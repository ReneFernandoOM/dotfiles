-- Started by tab_find after it switches tabs. When the picker closes, the app focuses the pane
-- at the previously focused pane's position in the newly shown tab, which also ends any zoom.
-- This puts the tab's own focused (and zoomed) pane back as soon as that happens.
--
--   rex do -s <session_id> --for 1s restore.lua --args '{"block_id": "...", "zoom": true}'

local block_id = rex.args.block_id
local zoom = rex.args.zoom == true

local function window_of(view)
    for _, window in ipairs(view.windows or {}) do
        for _, layer in ipairs(window.layers or {}) do
            for _, block in ipairs(layer.blocks or {}) do
                if block.block_id == block_id then
                    return window
                end
            end
        end
    end
end

local function restore()
    local view = rex.session.view({})
    local window = view and window_of(view)
    if not window then
        rex.stop()
    end
    if window.focused_block_id == block_id and (not zoom or window.zoomed_block_id == block_id) then
        return
    end
    if zoom then
        rex.session.zoom_block({ block_id = block_id, zoom = true })
    else
        rex.session.focus_block({ block_id = block_id })
    end
end

restore()
rex.on("session_view_changed", restore)
