return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		enabled = false,
		config = function()
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		"ellisonleao/gruvbox.nvim",
		priority = 2000,
		lazy = false,
		config = function()
			vim.cmd.colorscheme("gruvbox")
		end,
	},
}
