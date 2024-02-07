return {
  "ThePrimeagen/git-worktree.nvim",
  config = function()
    local Worktree = require("git-worktree")
    local Job = require("plenary.job")
    local function getParentPath(str)
      return str:match("(.*[/\\])")
    end

    Worktree.setup({})
    Worktree.on_tree_change(function(op, metadata)
      if op == Worktree.Operations.Switch or op == Worktree.Operations.Create then
        Job:new({
          command = "../worktree_switcher.sh",
          args = { metadata.path },
          -- cwd = parentPath,
          on_exit = function(j, return_val)
            print(return_val)
            print(vim.inspect(j:result()))
          end,
        }):sync()

        print(vim.inspect(metadata))
      end
    end)
  end,
}
