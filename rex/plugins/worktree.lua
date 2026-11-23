-- Create a git worktree for the focused pane's repo and open it in a new tab.
--
--   require("plugins.worktree").setup({ keys = { new = "ctrl+a>shift+w" } })
--
-- Also scriptable: rex do git_worktree_new branch=foo base=origin/main

local utils = require("core.utils")
local trim = utils.trim

local M = {}

M.defaults = {
    keys = {
        new = nil,
    },
    remote = "origin",
    -- Used when the base prompt is submitted empty.
    default_base = "origin/HEAD",
    -- Fetch remote bases before branching so they're current.
    fetch = true,
    -- rex.ui.pick shows at most 2,000 items.
    max_remote_branches = 1400,
    max_local_branches = 500,
    git_timeout = 120,
}

M.options = M.defaults

local function git(cwd, ...)
    local r, err = rex.exec({ "git", ... }, { cwd = cwd, timeout = M.options.git_timeout })
    if r == nil then
        return nil, err
    end
    if not r.ok then
        local msg = r.stderr ~= "" and r.stderr or r.stdout
        return nil, trim(msg)
    end
    return trim(r.stdout)
end

local function ref_exists(repo, ref)
    return git(repo, "show-ref", "--verify", "--quiet", ref) ~= nil
end

local function show_error(msg)
    rex.log("warn", "worktree: " .. msg)
    rex.ui.pick({
        title = "Worktree failed",
        items = { { id = "ok", title = (msg:gsub("\n", " ")) } },
        confirm = "OK",
    })
end

local function focused_cwd(ctx)
    local process = rex.block.call("com.superlogical.terminal", "process", {
        session_id = ctx.session_id,
        block_id = ctx.block_id,
    })
    return process and process.foreground and process.foreground.cwd
end

-- Returns the repo root, and whether it's a bare repo.
local function find_repo(cwd)
    local common = git(cwd, "rev-parse", "--path-format=absolute", "--git-common-dir")
    if not common then
        return nil
    end
    local bare = git(common, "rev-parse", "--is-bare-repository") == "true"
    return bare and common or (common:gsub("/%.git$", "")), bare
end

-- Bare repos keep their worktrees inside the repo directory.
local function worktree_path(repo, bare, branch)
    local dir = branch:gsub("/", "-")
    return bare and (repo .. "/" .. dir) or (repo .. ".worktrees/" .. dir)
end

local function branch_items(repo)
    local opts = M.options
    local items = { { id = opts.default_base, title = opts.default_base, subtitle = "default", icon = "branch" } }
    local seen = { [opts.default_base] = true, [opts.remote] = true }
    local function add(pattern, limit)
        local out = git(repo, "for-each-ref", "--sort=-committerdate", "--count=" .. limit,
            "--format=%(refname:short)\t%(committerdate:relative)", pattern) or ""
        for line in out:gmatch("[^\n]+") do
            local name, date = line:match("^([^\t]+)\t(.*)$")
            if name and not seen[name] then
                seen[name] = true
                table.insert(items, { id = name, title = name, detail = date, icon = "branch" })
            end
        end
    end
    add("refs/remotes/" .. opts.remote, opts.max_remote_branches)
    add("refs/heads", opts.max_local_branches)
    return items
end

local function ask_base(repo, branch)
    local base = rex.ui.pick({
        title = "Base " .. branch .. " on",
        placeholder = "Branch or ref (default " .. M.options.default_base .. ")",
        items = branch_items(repo),
        allow_other = true,
        confirm = "Create worktree",
    })
    if type(base) == "table" then
        base = trim(base.text)
    end
    return base
end

-- Resolves symbolic refs like origin/HEAD and fetches remote bases.
local function prepare_base(repo, base)
    local opts = M.options
    local prefix = opts.remote .. "/"
    if base == prefix .. "HEAD" then
        base = git(repo, "symbolic-ref", "--short", "refs/remotes/" .. base) or base
    end
    local remote_branch = base:sub(1, #prefix) == prefix and base:sub(#prefix + 1)
    if opts.fetch and remote_branch and remote_branch ~= "" then
        local _, err = git(repo, "fetch", opts.remote, remote_branch)
        if err then
            rex.log("warn", "worktree: fetch failed, using local " .. base .. ": " .. err)
        end
    end
    return base
end

function M.new(ctx, args)
    args = args or {}
    local opts = M.options

    local cwd = focused_cwd(ctx)
    if not cwd then
        return show_error("Couldn't find the focused pane's directory")
    end
    local repo, bare = find_repo(cwd)
    if not repo then
        return show_error("Not a git repository: " .. cwd)
    end

    local branch = args.branch or rex.ui.input({
        title = "New worktree in " .. repo:match("([^/]+)$"),
        placeholder = "Branch name",
        confirm = "Next",
    })
    if branch == nil then
        return
    end
    branch = trim(branch)
    if branch == "" then
        return
    end

    local path = worktree_path(repo, bare, branch)
    local _, err
    if ref_exists(repo, "refs/heads/" .. branch) or ref_exists(repo, "refs/remotes/" .. opts.remote .. "/" .. branch) then
        _, err = git(repo, "worktree", "add", path, branch)
    else
        local base = args.base or ask_base(repo, branch)
        if base == nil then
            return
        end
        base = prepare_base(repo, base ~= "" and base or opts.default_base)
        _, err = git(repo, "worktree", "add", "--no-track", "-b", branch, path, base)
    end
    if err then
        return show_error(err)
    end

    rex.session.new_window({
        session_id = ctx.session_id,
        window_label = branch,
        layout = rex.layout.block({
            flavor = "com.superlogical.terminal.shell",
            options = { cwd = path },
        }),
    })
end

function M.setup(opts)
    M.options = utils.merge(M.defaults, opts)

    rex.action({
        name = "git_worktree_new",
        title = "Git: New Worktree…",
        args = { branch = "string?", base = "string?" },
        run = M.new,
    })

    if M.options.keys.new then
        rex.bind(M.options.keys.new, "git_worktree_new")
    end
end

return M
