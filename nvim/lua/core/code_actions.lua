local M = {}

local function go_test_selection(null_ls)
  local methods = null_ls.methods

  return {
    name = "go_test_selection",
    method = methods.CODE_ACTION,
    filetypes = { "go" },
    generator = {
      fn = function()
        local current_line = vim.fn.line(".")
        local func_line = vim.fn.search("^\\s*func\\s\\+Test\\w\\+\\s*(", "bnW")
        local line_text
        if func_line == 0 then
          line_text = vim.fn.getline(current_line)
        else
          line_text = vim.fn.getline(func_line)
        end

        local test_name = line_text:match("^%s*func%s+(Test%w+)%s*%(")
        if not test_name then
          test_name = "nearest test"
        end

        return {
          {
            title = "Run Go test: " .. test_name,
            action = function()
              local file = vim.api.nvim_buf_get_name(0)
              local cwd = file ~= "" and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p:h") or vim.fn.getcwd()

              if not test_name then
                vim.notify("No Go test found near cursor", vim.log.levels.WARN)
                return
              end

              vim.cmd("botright new")
              vim.fn.termopen({ "go", "test", "-run", "^" .. test_name .. "$" }, { cwd = cwd })
              vim.cmd("startinsert")
            end,
          },
        }
      end,
    },
  }
end

function M.get(null_ls)
  return {
    go_test_selection(null_ls),
  }
end

return M
