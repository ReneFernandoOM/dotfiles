local wezterm = require 'wezterm'
local act = wezterm.action

wezterm.on('update-right-status', function(window)
    window:set_right_status(window:active_workspace())
end)

local M = {}

function M.switchToWorkspaceAction(window, pane)
    local success, stdout, stderr = wezterm.run_child_process { 'zsh', '-c', 'find ~/Documents/personal/ -maxdepth 1 -mindepth 1 -type d ' }

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

return M
