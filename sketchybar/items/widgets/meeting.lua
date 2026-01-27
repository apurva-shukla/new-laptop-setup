local colors = require("colors")
local settings = require("settings")

local meeting = sbar.add("item", "widgets.meeting", {
    position = "right",
    icon = {
        string = "\u{f133}",  -- NerdFont calendar icon
        font = {
            family = settings.font_icon.text,
            style = settings.font_icon.style_map["Bold"],
            size = settings.icon_size,
        },
        color = colors.gmail_red,
        padding_left = settings.padding.icon_label_item.icon.padding_left,
        padding_right = settings.padding.icon_label_item.icon.padding_right,
    },
    label = {
        string = "No meetings",
        font = {
            family = settings.font.text,
            style = settings.font.style_map["Regular"],
            size = settings.font.size,
        },
        color = colors.text,
        padding_right = settings.padding.icon_label_item.label.padding_right,
    },
    update_freq = 60,
})

-- Background bracket around meeting
sbar.add("bracket", "widgets.meeting.bracket", { meeting.name }, {
    background = { color = colors.bg1 }
})

-- Padding after meeting
sbar.add("item", "widgets.meeting.padding", {
    position = "right",
    width = settings.group_paddings
})

local function get_relative_time(minutes)
    if minutes < 1 then
        return "now"
    elseif minutes < 60 then
        return "in " .. minutes .. "m"
    elseif minutes < 1440 then
        local hours = math.floor(minutes / 60)
        return "in " .. hours .. "h"
    else
        local days = math.floor(minutes / 1440)
        return "in " .. days .. "d"
    end
end

local function extract_names_from_title(title)
    -- Title format: "Apurva and Maxime Champoux" or similar
    local names = {}

    -- Split by " and " (the word, not individual chars)
    local parts = {}
    local pattern = "(.-) and "
    local last_end = 1
    local s, e, cap = title:find(pattern, 1)

    while s do
        if cap and cap ~= "" then
            table.insert(parts, cap)
        end
        last_end = e + 1
        s, e, cap = title:find(pattern, last_end)
    end

    -- Add the remaining part after last " and "
    local remaining = title:sub(last_end)
    if remaining and remaining ~= "" then
        table.insert(parts, remaining)
    end

    -- If no " and " found, the whole title is one part
    if #parts == 0 then
        table.insert(parts, title)
    end

    -- Extract first name from each part
    for _, part in ipairs(parts) do
        part = part:gsub("^%s*", ""):gsub("%s*$", "")
        local first_name = part:match("^(%S+)")
        if first_name and #first_name > 1 then
            table.insert(names, first_name)
        end
    end

    if #names >= 2 then
        return names[1] .. " & " .. names[2]
    elseif #names == 1 then
        return names[1]
    end
    return nil
end

local function update_meeting()
    -- Get title and datetime separately for cleaner parsing
    sbar.exec([[icalBuddy -n -nc -nrd -li 1 -tf '%H:%M' -df '%Y-%m-%d' -iep "title,datetime" -b "" -ps "|||" eventsFrom:now to:'now+48h' 2>/dev/null | head -1]], function(result)
        if result == "" or result == nil then
            meeting:set({ drawing = false })
            return
        end

        -- Clean up result
        result = result:gsub("\n", "")

        -- Extract title (everything before the date)
        local title = result:match("^(.-)%d%d%d%d%-%d%d%-%d%d") or result
        title = title:gsub("^%s*", ""):gsub("%s*$", ""):gsub("|+$", ""):gsub("|+", " ")

        -- Extract date and time
        local event_date = result:match("(%d%d%d%d%-%d%d%-%d%d)")
        local event_time = result:match("at (%d+:%d+)") or result:match("(%d+:%d+)")

        if title == "" or not event_date or not event_time then
            meeting:set({ drawing = false })
            return
        end

        -- Get current time
        sbar.exec("date '+%Y-%m-%d %H:%M'", function(now_str)
            local now_date = now_str:match("(%d%d%d%d%-%d%d%-%d%d)")
            local now_time = now_str:match("(%d+:%d+)")

            if now_date and now_time then
                -- Calculate minutes difference
                local now_h, now_m = now_time:match("(%d+):(%d+)")
                local evt_h, evt_m = event_time:match("(%d+):(%d+)")

                local now_mins = tonumber(now_h) * 60 + tonumber(now_m)
                local evt_mins = tonumber(evt_h) * 60 + tonumber(evt_m)

                -- Add days difference
                local day_diff = 0
                if event_date ~= now_date then
                    local now_d = tonumber(now_date:match("%d%d$"))
                    local evt_d = tonumber(event_date:match("%d%d$"))
                    day_diff = evt_d - now_d
                    if day_diff < 0 then day_diff = day_diff + 30 end
                end

                local diff_mins = (evt_mins - now_mins) + (day_diff * 1440)
                if diff_mins < 0 then diff_mins = 0 end

                local relative = get_relative_time(diff_mins)

                local label = title .. " (" .. relative .. ")"

                -- Color based on urgency
                local icon_color = colors.gmail_red
                if diff_mins <= 5 then
                    icon_color = colors.red
                elseif diff_mins <= 15 then
                    icon_color = colors.orange
                end

                meeting:set({
                    drawing = true,
                    label = { string = label },
                    icon = { color = icon_color },
                })
            end
        end)
    end)
end

meeting:subscribe({"routine", "system_woke"}, update_meeting)

-- Click to open Calendar app
meeting:subscribe("mouse.clicked", function()
    sbar.exec("open -a Calendar")
end)

-- Run on load
update_meeting()
