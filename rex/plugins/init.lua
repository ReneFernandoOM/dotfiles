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

require("plugins.sessions").setup({
    sessions = {
        { key = utils.with_ctrl("ctrl+a>r"), label = "control-plane", cwd = "~/dev/earnin/control-plane" },
        { key = utils.with_ctrl("ctrl+a>o"), label = "dotfiles", cwd = "~/dev/personal/dotfiles" },
        { key = utils.with_ctrl("ctrl+a>i"), label = "go-bananas", cwd = "~/dev/personal/go-bananas" },
        { key = utils.with_ctrl("ctrl+a>e"), label = "data-plane", cwd = "~/dev/earnin/svc-managed-payroll-data-plane" },
    },
})

require("plugins.navigator").setup({
    wrap = false,
})
