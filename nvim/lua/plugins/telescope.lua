local utils = require("core.utils")

return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      -- NOTE: If having trouble, check telescope-fzf-native README
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    opts = {},
  },
  config = function()
    local telescope = require("telescope")
    telescope.load_extension("fzf")
    local gitWorktree = telescope.load_extension("git_worktree")
    local fzf_opts = {
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    }
    telescope.setup({
      defaults = {
        path_display = { "tail" },
        dynamic_preview_title = true,
        cache_picker = {
          num_pickers = 5,
        },
        mappings = {
          i = {
            ["<C-Down>"] = require("telescope.actions").cycle_history_next,
            ["<C-Up>"] = require("telescope.actions").cycle_history_prev,
          },
        },
      },
      pickers = {
        -- Manually set sorter, for some reason not picked up automatically, especially bad on python?
        lsp_dynamic_workspace_symbols = {
          sorter = telescope.extensions.fzf.native_fzf_sorter(fzf_opts),
        },
      },
      extensions = {
        fzf = fzf_opts,
      },
    })
    vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
    vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
    vim.keymap.set("n", "<leader>/", function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = true,
      }))
    end, { desc = "[/] Fuzzily search in current buffer" })

    -- Git worktree
    vim.keymap.set("n", "<leader>gwc", gitWorktree.git_worktrees, { desc = "[G]it  [W]orktree [C]heckout" })
    vim.keymap.set("n", "<leader>gwa", gitWorktree.create_git_worktree, { desc = "[S]earch [F]iles" })

    vim.keymap.set("n", "<leader>gf", require("telescope.builtin").git_files, { desc = "Search [G]it [F]iles" })
    vim.keymap.set("n", "<leader>sf", function()
      require("telescope.builtin").find_files()
    end, { desc = "[S]earch [F]iles" })
    vim.keymap.set("n", "<leader>sh", require("telescope.builtin").help_tags, { desc = "[S]earch [H]elp" })
    vim.keymap.set("n", "<leader>scd", require("telescope.builtin").git_commits,
      { desc = "[S]earch [C]ommits [D]irectory" })
    vim.keymap.set("n", "<leader>scb", require("telescope.builtin").git_bcommits,
      { desc = "[S]earch [B]uffer [C]ommits" })
    vim.keymap.set("n", "<leader>sm", require("telescope.builtin").man_pages, { desc = "[S]earch [M]an Pages" })
    vim.keymap.set("n", "<leader>sw", require("telescope.builtin").grep_string, { desc = "[S]earch current [W]ord" })
    vim.keymap.set("n", "<leader>sd", require("telescope.builtin").diagnostics, { desc = "[S]earch [D]iagnostics" })
    vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep, { desc = "[S]earch [D]iagnostics" })
    vim.keymap.set("n", "<leader>sr", require("telescope.builtin").resume, { desc = "[R]esume [S]earch" })

    -- Speial Keymaps for obsidian
    vim.keymap.set("n", "<leader>sg", function()
      if utils.getGitRootDir() == "/home/rene/dev/personal/ObsidianVault" then
        return "<cmd>ObsidianSearch<CR>"
      else
        return "<cmd>Telescope live_grep<CR>"
      end
    end, { noremap = false, expr = true, desc = "[G]rep" })
  end,
}
