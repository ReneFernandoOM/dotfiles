local utils = require("core.utils")

require("plugins.pane_resize").setup({
    modifier = "alt+shift",
    amount = 3,
})

require("plugins.worktree").setup({
    keys = { new = "ctrl+a>shift+w" },
})

require("plugins.tab_finder").setup({
    keys = { find = utils.with_ctrl("ctrl+a>f") },
})

require("plugins.navigator").setup({
    wrap = false,
})
