return {
  "sindrets/diffview.nvim",
  config = function()
    local diffview = require("diffview")
    vim.keymap.set("n", "<leader>fh", "<cmd>DiffviewFileHistory % --no-merges<cr>", { desc = "Open [F]ile [H]istory" })
    vim.keymap.set("v", "<leader>fh", ":DiffviewFileHistory % --no-merges<cr>", { desc = "Open [F]ile [H]istory" })
    diffview.setup({
      view = {
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          disable_diagnostics = true,
          winbar_info = false,
        },
        git = {
          log_args = { "--no-merges" }, -- Exclude merge commits
        },
      },
    })
  end,
}
