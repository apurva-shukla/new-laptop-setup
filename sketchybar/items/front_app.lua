local settings = require("settings")
local colors = require("colors")

local front_app = sbar.add("item", {
  icon = {
    drawing = false
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Regular"],
      size = settings.font.size,
    },
    color = colors.text,
  }
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({
    label = {
      string = env.INFO
    }
  })

  -- Or equivalently:
  -- sbar.set(env.NAME, {
  --   label = {
  --     string = env.INFO
  --   }
  -- })
end)
