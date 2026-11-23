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

-- Returns the key plus a copy with ctrl added to its last step, so "ctrl+a>f" also works as
-- "ctrl+a>ctrl+f" without letting go of ctrl (like wezterm's helpers.withExtraMod).
function M.with_ctrl(key)
    local prefix, last = key:match("^(.*[>/])([^>/]+)$")
    if not prefix then
        prefix, last = "", key
    end
    if ("+" .. last):match("%+ctrl%+") then
        return { key }
    end
    return { key, prefix .. "ctrl+" .. last }
end

-- rex.bind for one key or a list of keys.
function M.bind(keys, action, args)
    for _, key in ipairs(type(keys) == "table" and keys or { keys }) do
        if args then
            rex.bind(key, action, args)
        else
            rex.bind(key, action)
        end
    end
end

return M
