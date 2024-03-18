return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local function my_on_attach(bufnr)
      local api = require("nvim-tree.api")

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- default mappings
      api.config.mappings.default_on_attach(bufnr)

      -- custom mappings
      vim.keymap.del("n", "s", opts("del"))
    end

    local nvim_tree = require("nvim-tree")
    vim.g.nvim_tree_disable_netrw = 0
    nvim_tree.setup({
      vim.keymap.set("n", "<leader>b", ":NvimTreeToggle<CR>", { desc = "Open Nvim-tree" }),
      on_attach = my_on_attach,
    })
  end,
}
