return {
  'jose-elias-alvarez/null-ls.nvim',
  event = { 'LspAttach' },
  config = function()
    local null_ls = require 'null-ls'
    local code_actions = null_ls.builtins.code_actions
    local diagnostics = null_ls.builtins.diagnostics
    local formatting = null_ls.builtins.formatting

    null_ls.setup {
      sources = {
        -- Typescript
        formatting.prettier.with {
          prefer_local = 'node_modules/.bin',
        },
        diagnostics.eslint_d.with {
          prefer_local = 'node_modules/.bin',
        },
        code_actions.eslint_d.with {
          prefer_local = 'node_modules/.bin',
        },
        -- Python
        formatting.black,
        -- Lua
        formatting.stylua,
      },
    }
  end,
}
