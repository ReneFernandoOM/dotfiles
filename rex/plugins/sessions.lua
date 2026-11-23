-- Jump to a named session's first tab, creating the session in its directory if it doesn't exist
-- (like wezterm's SwitchToWorkspace with spawn.cwd).
--
--   require("plugins.sessions").setup({
--       sessions = {
--           { key = "ctrl+a>o", label = "dotfiles", cwd = "~/dev/personal/dotfiles" },
--       },
--   })
--
-- Also scriptable: rex do session_goto label=dotfiles cwd=~/dev/personal/dotfiles

local utils = require("core.utils")

local M = {}

M.defaults = {
    -- Each entry: key (a key or a list of keys), label, and cwd for when the session is created.
    sessions = {},
}

M.options = M.defaults

local function expand(path)
    return path and (path:gsub("^~", os.getenv("HOME") or "~")) or nil
end

local function find_session(label)
    local sessions = (rex.call("session.list", {}) or {}).sessions or {}
    for _, session in ipairs(sessions) do
        if session.label == label then
            return session.session_id
        end
    end
end

-- Other sessions can only be read while attached to them, and attaching returns the view.
local function first_window(session_id)
    local view = rex.call("session.view", { session_id = session_id })
    local attached
    if not view then
        attached = rex.call("session.attach", { session_id = session_id })
        view = attached and attached.view
    end
    local window = view and view.windows and view.windows[1]
    if attached then
        rex.call("session.detach", { session_id = session_id })
    end
    return window and window.window_id
end

local function create_session(label, cwd)
    local created, err = rex.call("session.create", {
        label = label,
        initial_windows = {
            {
                layout = rex.layout.block({
                    flavor = "com.superlogical.terminal.shell",
                    options = { cwd = expand(cwd) },
                }),
            },
        },
    })
    if not created then
        error("could not create session " .. label .. ": " .. tostring(err), 0)
    end
    return created.session_id
end

function M.go_to(_, args)
    local session_id = find_session(args.label) or create_session(args.label, args.cwd)
    rex.client.queue("session.select", { session_id = session_id, window_id = first_window(session_id) })
end

function M.setup(opts)
    M.options = utils.merge(M.defaults, opts)

    rex.action({
        name = "session_goto",
        title = "Go to Session by Name",
        args = { label = "string", cwd = "string?" },
        run = M.go_to,
    })

    for _, session in ipairs(M.options.sessions) do
        utils.bind(session.key, "session_goto", { label = session.label, cwd = session.cwd })
    end
end

return M
