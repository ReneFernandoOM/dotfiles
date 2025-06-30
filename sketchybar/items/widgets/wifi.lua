local constants = require("constants")
local settings = require("config.settings")

local popupWidth <const> = settings.dimens.graphics.popup.width + 20


local wifi = sbar.add("item", constants.items.WIFI .. ".padding", {
  position = "right",
  label = { drawing = false },
  padding_right = 0,
})

local wifiBracket = sbar.add("bracket", constants.items.WIFI .. ".bracket", {
  wifi.name,
}, {
  popup = { align = "center" },
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

local ssid = sbar.add("item", {
  align = "center",
  position = "popup." .. wifiBracket.name,
  width = popupWidth,
  height = 16,
  icon = {
    string = settings.icons.nerdfont.wifi.router,
    font = {
      style = settings.fonts.styles.bold
    },
  },
  label = {
    font = {
      style = settings.fonts.styles.bold,
      size = settings.dimens.text.label,
    },
    max_chars = 18,
    string = "????????????",
  },
})

sbar.add("item", { position = "right", width = settings.dimens.padding.item })

wifi:subscribe({ "wifi_change", "system_woke", "forced" }, function()
  wifi:set({
    icon = {
      string = settings.icons.nerdfont.wifi.disconnected,
      color = settings.colors.magenta,
    }
  })

  sbar.exec([[ipconfig getifaddr en0]], function(ip)
    local ipConnected = not (ip == "")

    local wifiIcon
    local wifiColor

    if ipConnected then
      wifiIcon = settings.icons.nerdfont.wifi.connected
      wifiColor = settings.colors.gruvbox.wifi
    end

    wifi:set({
      icon = {
        string = wifiIcon,
        color = wifiColor,
      }
    })
  end)
end)

local function hideDetails()
  wifiBracket:set({ popup = { drawing = false } })
end

local function toggleDetails()
  local shouldDrawDetails = wifiBracket:query().popup.drawing == "off"

  if shouldDrawDetails then
    wifiBracket:set({ popup = { drawing = true } })
    sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
      ssid:set({ label = result })
    end)
  else
    hideDetails()
  end
end

wifi:subscribe("mouse.entered", toggleDetails)
wifi:subscribe("mouse.exited", toggleDetails)
