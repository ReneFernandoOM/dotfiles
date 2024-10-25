return {
  "ThePrimeagen/harpoon",
  config = function()
    local harpoon = require("harpoon")
    local harpoon_mark = require("harpoon.mark")
    local harpoon_ui = require("harpoon.ui")
    harpoon.setup({})
    vim.keymap.set("n", "<leader>m", harpoon_mark.add_file, { desc = "Add a file to harpoon list" })
    vim.keymap.set("n", "<leader>h", harpoon_ui.toggle_quick_menu, { desc = "Toggle Harpoon UI menu" })
    -- quick navigation to harpoon files
    vim.keymap.set("n", "<C-y>", function()
      harpoon_ui.nav_file(1)
      vim.api.nvim_feedkeys("zz", "normal", false)
    end)
    vim.keymap.set("n", "<C-n>", function()
      harpoon_ui.nav_file(2)
      vim.api.nvim_feedkeys("zz", "normal", false)
    end)
    vim.keymap.set("n", "<C-m>", function()
      harpoon_ui.nav_file(3)
      vim.api.nvim_feedkeys("zz", "normal", false)
    end)
    vim.keymap.set("n", "<C-q>", function()
      harpoon_ui.nav_file(4)
      vim.api.nvim_feedkeys("zz", "normal", false)
    end)
  end,
}
