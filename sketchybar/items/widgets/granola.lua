local colors = require("colors")
local settings = require("settings")
local log = require("helpers.log").new("granola")

local granola = settings.granola or {}

if granola.enabled == false then
    return
end

local owner = granola.owner or "Granola"
local alias_scale = granola.scale or 1.0
local alias_update_freq = granola.update_freq or 5
local configured_candidates = granola.alias_candidates or { owner }

local function trim(value)
    if not value then
        return ""
    end

    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function push_unique(list, seen, value)
    local normalized = trim(value)
    if normalized == "" or seen[normalized] then
        return
    end

    seen[normalized] = true
    table.insert(list, normalized)
end

local function build_candidates(discovered_aliases)
    local candidates = {}
    local seen = {}

    for line in (discovered_aliases or ""):gmatch("[^\r\n]+") do
        push_unique(candidates, seen, line)
    end

    for _, alias_name in ipairs(configured_candidates) do
        push_unique(candidates, seen, alias_name)
    end

    return candidates
end

local function add_granola_alias(alias_name)
    local ok, alias_item = pcall(sbar.add, "alias", alias_name, {
        position = "right",
        padding_left = 0,
        padding_right = 0,
        alias = {
            scale = alias_scale,
            update_freq = alias_update_freq,
        },
        background = {
            color = colors.bg1,
            drawing = true,
        },
    })

    if not ok or not alias_item then
        return nil
    end

    sbar.add("bracket", "widgets.granola.bracket", { alias_item.name }, {
        background = { color = colors.bg1 }
    })

    sbar.add("item", "widgets.granola.padding", {
        position = "right",
        width = settings.group_paddings
    })

    return alias_item
end

sbar.exec("$CONFIG_DIR/helpers/menus/bin/menus -a '" .. owner .. "'", function(result)
    local candidates = build_candidates(result)

    for _, alias_name in ipairs(candidates) do
        local alias_item = add_granola_alias(alias_name)
        if alias_item then
            log.info("using Granola alias %s", alias_name)
            return
        end
    end

    log.warn("unable to bind Granola alias for owner %s", owner)
end)
