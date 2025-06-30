local constants = require("constants")
local settings = require("config.settings")

local volumeValue = sbar.add("item", constants.items.VOLUME .. ".value", {
  position = "right",
  label = {
    string = "??%",
    padding_left = 0,
  },
})


sbar.add("bracket", { volumeValue.name }, {
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

volumeValue:subscribe("volume_change", function(env)
  local icon = settings.icons.nerdfont.volume._0
  local volume = tonumber(env.INFO)

  if volume > 60 then
    icon = settings.icons.nerdfont.volume._100
  elseif volume > 30 then
    icon = settings.icons.nerdfont.volume._66
  elseif volume > 10 then
    icon = settings.icons.nerdfont.volume._33
  elseif volume > 0 then
    icon = settings.icons.nerdfont.volume._10
  end

  local lead = ""
  if volume < 10 then
    lead = "0"
  end

  local hasVolume = volume ~= 0
  volumeValue:set({
    icon = { string = icon, color = settings.colors.gruvbox.secondary },
    label = {
      string = hasVolume and lead .. volume .. "%" or "",
      padding_right = hasVolume and 8 or 0,
    },
  })
end)


local function changeVolume(env)
  local delta = env.SCROLL_DELTA
  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volumeValue:subscribe("mouse.scrolled", changeVolume)
