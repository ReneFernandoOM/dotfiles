return {
	"rcarriga/nvim-notify",
	opts = {
		stages = "fade_in_slide_out",
		-- Default timeout for notifications
		timeout = 1500,
		background_colour = "#2E3440",
	},
	config = function()
		local nvim_notify = require("notify") -- Animation style
		vim.notify = nvim_notify
	end,
}
