require("plugins.pane_resize").setup({
    modifier = "alt+shift",
    amount = 3,
})

require("plugins.worktree").setup({
    keys = { new = "ctrl+a>shift+w" },
})

require("plugins.navigator").setup({
    wrap = false,
})
