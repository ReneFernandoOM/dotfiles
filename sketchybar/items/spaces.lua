local constants = require("constants")
local settings = require("config.settings")

local function addWorkspaceItem(workspaceName)
  local spaceName = constants.items.SPACES .. "." .. workspaceName

  local workspaceItem = sbar.add("item", spaceName, {
    label = {
      drawing = false,
    },
    icon = {
      string = workspaceName,
      color = settings.colors.gruvbox.primary,
      padding_left = 5,
      padding_right = 5,
    },
    background = {
      height = 20,
      padding_left = 5,
      padding_right = workspaceName == "9" and 10 or 5,
      corner_radius = 20,
      drawing = false,
    },
    click_script = "aerospace workspace " .. workspaceName,
  })

  workspaceItem:subscribe(constants.events.AEROSPACE_WORKSPACE_CHANGED, function(env)
    local isSelected = env.FOCUSED_WORKSPACE == workspaceName
    workspaceItem:set({
      icon = { color = isSelected and settings.colors.gruvbox.bg or settings.colors.gruvbox.primary },
      background = { color = isSelected and settings.colors.gruvbox.secondary or settings.colors.gruvbox.bg },
    })
  end)
end

local function createWorkspaces()
  sbar.exec(constants.aerospace.LIST_ALL_WORKSPACES, function(workspacesOutput)
    for workspaceName in workspacesOutput:gmatch("[^\r\n]+") do
      addWorkspaceItem(workspaceName)
    end

    sbar.add("bracket", { "/" .. constants.items.SPACES .. "\\..*/" }, {
      background = {
        color = settings.colors.gruvbox.bg,
        padding_left = settings.dimens.padding.item,
        padding_right = settings.dimens.padding.item,
        border_color = settings.colors.gruvbox.primary,
        height = 30,
        border_width = 3,
        corner_radius = 20,
      },
    })
  end)
end

createWorkspaces()
