return {
  -- Multiple plugins that I have already installed do the same thing, but this one also opens the file/commit in github
  "f-person/git-blame.nvim",
  config = function()
    vim.keymap.set(
      "n",
      "<leader>gb",
      "<cmd>GitBlameToggle<cr>",
      { silent = true, noremap = true, desc = "[G]it[B]lameToggle" }
    )
    vim.keymap.set(
      "n",
      "<leader>goc",
      "<cmd>GitBlameOpenCommitURL<cr>",
      { silent = true, noremap = true, desc = "[G]itBlame[O]pen[C]ommitURL" }
    )
  end,
}
