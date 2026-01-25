local settings = require("settings")

local icons = {
    sf_symbols = {
        plus = "􀅼",
        loading = "􀖇",
        apple = "􀣺",
        gear = "􀍟",
        cpu = "􀫥",
        ram = "􀫦",
        clipboard = "􀉄",

        switch = {
            on = "􁏮",
            off = "􁏯",
        },
        volume = {
            _100 = "􀊩",
            _66 = "􀊧",
            _33 = "􀊥",
            _10 = "􀊡",
            _0 = "􀊣",
        },
        battery = {
            _100 = "􀛨",
            _75 = "􀺸",
            _50 = "􀺶",
            _25 = "􀛩",
            _0 = "􀛪",
            charging = "􀢋"
        },
        wifi = {
            upload = "􀄨",
            download = "􀄩",
            connected = "􀙇",
            disconnected = "􀙈",
            router = "􁓤",
        },
        media = {
            back = "􀊊",
            forward = "􀊌",
            play_pause = "􀊈",
        },
    },

    -- Alternative NerdFont icons
    nerdfont = {
        plus = "",
        loading = "",
        apple = "",
        gear = "",
        cpu = "\u{f4bc}",
        ram = "\u{efc5}",
        clipboard = "Missing Icon",

        switch = {
            on = "󱨥",
            off = "󱨦",
        },
        volume = {
            _100 = "",
            _66 = "",
            _33 = "",
            _10 = "",
            _0 = "",
        },
        battery = {
            _100 = "",
            _75 = "",
            _50 = "",
            _25 = "",
            _0 = "",
            charging = ""
        },
        wifi = {
            upload = "\u{f102}",
            download = "\u{f103}",
            connected = "󰖩",
            disconnected = "󰖪",
            router = "Missing Icon"
        },
        media = {
            back = "",
            forward = "",
            play_pause = "",
        },
    },
}

if not (settings.icons == "NerdFont") then
    return icons.sf_symbols
else
    return icons.nerdfont
end
