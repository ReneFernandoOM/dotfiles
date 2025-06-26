return {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvimtools/none-ls-extras.nvim" },
  event = { "LspAttach" },
  config = function()
    local null_ls = require("null-ls")

    local formatting = null_ls.builtins.formatting

    null_ls.setup({
      debug = true,
      sources = {
        -- Typescript
        formatting.prettierd.with({
          prefer_local = "node_modules/.bin",
        }),
        require("none-ls.diagnostics.eslint_d"),
        require("none-ls.code_actions.eslint_d"),
        -- Python
        require("none-ls.formatting.ruff"),
        require("none-ls.diagnostics.ruff"),
        -- Lua
        formatting.stylua,
      },
    })
  end,
}
