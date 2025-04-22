local M = {}

function M.withExtraMod(keymap, mod)
    local keymapCopy = {}
    for k, v in pairs(keymap) do
        if k == 'mods' then
            keymapCopy[k] = v .. '|' .. mod
        else
            keymapCopy[k] = v
        end
    end
    return { keymap, keymapCopy }
end

function M.withExtraModBatch(mod, ...)
    local result = {}
    for _, keymap in ipairs({ ... }) do
        local pair = M.withExtraMod(keymap, mod)
        table.insert(result, pair[1])
        table.insert(result, pair[2])
    end
    return result
end

return M
