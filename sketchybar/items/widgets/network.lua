local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Detect primary network interface
local function get_primary_interface()
    local handle = io.popen("route -n get default 2>/dev/null | grep interface | awk '{print $2}'")
    local interface = handle:read("*a"):gsub("%s+", "")
    handle:close()
    return interface ~= "" and interface or "en0"
end

local interface = get_primary_interface()

-- Execute network_load event provider
sbar.exec("killall network_load >/dev/null; $CONFIG_DIR/helpers/event_providers/network_load/bin/network_load " .. interface .. " network_update 2.0")

local rate_font = {
    family = settings.font.numbers,
    style = settings.font.style_map["Bold"],
    size = 10.0,
}

local icon_font = {
    family = settings.font_icon.text,
    style = settings.font_icon.style_map["Bold"],
    size = 10.0,
}

-- Upload item (top line, stacked)
local network_up = sbar.add("item", "widgets.network.up", {
    position = "right",
    width = 0,
    padding_left = 0,
    padding_right = 0,
    icon = {
        string = icons.wifi.upload,
        font = icon_font,
        color = colors.red,
        padding_left = 0,
        padding_right = 2,
        y_offset = 1,
    },
    label = {
        font = rate_font,
        padding_left = 0,
        padding_right = 6,
        align = "left",
        string = "???",
        color = colors.red,
        y_offset = 0,
    },
    y_offset = 5,
    background = { drawing = false },
})

-- Download item (bottom line, stacked)
local network_down = sbar.add("item", "widgets.network.down", {
    position = "right",
    padding_left = 0,
    padding_right = 0,
    icon = {
        string = icons.wifi.download,
        font = icon_font,
        color = colors.green,
        padding_left = 0,
        padding_right = 2,
        y_offset = 1,
    },
    label = {
        font = rate_font,
        padding_left = 0,
        padding_right = 6,
        align = "left",
        string = "???",
        color = colors.green,
        y_offset = 0,
    },
    y_offset = -5,
    background = { drawing = false },
})

-- Padding item
local network = sbar.add("item", "widgets.network.padding", {
    position = "right",
    label = { drawing = false },
})

network_up:subscribe("network_update", function(env)
    local up = env.upload or "??"
    if up:match(" Bps$") then
        local value = tonumber(up:match("^%d+"))
        if value then
            up = string.format("%dKB/s", math.floor(value / 1000))
        end
    end
    up = up:gsub("Bps$", "B/s"):gsub("ps$", "/s")

    local up_color = (env.upload == "000 Bps" or up == "0KB/s") and colors.grey or colors.red
    network_up:set({
        icon = { color = up_color },
        label = { string = up, color = up_color }
    })
end)

network_down:subscribe("network_update", function(env)
    local down = env.download or "??"
    if down:match(" Bps$") then
        local value = tonumber(down:match("^%d+"))
        if value then
            down = string.format("%dKB/s", math.floor(value / 1000))
        end
    end
    down = down:gsub("Bps$", "B/s"):gsub("ps$", "/s")

    local down_color = (env.download == "000 Bps" or down == "0KB/s") and colors.grey or colors.green
    network_down:set({
        icon = { color = down_color },
        label = { string = down, color = down_color }
    })
end)

network_up:subscribe("mouse.clicked", function(env)
    sbar.exec("open -a 'Activity Monitor'")
end)

network_down:subscribe("mouse.clicked", function(env)
    sbar.exec("open -a 'Activity Monitor'")
end)

network:subscribe("mouse.clicked", function(env)
    sbar.exec("open -a 'Activity Monitor'")
end)

-- Background bracket around all network items
sbar.add("bracket", "widgets.network.bracket", {
    network.name,
    network_up.name,
    network_down.name
}, {
    background = { color = colors.bg1 }
})

-- Padding after network widget
sbar.add("item", "widgets.network.padding2", {
    position = "right",
    width = settings.group_paddings
})
