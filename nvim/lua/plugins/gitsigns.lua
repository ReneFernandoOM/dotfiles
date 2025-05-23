return {
  -- Adds git releated signs to the gutter, as well as utilities for managing changes
  "lewis6991/gitsigns.nvim",
  opts = {
    -- See `:help gitsigns.txt`
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
      local gs = require("gitsigns")

      vim.keymap.set("n", "<leader>gp", function()
        gs.prev_hunk()
        -- presumably, gitsigns runs asyncronously so we need to have a small delay before centering the screen
        vim.defer_fn(function()
          vim.cmd("normal! zz")
        end, 20)
      end, { buffer = bufnr, desc = "[G]o to [P]revious Hunk" })

      vim.keymap.set("n", "<leader>gn", function()
        gs.next_hunk()
        vim.defer_fn(function()
          vim.cmd("normal! zz")
        end, 20)
      end, { buffer = bufnr, desc = "[G]o to [N]ext Hunk" })

      vim.keymap.set("n", "<leader>ph", gs.preview_hunk, { buffer = bufnr, desc = "[P]review [H]unk" })
      vim.keymap.set("n", "<leader>rh", gs.reset_hunk, { buffer = bufnr, desc = "[R]estore [H]unk" })
    end,
  },
}
