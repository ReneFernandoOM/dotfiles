-- Fuzzy-find a tab across every session, with agent tabs sorted first by how
-- much they need you (blocked, error, done, working, idle).
--
--   require("plugins.tab_finder").setup({ keys = { find = "ctrl+a>f" } })
--
-- A key can also be a list, e.g. utils.with_ctrl("ctrl+a>f") for ctrl+a>f and ctrl+a>ctrl+f.
--
-- Also scriptable: rex do tab_find list=true, or rex do tab_find id='<session_id>|<window_id>'

local utils = require("core.utils")

local M = {}

M.defaults = {
    keys = {
        find = nil,
    },
    -- Program names (from argv0 or the process name) that are coding agents.
    agents = {
        agent = "cursor",
        ["cursor-agent"] = "cursor",
        claude = "claude",
        codex = "codex",
        opencode = "opencode",
        pi = "pi",
    },
    shells = { zsh = true, bash = true, fish = true, sh = true, nu = true },
    -- Program status states, most urgent first.
    status_order = { "blocked", "error", "done", "working", "idle" },
    include_current = false,
    -- How long after a switch to keep putting back the tab's focused or zoomed pane.
    restore_for = "1s",
    rex_bin = "/Applications/Rex.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex",
}

local restore_script = debug.getinfo(1, "S").source:gsub("^@", ""):gsub("init%.lua$", "restore.lua")

M.options = M.defaults

local status_rank = {}

local function terminal_call(method, session_id, block_id)
    return rex.block.call("com.superlogical.terminal", method, {
        session_id = session_id,
        block_id = block_id,
    })
end

local function basename(path)
    return path and path:match("([^/]+)/*$") or nil
end

local function program_name(fg)
    local name = basename(fg.argv0) or fg.name or "?"
    return (name:gsub("^%-", ""))
end

local function describe_block(session_id, block_id)
    local process = terminal_call("process", session_id, block_id) or {}
    local fg = process.foreground or {}
    local prog = program_name(fg)
    local agent = M.options.agents[prog] or M.options.agents[fg.name or ""]

    local status
    local records = (terminal_call("program_status", session_id, block_id) or {}).records or {}
    for _, record in ipairs(records) do
        local rank = status_rank[record.state]
        -- Done and error records outlive their program, so ignore ones a previous program left.
        local live = record.owner and record.owner.pid == fg.pid
        if rank and live and (not status or rank < status.rank) then
            status = { state = record.state, rank = rank, app = record.effective_app }
        end
    end

    -- Shells title themselves user@host:path, which reads worse than "zsh · dir".
    local title
    if not M.options.shells[prog] then
        title = (terminal_call("title", session_id, block_id) or {}).title
        if title and utils.trim(title) == "" then
            title = nil
        end
    end

    return {
        agent = agent or (status and status.app),
        status = status,
        prog = agent or prog,
        cwd = fg.cwd,
        title = title,
    }
end

local function more_urgent(a, b)
    if not b then
        return true
    end
    local ra = a.status and a.status.rank or math.huge
    local rb = b.status and b.status.rank or math.huge
    return ra < rb
end

local function window_blocks(window)
    local blocks = {}
    for _, layer in ipairs(window.layers or {}) do
        for _, block in ipairs(layer.blocks or {}) do
            table.insert(blocks, block.block_id)
        end
    end
    return blocks
end

-- Prefers a label you gave the tab, then the focused pane's title (as the sidebar shows it),
-- then program and directory.
local function tab_name(window, focused)
    if not window.label:match("^Window %x+$") then
        return window.label
    end
    if focused.title then
        return focused.title
    end
    local dir = basename(focused.cwd)
    return dir and (focused.prog .. " · " .. dir) or focused.prog or window.label
end

-- Other sessions can only be read while attached to them, and attaching returns the view.
local function open_session(session_id)
    local view = rex.call("session.view", { session_id = session_id })
    if view then
        return view, false
    end
    local attached = rex.call("session.attach", { session_id = session_id })
    return attached and attached.view or {}, attached ~= nil
