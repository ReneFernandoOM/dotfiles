return {
  'sindrets/diffview.nvim',
  config = function()
    local diffview = require 'diffview'
    vim.keymap.set('n', '<leader>fh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'Open [F]ile [H]istory' })
    diffview.setup {
      view = {
        merge_tool = {
          layout = 'diff3_mixed',
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          disable_diagnostics = true,
          winbar_info = false,
        },
      },
    }
  end,
}
