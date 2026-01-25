return {
    -- Icon set: "sf_symbols" or "NerdFont"
    -- sf_symbols requires SF Pro font, NerdFont requires Hack Nerd Font
    icons = "NerdFont",

    font = {
        text = "SF Pro",
        numbers = "SF Pro",
        size = 13.0,
        style_map = {
            ["Regular"] = "Regular",
            ["Semibold"] = "Semibold",
            ["Bold"] = "Bold",
            ["Heavy"] = "Heavy",
            ["Black"] = "Black",
        },
    },
    font_icon = {
        text = "Hack Nerd Font",
        numbers = "Hack Nerd Font",
        size = 13.0,
        style_map = {
            ["Regular"] = "Regular",
            ["Semibold"] = "Semibold",
            ["Bold"] = "Bold",
            ["Heavy"] = "Heavy",
            ["Black"] = "Black",
        },
    },
    height = 24,
    paddings = 8,
    group_paddings = 5,

    -- Standard sizes for consistency
    icon_size = 13.0,
    label_size = 13.0,
    padding = {
        icon_item = {
            icon = {
                padding_left = 12,
                padding_right = 12,
            },
        },
        icon_label_item = {
            icon = {
                padding_left = 8,
                padding_right = 0,
            },
            label = {
                padding_left = 2,
                padding_right = 8,
            }
        }
    }
}
