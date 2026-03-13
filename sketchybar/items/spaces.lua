local colors = require("colors")
local settings = require("settings")
local log = require("helpers.log").new("spaces")

-- Number of spaces to display (max spaces shown in bar)
local SPACE_COUNT = 10

-- Track space items
local spaces = {}

-- Path to update script (handles both icon text and colors)
local CONFIG_DIR = os.getenv("HOME") .. "/.config/sketchybar"
local UPDATE_SCRIPT = CONFIG_DIR .. "/plugins/update_space_colors.sh"
local update_running = false
local update_pending = false
local pending_reason = "unknown"

-- Update space icons and colors via shell script
local function update_space_icons(reason)
    if update_running then
        update_pending = true
        pending_reason = reason or "unknown"
        return
    end

    update_running = true
    local started = os.clock()
    sbar.exec(UPDATE_SCRIPT, function()
        update_running = false
        local elapsed_ms = (os.clock() - started) * 1000
        if elapsed_ms > 200 then
            log.warn("space refresh (%s) took %.2fms", reason or "unknown", elapsed_ms)
        end
        if update_pending then
            local next_reason = pending_reason
            update_pending = false
            pending_reason = "unknown"
            update_space_icons(next_reason)
        end
    end)
end

-- Mouse click handler
local function mouse_click(env)
    if env.BUTTON == "right" then
        sbar.exec("yabai -m space --destroy " .. env.SID)
    else
        sbar.exec("yabai -m space --focus " .. env.SID)
    end
end

-- Space selection change handler (called automatically by associated_space)
local function space_selection(env)
    local selected = env.SELECTED == "true"
    sbar.set(env.NAME, {
        icon = { highlight = selected },
        label = { highlight = selected },
        background = { border_color = selected and colors.white or colors.bg2 }
    })
end

-- Create space items
local space_names = {}
for i = 1, SPACE_COUNT do
    local space = sbar.add("space", "space." .. i, {
        associated_space = i,
        icon = {
            string = tostring(i),
            color = colors.with_alpha(colors.white, 0.3),
            highlight_color = colors.white,
            font = {
                family = settings.font.numbers,
                style = settings.font.style_map["Bold"],
                size = settings.font.size,
            },
            padding_left = 8,
            padding_right = 8,
        },
        padding_left = 5,
        padding_right = 5,
        label = {
            string = "",
            color = colors.with_alpha(colors.white, 0.3),
            highlight_color = colors.white,
            font = "sketchybar-app-font:Regular:16.0",
            padding_left = 0,
            padding_right = 8,
            y_offset = -1,
            drawing = false,  -- Start hidden, show when apps exist
        },
        background = {
            color = colors.bg1,
            drawing = true,
        },
    })

    spaces[i] = space
    space_names[i] = space.name
    space:subscribe("space_change", space_selection)
    space:subscribe("mouse.clicked", mouse_click)
end

-- Bracket around all spaces
sbar.add("bracket", space_names, {
    background = { color = colors.bg1, border_color = colors.bg2 }
})

-- Space creator button removed (use yabai -m space --create manually)

-- Subscribe to events that should trigger icon updates
local space_watcher = sbar.add("item", "space.watcher", {
    drawing = false,
})

space_watcher:subscribe("space_change", function()
    update_space_icons("space_change")
end)

-- Custom event for window changes (requires yabai signals)
sbar.add("event", "windows_changed")
space_watcher:subscribe("windows_changed", function()
    update_space_icons("windows_changed")
end)

-- Initial update
update_space_icons("initial")
