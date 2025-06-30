local settings = require("config.settings")

sbar.bar({
	topmost = "window",
	height = settings.dimens.graphics.bar.height,
	color = settings.colors.transparent,
	padding_right = settings.dimens.padding.right,
	padding_left = settings.dimens.padding.left,
	margin = settings.dimens.padding.bar,
	y_offset = settings.dimens.graphics.bar.offset,
	border_width = 0,
})
