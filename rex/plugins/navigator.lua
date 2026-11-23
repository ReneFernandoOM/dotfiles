-- Seamless pane navigation between Rex and Neovim, provided by rex-navigator.nvim.
-- The Rex side ships inside the Neovim plugin, so load it from lazy.nvim's directory.
--
--   require("plugins.navigator").setup({ wrap = false })

local M = {}

local nvim_data = (os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")) .. "/nvim"

M.path = nvim_data .. "/lazy/rex-navigator.nvim/rex/navigator.lua"

function M.setup(opts)
    local ok, err = pcall(function()
        dofile(M.path).setup(opts)
    end)
    if not ok then
        rex.log("warn", "rex-navigator not loaded: " .. tostring(err))
    end
end

return M
