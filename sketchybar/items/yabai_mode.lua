local colors = require("colors")
local settings = require("settings")

-- Yabai layout mode indicator
-- Shows: B (BSP), F (Float), S (Stack)
local mode_indicator = sbar.add("item", "yabai.mode", {
    position = "left",
    icon = {
        string = "?",
        color = colors.grey,
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Bold"],
            size = settings.font.size,
        },
        padding_left = 8,
        padding_right = 8,
    },
    label = { drawing = false },
    background = {
        color = colors.bg1,
        drawing = true,
    },
})

local update_running = false
local update_pending = false
local LAYOUT_QUERY = "yabai -m query --spaces --space 2>/dev/null | jq -r '.type // empty' 2>/dev/null"

local function update_mode()
    if update_running then
        update_pending = true
        return
    end

    update_running = true
    sbar.exec(LAYOUT_QUERY, function(layout)
        update_running = false

        if not layout then
            if update_pending then
                update_pending = false
                update_mode()
            end
            return
        end

        layout = tostring(layout):gsub("%s+", "")  -- Remove whitespace/newlines

        if layout == "" then
            if update_pending then
                update_pending = false
                update_mode()
            end
            return
        end

        local icon_str = "B"
        local icon_color = colors.green

        if layout == "float" then
            icon_str = "F"
            icon_color = colors.yellow
        elseif layout == "stack" then
            icon_str = "S"
            icon_color = colors.blue
        elseif layout == "bsp" then
            icon_str = "B"
            icon_color = colors.green
        end

        mode_indicator:set({
            icon = {
                string = icon_str,
                color = icon_color
            }
        })

        if update_pending then
            update_pending = false
            update_mode()
        end
    end)
end

mode_indicator:subscribe({"forced", "space_change", "system_woke"}, function()
    update_mode()
end)

-- Click to toggle layout
mode_indicator:subscribe("mouse.clicked", function(env)
    if env.BUTTON == "left" then
        -- Toggle between bsp and float
        sbar.exec("yabai -m query --spaces --space 2>/dev/null | jq -r '.type // empty' 2>/dev/null | grep -q '^bsp$' && yabai -m space --layout float || yabai -m space --layout bsp")
    else
        -- Right click: cycle bsp -> stack -> float -> bsp
        sbar.exec(LAYOUT_QUERY, function(layout)
            layout = tostring(layout):gsub("%s+", "")
            local next_layout = "bsp"
            if layout == "bsp" then
                next_layout = "stack"
            elseif layout == "stack" then
                next_layout = "float"
            end
            sbar.exec("yabai -m space --layout " .. next_layout)
        end)
    end
    -- Update after a short delay
    sbar.exec("sleep 0.2", function()
        update_mode()
    end)
end)

update_mode()
