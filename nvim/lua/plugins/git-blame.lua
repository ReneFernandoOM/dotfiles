return {
  -- Multiple plugins that I have already installed do the same thing, but this one also opens the file/commit in github
  'f-person/git-blame.nvim',
  config = function()
    vim.keymap.set('n', '<leader>gb', '<cmd>[G]it[B]lameToggle<cr>', { silent = true, noremap = true, desc = 'Toggles Blame Line' })
    vim.keymap.set('n', '<leader>goc', '<cmd>[G]itBlame[O]pen[C]ommitURL<cr>', { silent = true, noremap = true, desc = 'Open Commit Url in browser' })
  end,
}
