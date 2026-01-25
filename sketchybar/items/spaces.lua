local colors = require("colors")
local settings = require("settings")
local icons = require("icons")
local app_icons = require("helpers.app_icons")

-- Number of spaces to display (matching yabairc)
local SPACE_COUNT = 6

-- Track space items
local spaces = {}

-- Query yabai for windows and update space labels with app icons
-- NOTE: This only updates labels (app icons), NOT highlight state
-- Highlight is handled automatically by associated_space + space_change event
local function update_space_icons()
    sbar.exec("yabai -m query --windows", function(windows_json)
        if not windows_json then return end

        local json_str = tostring(windows_json)
        if json_str == "" or json_str == "nil" then return end

        -- Group windows by space using pattern matching
        local windows_by_space = {}
        for i = 1, SPACE_COUNT do
            windows_by_space[i] = {}
        end

        -- Parse each window entry
        for app, space in string.gmatch(json_str, '"app"%s*:%s*"([^"]+)".-"space"%s*:%s*(%d+)') do
            local space_num = tonumber(space)
            if space_num and space_num >= 1 and space_num <= SPACE_COUNT then
                table.insert(windows_by_space[space_num], app)
            end
        end

        -- Update each space's label with app icons
        for i = 1, SPACE_COUNT do
            local apps = windows_by_space[i]

            if #apps > 0 then
                -- Build icon string from app names
                local icon_line = ""
                for _, app_name in ipairs(apps) do
                    local icon = app_icons[app_name] or app_icons["Default"] or ":default:"
                    icon_line = icon_line .. icon
                end

                spaces[i]:set({
                    label = {
                        string = icon_line,
                        drawing = true,
                    },
                })
            else
                -- No windows - hide label
                spaces[i]:set({
                    label = {
                        string = "",
                        drawing = false,
                    },
                })
            end
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
    update_space_icons()
end)

space_watcher:subscribe("front_app_switched", function()
    update_space_icons()
end)

-- Custom event for window changes (requires yabai signals)
sbar.add("event", "windows_changed")
space_watcher:subscribe("windows_changed", function()
    update_space_icons()
end)

-- Initial update
update_space_icons()
