return {
	-- Set lualine as statusline
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {
		options = {
			icons_enabled = true,
			theme = "onedark",
			component_separators = "|",
			section_separators = "",
		},
		sections = {
			lualine_a = { "mode", "branch" },
			lualine_b = { "diff", "diagnostics" },
		},
		winbar = {
			lualine_a = {},
			lualine_b = { { "filename", path = 1, symbols = { modified = " ●" } } },
		},
	},
}
