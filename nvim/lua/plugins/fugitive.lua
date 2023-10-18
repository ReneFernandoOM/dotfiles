return {
  -- Git related plugins
  'tpope/vim-fugitive',
  config = function()
    -- Define browse method for GBrowse. 'xdg-open' for linux, 'open' for macOs
    vim.cmd [[ command! -nargs=1 Browse silent execute '!xdg-open' shellescape(<q-args>,1) ]]
    vim.keymap.set('n', '<leader>gs', '<cmd>Git<cr>', { desc = '[G]it [S]tatus' })
    vim.keymap.set('n', '<leader>gl', '<cmd>Git pull<cr>', { desc = '[G]it pu[L]l' })
    -- Opens current file in github
    vim.keymap.set('n', '<leader>gof', '<cmd>GBrowse<cr>', { desc = '[G]it [O]pen [F]ile' })
    -- Opens current selection in github
    vim.keymap.set('v', '<leader>gof', ':GBrowse<cr>', { desc = '[G]it [O]pen selection' })
  end,
}
