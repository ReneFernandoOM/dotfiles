local wezterm = require 'wezterm'
local config = wezterm.config_builder()
local session_manager = require('session_manager')
local helpers = require('helpers')
local split_nav = require('splitnav')

local act = wezterm.action

config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

config.window_decorations = 'RESIZE'
config.tab_bar_at_bottom = true

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
    { key = 'r', mods = 'LEADER',       action = act.ReloadConfiguration },
    { key = 'c', mods = 'LEADER',       action = act.SpawnTab('CurrentPaneDomain') },
    { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '-', mods = 'LEADER',       action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    {
        key = 'w',
        mods = 'LEADER|CTRL',
        action = wezterm.action.CloseCurrentTab { confirm = false },
    },
    {
        key = 'w',
        mods = 'LEADER',
        action = wezterm.action.CloseCurrentPane { confirm = false },
    },
}

-- split navigation and resizing
split_nav.apply_to_config(config)

-- move to tabs
for i = 1, 9 do
    local keybinding = { key = tostring(i), mods = 'LEADER', action = act.ActivateTab(i - 1) }
    table.insert(config.keys, keybinding)
end

local dualModKeys = helpers.withExtraModBatch('CTRL',
    {
        key = 'f',
        mods = 'LEADER',
        action = wezterm.action_callback(session_manager.switchToWorkspaceAction)
    },
    { key = 'Enter', mods = 'LEADER', action = act.ActivateCopyMode },
    {
        key = 'o',
        mods = 'LEADER',
        action = act.SwitchToWorkspace {
            name = "dotfiles",
            spawn = { cwd = os.getenv("HOME") .. "/dev/personal/dotfiles/" }
        }
    },
    {
        key = 'p',
        mods = 'LEADER',
        action = act.SwitchToWorkspace {
            name = "data-strctures-and-algorithms",
            spawn = { cwd = os.getenv("HOME") .. "/dev/personal/data-strctures-and-algorithms/" }
        }
    },
    -- Show the launcher in fuzzy selection mode and have it list all workspaces
    -- and allow activating one.
    {
        key = 's',
        mods = 'LEADER',
        action = act.ShowLauncherArgs {
            flags = 'FUZZY|WORKSPACES',
        },
    }
)

for _, keybind in ipairs(dualModKeys) do
    table.insert(config.keys, keybind)
end

return config
