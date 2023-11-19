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
  config = function()
    vim.keymap.set("n", "<leader>kf", function()
      require("telescope.builtin").find_files({ cwd = "~/vimwiki", prompt_title = "vimwiki" })
    end, { desc = "Search [V]im Wiki file[s]" })
  end,
}
