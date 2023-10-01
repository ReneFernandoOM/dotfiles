return {
  -- Keeps the context of the function at the top
  'nvim-treesitter/nvim-treesitter-context',
  config = function()
    local treesitter_context = require 'treesitter-context'
    treesitter_context.setup {
      max_lines = 1,
    }
  end,
}
