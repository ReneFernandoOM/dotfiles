local constants = require("constants")
local settings = require("config.settings")

local isCharging = false

local battery = sbar.add("item", constants.items.battery, {
  position = "right",
  update_freq = 60,
})

local batteryPopup = sbar.add("item", {
  position = "popup." .. battery.name,
  width = "dynamic",
  label = {
    padding_right = settings.dimens.padding.label,
    padding_left = settings.dimens.padding.label,
  },
  icon = {
    padding_left = 0,
    padding_right = 0,
  },
})


sbar.add("bracket", { battery.name }, {
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

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
  sbar.exec("pmset -g batt", function(batteryInfo)
    local icon = "!"
    local label = "?"

    local found, _, charge = batteryInfo:find("(%d+)%%")
    if found then
      charge = tonumber(charge)
      label = charge .. "%"
    end

    local color = settings.colors.green
    local charging, _, _ = batteryInfo:find("AC Power")

    isCharging = charging

    if charging then
      icon = settings.icons.text.battery.charging
    else
      if found and charge > 80 then
        icon = settings.icons.nerdfont.battery._100
      elseif found and charge > 60 then
        icon = settings.icons.nerdfont.battery._75
      elseif found and charge > 40 then
        icon = settings.icons.nerdfont.battery._50
      elseif found and charge > 30 then
        icon = settings.icons.nerdfont.battery._50
        color = settings.colors.yellow
      elseif found and charge > 20 then
        icon = settings.icons.nerdfont.battery._25
        color = settings.colors.orange
      else
        icon = settings.icons.nerdfont.battery._0
        color = settings.colors.red
      end
    end

    local lead = ""
    if found and charge < 10 then
      lead = "0"
    end

    battery:set({
      icon = {
        string = icon,
        color = color
      },
      label = {
        string = lead .. label,
        padding_left = 0,
      },
    })
  end)
end)

battery:subscribe("mouse.entered", function()
  local drawing = battery:query().popup.drawing

  battery:set({ popup = { drawing = "toggle" } })

  if drawing == "off" then
    sbar.exec("pmset -g batt", function(batteryInfo)
      local found, _, remaining = batteryInfo:find("(%d+:%d+) remaining")
      local label = found and ("Time remaining: " .. remaining .. "h") or (isCharging and "Charging" or "No estimate")
      batteryPopup:set({ label = label })
    end)
  end
end)

battery:subscribe("mouse.exited", function()
  local drawing = battery:query().popup.drawing

  if drawing == "on" then
    battery:set({ popup = { drawing = false } })
  end
end)
