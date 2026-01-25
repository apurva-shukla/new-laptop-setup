local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local apple = sbar.add("item", "apple", {
    icon = {
        padding_left = settings.padding.icon_item.icon.padding_left,
        padding_right = settings.padding.icon_item.icon.padding_right,
        string = icons.apple,
        font = {
            family = settings.font_icon.text,
            style = settings.font_icon.style_map["Regular"],
            size = settings.font.size,
        },
    },
    label = { drawing = false },
    background = {
        color = colors.bg1,
        drawing = true,
    },
    click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

apple:subscribe({"mouse.clicked", "front_app_switched"}, function(env)
    -- Event handler for mouse clicks and app switches
end)
