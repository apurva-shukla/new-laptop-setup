local settings = require("settings")
local colors = require("colors")
local log = require("helpers.log").new("menus")

-- Create a menu trigger item
local menu_item = sbar.add("item", "menu_trigger", {
    drawing = true,
    updates = true,
    icon = {
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Bold"],
            size = 18.0,
        },
        padding_left = settings.padding.icon_item.icon.padding_left,
        padding_right = settings.padding.icon_item.icon.padding_right,
        string = "≡",
    },
    label = { drawing = false },
    background = {
        color = colors.bg1,
        drawing = true,
    },
})

-- Maximum number of menu items to display
local max_items = 15
local menu_items = {}

-- Create the menu items that will appear inline
for i = 1, max_items, 1 do
    local menu = sbar.add("item", "menu." .. i, {
        position = "left", -- Position them on the left of the bar
        drawing = false,   -- Hidden by default
        icon = { drawing = false },
        label = {
            font = {
                style = settings.font.style_map["Semibold"]
            },
            padding_left = settings.paddings,
            padding_right = settings.paddings,
        },
        click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s " .. i,
    })
    menu_items[i] = menu
end

-- Menu watcher to monitor app changes
local menu_watcher = sbar.add("item", {
    drawing = false,
    updates = false,
})

-- Menu state variable
local menu_visible = false
local menu_labels = {}
local update_running = false
local update_pending = false
local pending_reason = "unknown"

local function apply_menu_state()
    for i = 1, max_items do
        local label = menu_labels[i]
        if label and label ~= "" then
            menu_items[i]:set({
                drawing = menu_visible,
                width = menu_visible and "dynamic" or 0,
                label = {
                    string = label,
                    drawing = menu_visible,
                },
            })
        else
            menu_items[i]:set({
                drawing = false,
                width = 0,
                label = {
                    string = "",
                    drawing = false,
                },
            })
        end
    end
end

-- Function to update menu contents
local function update_menus(reason)
    if not menu_visible and reason ~= "toggle" then
        return
    end

    if update_running then
        update_pending = true
        pending_reason = reason
        return
    end

    update_running = true
    local started = os.clock()

    sbar.exec("$CONFIG_DIR/helpers/menus/bin/menus -l", function(menus)
        update_running = false

        local labels = {}
        local id = 1
        if menus then
            for menu in string.gmatch(menus, '[^\r\n]+') do
                if id > max_items then
                    break
                end
                labels[id] = menu
                id = id + 1
            end
        end

        menu_labels = labels
        apply_menu_state()

        local elapsed_ms = (os.clock() - started) * 1000
        if elapsed_ms > 200 then
            log.warn("menu refresh (%s) took %.2fms with %d items", reason, elapsed_ms, #labels)
        end

        if update_pending and menu_visible then
            local next_reason = pending_reason
            update_pending = false
            pending_reason = "unknown"
            update_menus(next_reason)
        end
    end)
end

-- Function to toggle the menu
local function toggle_menu()
    menu_visible = not menu_visible
    menu_watcher:set({ updates = menu_visible })

    if menu_visible then
        apply_menu_state()
        update_menus("toggle")
    else
        apply_menu_state()
    end
end

-- Click to toggle menu
menu_item:subscribe("mouse.clicked", function(env)
    toggle_menu()
end)

-- Subscribe to front app changes
menu_watcher:subscribe("front_app_switched", function()
    update_menus("front_app_switched")
end)

return menu_watcher
