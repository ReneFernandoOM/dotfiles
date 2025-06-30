local constants = require("constants")
local settings = require("config.settings")

local calendar = sbar.add("item", constants.items.CALENDAR, {
  position = "right",
  update_freq = 10,
  icon = { string = settings.icons.nerdfont.calendar, color = settings.colors.gruvbox.calendar },
  background = { padding_right = 5, padding_left = 5 }
})

sbar.add("bracket", { calendar.name }, {
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

calendar:subscribe({ "forced", "routine", "system_woke" }, function()
  calendar:set({
    label = os.date("%a %d %b, %H:%M"),
  })
end)

calendar:subscribe("mouse.clicked", function()
  sbar.exec("open -a 'Calendar'")
end)
