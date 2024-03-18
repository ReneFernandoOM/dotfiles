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

return M
