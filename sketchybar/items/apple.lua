local settings = require("config.settings")

local apple = sbar.add("item", {
  icon = { string = settings.icons.nerdfont.apple, color = settings.colors.gruvbox.primary },
  label = { drawing = false },
  background = { drawing = false },
  click_script = "$CONFIG_DIR/items/menus/bin/menus -s 0"
})

-- @TODO have this as a constant
sbar.add("bracket", { apple.name }, {
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

sbar.add("item", {
  width = settings.dimens.padding.width
})
