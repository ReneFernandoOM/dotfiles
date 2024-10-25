local M = {}
function M.getGitRootDir()
  local root_dir
  for dir in vim.fs.parents(vim.api.nvim_buf_get_name(0)) do
    if vim.fn.isdirectory(dir .. "/.git") == 1 then
      root_dir = dir
      break
    end
  end

  if root_dir then
    return root_dir
  end
end

function M.OnLspAttach(client, bufnr)
  local telescopeBuiltin = require("telescope.builtin")
  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end
    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

  -- nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
  nmap("gd", function()
    telescopeBuiltin.lsp_definitions()
    vim.api.nvim_feedkeys("zz", "normal", false)
    -- vim.api.nvim_feedkeys("zz", "normal", false)
  end, "[G]oto [D]efinition")
  nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
  nmap("gI", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
  nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
  nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
  -- nmap('<leader>ws', require('telescope.builtin').lsp_workspace_symbols, '[W]orkspace [S]ymbols')

  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-s>", vim.lsp.buf.signature_help, "Signature Documentation")
end

return M
