local colors = require("colors")
local settings = require("settings")

local LOCATION = "Brooklyn,NY,USA"

-- Weather icons mapping (NerdFont)
local weather_icons = {
    ["Clear"] = "",
    ["Sunny"] = "",
    ["Partly cloudy"] = "",
    ["Cloudy"] = "",
    ["Overcast"] = "",
    ["Mist"] = "",
    ["Fog"] = "",
    ["Light rain"] = "",
    ["Rain"] = "",
    ["Heavy rain"] = "",
    ["Light snow"] = "",
    ["Snow"] = "",
    ["Heavy snow"] = "",
    ["Thunderstorm"] = "",
    ["default"] = "",
}

local function get_weather_icon(condition)
    for key, icon in pairs(weather_icons) do
        if condition:lower():find(key:lower()) then
            return icon
        end
    end
    return weather_icons["default"]
end

local weather = sbar.add("item", "widgets.weather", {
    position = "right",
    icon = {
        string = "",
        font = {
            family = settings.font_icon.text,
            style = settings.font_icon.style_map["Bold"],
            size = settings.icon_size,
        },
        color = colors.blue,
        padding_left = settings.padding.icon_label_item.icon.padding_left,
        padding_right = settings.padding.icon_label_item.icon.padding_right,
    },
    label = {
        string = "...",
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Bold"],
            size = settings.label_size,
        },
        color = colors.white,
        padding_right = settings.padding.icon_label_item.label.padding_right,
    },
    update_freq = 1800, -- Update every 30 minutes
})

-- Background bracket around weather
sbar.add("bracket", "widgets.weather.bracket", { weather.name }, {
    background = { color = colors.bg1 }
})

-- Padding after weather
sbar.add("item", "widgets.weather.padding", {
    position = "right",
    width = settings.group_paddings
})

local weather_running = false

local function update_weather()
    if weather_running then return end
    weather_running = true

    -- Using wttr.in for weather data (free, no API key needed)
    sbar.exec("curl -s --connect-timeout 5 --max-time 10 'wttr.in/" .. LOCATION .. "?format=%t+%C' 2>/dev/null", function(result)
        weather_running = false
        if result and result ~= "" then
            -- Parse temperature and condition
            local temp = result:match("([%+%-]?%d+°[CF])")
            local condition = result:match("°[CF]%s+(.+)") or ""
            condition = condition:gsub("^%s*(.-)%s*$", "%1") -- trim

            local icon = get_weather_icon(condition)

            if temp then
                weather:set({
                    icon = { string = icon },
                    label = { string = temp },
                })
            end
        end
    end)
end

weather:subscribe({"routine", "system_woke"}, update_weather)

-- Click to open weather website
weather:subscribe("mouse.clicked", function()
    sbar.exec("open 'https://wttr.in/" .. LOCATION .. "'")
end)

-- Run on load
update_weather()
