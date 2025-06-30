local constants = require("constants")
local settings = require("config.settings")

local frontAppWatcher = sbar.add("item", {
  drawing = false,
  updates = true,
})

local function updateWindows(windows)
  sbar.remove("/" .. constants.items.FRONT_APPS .. "\\.*/")

  local foundWindows = string.gmatch(windows, "[^\n]+")
  -- in practice we should only have one window due to how we query them from aerospace
  for window in foundWindows do
    local parsedWindow = {}
    for key, value in string.gmatch(window, "(%w+)=([%w%s]+)") do
      parsedWindow[key] = value
    end

    local windowName = parsedWindow["name"]

    sbar.add("item", constants.items.FRONT_APPS .. "." .. windowName, {
      label = {
        padding_left = 15,
        padding_right = 15,
        string = windowName,
        color = settings.colors.white
      },
      icon = { drawing = false },
      position = "q"
    })
  end
  sbar.add("bracket", { "/" .. constants.items.FRONT_APPS .. "\\..*/" },
    { background = { color = settings.colors.gruvbox.bg, border_color = settings.colors.gruvbox.primary, border_width = 3, corner_radius = 20, height = 30 } })
end

local function getWindows()
  sbar.exec(constants.aerospace.LIST_WINDOWS, updateWindows)
end

frontAppWatcher:subscribe(constants.events.UPDATE_WINDOWS, function()
  getWindows()
end)

getWindows()
