local function detect_json(lines)
  if not lines or #lines == 0 then
    return false
  end

  local text = table.concat(lines, "\n")
  local trimmed = text:match("^%s*(.-)%s*$")
  if trimmed == "" then
    return false
  end

  return pcall(vim.json.decode, trimmed)
end

local function format_or_wait(bufnr)
  vim.defer_fn(function()
    vim.api.nvim_create_autocmd({ "LspAttach" }, {
      buffer = bufnr,
      once = true,
      callback = function(args)
        if args.buf ~= bufnr then
          return
        end
        pcall(vim.lsp.buf.format, { async = false })
      end,
    })
  end, 50)
end

vim.api.nvim_create_user_command("PasteFormat", function(opts)
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local ft = vim.bo.filetype
  if ft == "" then
    ft = opts.args
  end

  if ft == "" then
    if detect_json(lines) then
      ft = "json"
    end
  end

  if ft == "" then
    vim.notify("PasteFormat: could not detect filetype (try :PasteFormat json)", vim.log.levels.WARN)
    return
  end

  vim.cmd("setfiletype " .. ft)
  format_or_wait(vim.api.nvim_get_current_buf())
end, { nargs = "?" })