end

function M.items(ctx)
    local home = os.getenv("HOME") or ""
    local unranked = #M.options.status_order + 1
    local items = {}

    local sessions = (rex.call("session.list", {}) or {}).sessions or {}
    for s_index, session in ipairs(sessions) do
        local view, attached = open_session(session.session_id)
        for w_index, window in ipairs(view.windows or {}) do
            local blocks = window_blocks(window)
            -- The session's active window follows newly created tabs, so use the pane the action ran from.
            local current = false
            if ctx and ctx.block_id and session.session_id == ctx.session_id then
                for _, block_id in ipairs(blocks) do
                    current = current or block_id == ctx.block_id
                end
            end
            if M.options.include_current or not current then
                local focused, agent
                for _, block_id in ipairs(blocks) do
                    local d = describe_block(session.session_id, block_id)
                    if block_id == window.focused_block_id then
                        focused = d
                    end
                    if d.agent and more_urgent(d, agent) then
                        agent = d
                    end
                end
                focused = focused or agent or {}
                local shown = agent or focused

                table.insert(items, {
                    id = session.session_id .. "|" .. window.window_id,
                    title = session.label .. " › " .. tab_name(window, focused),
                    subtitle = shown.cwd and (shown.cwd:sub(1, #home) == home and "~" .. shown.cwd:sub(#home + 1) or shown.cwd),
                    detail = agent and ((agent.status and agent.status.state or "agent") .. " · " .. agent.agent) or nil,
                    icon = agent and "star" or (shown.prog == "nvim" and "code" or "terminal"),
                    rank = { agent and (agent.status and agent.status.rank or unranked) or unranked + 1, s_index, w_index },
                    focused_block_id = window.focused_block_id,
                    zoomed_block_id = window.zoomed_block_id,
                })
            end
        end
        if attached then
            rex.call("session.detach", { session_id = session.session_id })
        end
    end

    table.sort(items, function(a, b)
        for i = 1, 3 do
            if a.rank[i] ~= b.rank[i] then
                return a.rank[i] < b.rank[i]
            end
        end
        return false
    end)
    for _, item in ipairs(items) do
        item.rank = nil
    end
    return items
end

local function rex_bin()
    local dir = os.getenv("REX_BIN_DIR")
    return dir and (dir .. "/rex") or M.options.rex_bin
end

-- The app moves focus in the new tab after this action returns (see restore.lua), and actions
-- can't handle events, so a short-lived script does it. Unless detached, Rex stops it on return.
local function restore_focus(session_id, item)
    local block_id = item.zoomed_block_id or item.focused_block_id
    if not block_id then
        return
    end
    local _, err = rex.exec.start({
        rex_bin(), "do", "-s", session_id, "--for", M.options.restore_for, restore_script,
        "--args", rex.json.encode({ block_id = block_id, zoom = item.zoomed_block_id ~= nil }),
    }, { detach = true })
    if err then
        rex.log("warn", "tab_find: could not restore focus: " .. tostring(err))
    end
end

function M.find(ctx, args)
    local items = M.items(ctx)
    if args and args.list then
        return items
    end

    local id = args and args.id or rex.ui.pick({
        title = "Go to tab",
        placeholder = "Filter tabs",
        items = items,
    })
    if id == nil then
        return
    end
    local session_id, window_id = id:match("^(.-)|(.*)$")
    rex.client.queue("session.select", { session_id = session_id, window_id = window_id })

    for _, item in ipairs(items) do
        if item.id == id then
            restore_focus(session_id, item)
        end
    end
end

function M.setup(opts)
    M.options = utils.merge(M.defaults, opts)
    status_rank = {}
    for i, state in ipairs(M.options.status_order) do
        status_rank[state] = i
    end

    rex.action({
        name = "tab_find",
        title = "Find Tab…",
        args = { list = "boolean?", id = "string?" },
        run = M.find,
    })

    if M.options.keys.find then
        utils.bind(M.options.keys.find, "tab_find")
    end
end

return M
