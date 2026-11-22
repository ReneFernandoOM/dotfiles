-- Leader ctrl+a
rex.bind("ctrl+a>ctrl+a", "pane.send_key", { key = "ctrl+a" })
rex.bind("ctrl+a>l", "client.config.reload")
rex.bind("ctrl+a>z", "pane.zoom")
rex.bind("ctrl+a>c", "client.tab.new")
rex.bind("ctrl+a>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+a>-", "pane.split", { direction = "down" })
rex.bind("ctrl+a>ctrl+w", "client.tab.close")
rex.bind("ctrl+a>w", "pane.close")

for i = 1, 9 do
    rex.bind("ctrl+a>" .. i, "client.tab.goto", { index = i })
end

rex.bind("ctrl+a>enter", "pane.copy_mode.enter")
-- Pane navigation and resizing; Neovim gets the keys itself (smart-splits, rex-navigator)
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

for key, direction in pairs({ h = "left", j = "down", k = "up", l = "right" }) do
    local name = "resize_pane_" .. direction
    rex.action({
        name = name,
        title = "Resize Pane " .. direction .. " (or send to Neovim)",
        repeats = true,
        run = function(ctx)
            if nvim_running(ctx) then
                rex.client.queue("pane.send_key", { key = "alt+shift+" .. key })
            else
                rex.client.queue("pane.resize", { direction = direction, amount = 3 })
            end
        end,
    })
    rex.bind("alt+shift+" .. key, name)
end

local nvim_data = (os.getenv("XDG_DATA_HOME") or (os.getenv("HOME") .. "/.local/share")) .. "/nvim"
local ok, err = pcall(function()
    dofile(nvim_data .. "/lazy/rex-navigator.nvim/rex/navigator.lua").setup({ wrap = false })
end)
if not ok then
    rex.log("warn", "rex-navigator not loaded: " .. tostring(err))
end
