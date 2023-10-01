return {
  'nvim-tree/nvim-tree.lua',
  version = '*',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local nvim_tree = require 'nvim-tree'
    vim.g.nvim_tree_disable_netrw = 0
    nvim_tree.setup {
      vim.keymap.set('n', '<leader>b', ':NvimTreeToggle<CR>', { desc = 'Open Nvim-tree' }),
    }
  end,
}
