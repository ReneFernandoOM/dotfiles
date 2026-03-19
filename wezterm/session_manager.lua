local wezterm = require 'wezterm'
local act = wezterm.action

wezterm.on('update-right-status', function(window)
    window:set_right_status(window:active_workspace())
end)

local M = {}

local function trim(value)
    return (value:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function basename(path)
    return path:match('([^/]+)/*$') or path
end

local function pane_cwd(pane)
    local cwd = pane:get_current_working_dir()
    if not cwd then
        return nil
    end

    if type(cwd) == 'table' or type(cwd) == 'userdata' then
        if cwd.file_path and cwd.file_path ~= '' then
            return cwd.file_path
        end
        if cwd.path and cwd.path ~= '' then
            return cwd.path
        end
    elseif type(cwd) == 'string' then
        if cwd:match('^file://') then
            local ok, parsed = pcall(function()
                return wezterm.url.parse(cwd)
            end)
            if ok and parsed and parsed.file_path and parsed.file_path ~= '' then
                return parsed.file_path
            end
            return cwd:gsub('^file://[^/]*', '')
        end
        return cwd
    end

    return nil
end

local function git_repo_root(path)
    local success_common, stdout_common = wezterm.run_child_process {
        'git', '-C', path, 'rev-parse', '--path-format=absolute', '--git-common-dir'
    }
    if success_common and stdout_common then
        local common_dir = trim(stdout_common):gsub('/+$', '')
        if common_dir ~= '' then
            local common_root = common_dir:gsub('/%.git$', '')
            if common_root ~= common_dir and common_root ~= '' then
                return common_root
            end
            return common_dir
        end
    end

    local success_toplevel, stdout_toplevel = wezterm.run_child_process {
        'git', '-C', path, 'rev-parse', '--show-toplevel'
    }
    if not success_toplevel or not stdout_toplevel then
        return nil
    end

    local toplevel = trim(stdout_toplevel)
    if toplevel == '' then
        return nil
    end

    return toplevel
end

local function list_repo_worktrees(repo_root)
    local success, stdout, stderr = wezterm.run_child_process { 'git', '-C', repo_root, 'worktree', 'list', '--porcelain' }
    if not success or not stdout then
        wezterm.log_error('Error listing worktrees: ' .. (stderr or 'unknown error'))
        return {}
    end

    local worktrees = {}
    local current_path = nil
    local current_branch = nil
    local current_detached = false
    local current_bare = false

    local function push_current()
        if not current_path then
            return
        end

        local branch = current_branch
        if current_bare then
            branch = '(bare)'
        elseif current_detached or not branch then
            branch = '(detached)'
        end

        local workspace_suffix = branch
        if branch == '(detached)' or branch == '(bare)' then
            workspace_suffix = branch .. '@' .. basename(current_path)
        end

        table.insert(worktrees, {
            path = current_path,
            branch = branch,
            workspace = basename(repo_root) .. ':' .. workspace_suffix,
        })
    end

    for line in (stdout .. '\n'):gmatch('([^\n]*)\n') do
        if line == '' then
            push_current()
            current_path = nil
            current_branch = nil
            current_detached = false
            current_bare = false
        elseif line:match('^worktree%s+') then
            current_path = line:gsub('^worktree%s+', '')
        elseif line:match('^branch%s+') then
            local ref = line:gsub('^branch%s+', '')
            current_branch = ref:gsub('^refs/heads/', '')
        elseif line == 'bare' then
            current_bare = true
        elseif line == 'detached' then
            current_detached = true
        end
    end

    return worktrees
end

local function workspace_exists(name)
    local names = wezterm.mux.get_workspace_names()
    for _, workspace_name in ipairs(names) do
        if workspace_name == name then
            return true
        end
    end
    return false
end

function M.switchToWorkspaceAction(window, pane)
    local success, stdout, stderr = wezterm.run_child_process { 'zsh', '-c', 'find ~/dev/personal/ ~/dev/earnin/  -maxdepth 1 -mindepth 1 -type d ' }

    local choices = {}
    if success and stdout then
        for line in stdout:gmatch("[^\n]+") do
            local absolute_path = line:match("^%s*(.-)%s*$")    -- Trim leading/trailing whitespace
            local workspaceName = absolute_path:match("[^/]+$") -- Grab last directory name from the absolute path
            table.insert(choices, { id = absolute_path, label = workspaceName })
        end
    else
        wezterm.log_error("Error running find:", stderr)
    end

    window:perform_action(
        act.InputSelector {
            action = wezterm.action_callback(
                function(inner_window, inner_pane, id, label)
                    if not id and not label then
                        wezterm.log_info 'cancelled'
                    else
                        wezterm.log_info('id = ' .. id)
                        wezterm.log_info('label = ' .. label)
                        inner_window:perform_action(
                            act.SwitchToWorkspace {
                                name = label,
                                spawn = {
                                    label = 'Workspace: ' .. label,
                                    cwd = id,
                                },
                            },
                            inner_pane
                        )
                    end
                end
            ),
            title = 'Choose Workspace',
            choices = choices,
            fuzzy = true,
            fuzzy_description = 'Fuzzy find and/or make a workspace',
        },
        pane
    )
end

function M.switchToWorktreeAction(window, pane)
    local cwd = pane_cwd(pane)
    if not cwd then
        wezterm.log_info('Could not determine pane cwd')
        return
    end

    local repo_root = git_repo_root(cwd)
    if not repo_root then
        wezterm.log_info('Current pane is not in a git repository')
        return
    end

    local worktrees = list_repo_worktrees(repo_root)
    if #worktrees == 0 then
        wezterm.log_info('No worktrees found for repo: ' .. repo_root)
        return
    end

    table.sort(worktrees, function(a, b)
        return a.branch < b.branch
    end)

    local choices = {}
    local by_path = {}
    for _, worktree in ipairs(worktrees) do
        local label = worktree.branch .. ' (' .. basename(worktree.path) .. ')'
        table.insert(choices, { id = worktree.path, label = label })
        by_path[worktree.path] = worktree
    end

    window:perform_action(
        act.InputSelector {
            action = wezterm.action_callback(
                function(inner_window, inner_pane, id, label)
                    if not id and not label then
                        wezterm.log_info 'cancelled'
                        return
                    end

                    local selected = by_path[id]
                    if not selected then
                        return
                    end

                    if workspace_exists(selected.workspace) then
                        inner_window:perform_action(
                            act.SwitchToWorkspace {
                                name = selected.workspace,
                            },
                            inner_pane
                        )
                        return
                    end

                    inner_window:perform_action(
                        act.SwitchToWorkspace {
                            name = selected.workspace,
                            spawn = {
                                label = 'Workspace: ' .. selected.workspace,
                                cwd = selected.path,
                            },
                        },
                        inner_pane
                    )

                    local function spawn_extra_tabs_when_ready(tries_left)
                        if inner_window:active_workspace() ~= selected.workspace then
                            if tries_left > 0 then
                                wezterm.time.call_after(0.15, function()
                                    spawn_extra_tabs_when_ready(tries_left - 1)
                                end)
                            end
                            return
                        end

                        local active_tab = inner_window:active_tab()
                        if not active_tab then
                            return
                        end

                        local active_pane = active_tab:active_pane()
                        if not active_pane then
                            return
                        end

                        inner_window:perform_action(
                            act.Multiple {
                                act.SpawnCommandInNewTab {
                                    cwd = selected.path,
                                },
                                act.SpawnCommandInNewTab {
                                    cwd = selected.path,
                                },
                            },
                            active_pane
                        )
                    end

                    wezterm.time.call_after(0.15, function()
                        spawn_extra_tabs_when_ready(8)
                    end)
                end
            ),
            title = 'Choose Worktree',
            choices = choices,
            fuzzy = true,
            fuzzy_description = 'Fuzzy find git worktrees in this repo',
        },
        pane
    )
end

return M
