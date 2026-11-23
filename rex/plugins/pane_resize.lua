-- Resize panes with a key, unless Neovim is running in the pane, in which case
-- the key is sent through so Neovim can resize its own splits (smart-splits).
--
--   require("plugins.pane_resize").setup({ modifier = "alt+shift", amount = 3 })

local utils = require("core.utils")

local M = {}

M.defaults = {
    modifier = "alt+shift",
    amount = 3,
    keys = { h = "left", j = "down", k = "up", l = "right" },
}

M.options = M.defaults

local function nvim_running(ctx)
    local process = rex.block.call("com.superlogical.terminal", "process", {
        session_id = ctx.session_id,
        block_id = ctx.block_id,
    })
    if not process then
        return false
    end
    if process.foreground and process.foreground.name == "nvim" then
        return true
    end
    for _, ancestor in ipairs(process.ancestors or {}) do
        if ancestor.name == "nvim" then
            return true
        end
    end
    return false
end

function M.setup(opts)
    M.options = utils.merge(M.defaults, opts)

    for key, direction in pairs(M.options.keys) do
        local name = "resize_pane_" .. direction
        local chord = M.options.modifier .. "+" .. key
        rex.action({
            name = name,
            title = "Resize Pane " .. direction .. " (or send to Neovim)",
            repeats = true,
            run = function(ctx)
                if nvim_running(ctx) then
                    rex.client.queue("pane.send_key", { key = chord })
                else
                    rex.client.queue("pane.resize", { direction = direction, amount = M.options.amount })
                end
            end,
        })
        rex.bind(chord, name)
    end
end

return M
