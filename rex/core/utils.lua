local M = {}

-- Deep-merges overrides into a copy of defaults, like vim.tbl_deep_extend("force", ...).
function M.merge(defaults, overrides)
    local result = {}
    for k, v in pairs(defaults) do
        result[k] = v
    end
    for k, v in pairs(overrides or {}) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = M.merge(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

function M.trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

return M
