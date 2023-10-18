return {
  "vimwiki/vimwiki",
  init = function()
    vim.g.vimwiki_list = {
      {
        syntax = "markdown",
        ext = ".md",
      },
    }
    vim.g.vimwiki_map_prefix = "<Leader>k"
  end,
}