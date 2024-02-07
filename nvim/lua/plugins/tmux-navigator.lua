return {
  "christoomey/vim-tmux-navigator",
  event = "BufReadPre",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    -- bug with lazyvim, restore this later https://github.com/LazyVim/LazyVim/issues/1502
    -- { "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
    -- { "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
    -- { "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
    -- { "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
    { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
  },
}
