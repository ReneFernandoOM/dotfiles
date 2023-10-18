return {
	"folke/trouble.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = {},
	config = function()
		vim.keymap.set(
			"n",
			"<leader>q",
			"<cmd>TroubleToggle workspace_diagnostics<cr>",
			{ silent = true, noremap = true, desc = "Open diagnostics list" }
		)
	end,
}
