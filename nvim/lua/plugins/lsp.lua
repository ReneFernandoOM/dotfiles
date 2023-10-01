local on_attach = function(client, bufnr)
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  -- nmap('<leader>ws', require('telescope.builtin').lsp_workspace_symbols, '[W]orkspace [S]ymbols')

  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
end

return {
  -- LSP Configuration & Plugins
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs to stdpath for neovim
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',

    -- Useful status updates for LSP
    { 'j-hui/fidget.nvim', opts = {} },

    -- Additional lua configuration, makes nvim stuff amazing!
    'folke/neodev.nvim',
    'ray-x/lsp_signature.nvim',
  },
  config = function()
    -- Important to load Mason first
    require('mason').setup()

    -- Setum neovim lua config
    require('neodev').setup()

    -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    -- Should be loaded after mason
    -- Ensure the servers above are installed
    local mason_lspconfig = require 'mason-lspconfig'

    local servers = {
      -- clangd = {},
      -- gopls = {},
      -- pyright = {},
      -- rust_analyzer = {},
      -- tsserver = {},

      lua_ls = {
        Lua = {
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    }

    mason_lspconfig.setup {
      ensure_installed = vim.tbl_keys(servers),
    }

    mason_lspconfig.setup_handlers {
      function(server_name)
        require('lspconfig')[server_name].setup {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = servers[server_name],
        }
      end,
    }
    -- Diagnostic message setup
    vim.diagnostic.config {
      -- Keep virtual text simple to avoid clutter
      virtual_text = {
        signs = true,
        severity_sort = true,
      },
      -- Use a custom format for the message in line diagnostics (E)
      float = {
        signs = true,
        severity_sort = true,
        format = function(diagnostic)
          return string.format('%s [%s] (%s)', diagnostic.message, diagnostic.code, diagnostic.source)
        end,
        suffix = '',
      },
    }
    -- Signature help
    require('lsp_signature').setup {
      bind = true,
      hint_enable = false,
      handler_opts = {
        border = 'rounded',
      },
    }

    -- Autoformat setup --
    -- Switch for controlling whether you want autoformatting.
    --  Use :LspFormatToggle to toggle autoformatting on or off
    local format_is_enabled = true
    vim.api.nvim_create_user_command('LspFormatToggle', function()
      format_is_enabled = not format_is_enabled
    end, {})

    -- Create an augroup that is used for managing our formatting autocmds.
    --      We need one augroup per client to make sure that multiple clients
    --      can attach to the same buffer without interfering with each other.
    local _augroups = {}
    local get_formatting_augroup = function(client)
      if not _augroups[client.id] then
        local group_name = 'lsp-attach-' .. client.name
        local id = vim.api.nvim_create_augroup(group_name, { clear = true })
        _augroups[client.id] = id
      end

      return _augroups[client.id]
    end

    -- Setup for autoformatting
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('lsp-attach-main', { clear = true }),
      -- This is where we attach the autoformatting for reasonable clients
      callback = function(args)
        local client_id = args.data.client_id
        local client = vim.lsp.get_client_by_id(client_id)
        local bufnr = args.buf
        local buf_ft = vim.bo.filetype

        if client == nil or bufnr == nil then
          return
        end

        -- Sets up an formatting AutoCommand
        vim.api.nvim_create_autocmd('BufWritePre', {
          group = get_formatting_augroup(client),
          buffer = bufnr,
          callback = function()
            -- Only attach to clients that support document formatting
            if not client.server_capabilities.documentFormattingProvider then
              return
            end

            -- Tsserver usually works poorly.
            if client.name == 'tsserver' then
              return
            end
            -- From the format_is_enabled variable defined above
            if not format_is_enabled then
              return
            end

            vim.lsp.buf.format {
              async = false,
              filter = function(c)
                return c.id == client.id
              end,
            }

            -- Re-enable diagnostics, following this: idk if I need it
            -- https://www.reddit.com/r/neovim/comments/15dfx4g/help_lsp_diagnostics_are_not_being_displayed/?utm_source=share&utm_medium=web2x&context=3
            -- vim.diagnostic.enable(bufnr)
          end,
        })
      end,
    })
  end,
}
