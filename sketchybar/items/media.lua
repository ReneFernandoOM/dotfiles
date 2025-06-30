local colors = require("config.colors")
local settings = require("config.settings")

local whitelist = { ["Spotify"] = true, ["Psst"] = true }

local media_playback = sbar.add("item", {
  position = "right",
  icon = {
    string = "teestt",
    color = colors.label,
    padding_left = 8,
  },
  label = {
    max_chars = 50,
    padding_right = 8,
  },
  popup = {
    horizontal = true,
    align = "center",
    y_offset = 2,
  },
  padding_right = 8,
})

sbar.add("item", {
  position = "popup." .. media_playback.name,
  padding_left = 6,
  padding_right = 6,
  icon = { string = settings.icons.nerdfont.media.back },
  label = { drawing = false },
  background = { drawing = false },
  click_script = "nowplaying-cli previous",
})

sbar.add("item", {
  position = "popup." .. media_playback.name,
  padding_left = 6,
  padding_right = 6,
  icon = { string = settings.icons.nerdfont.media.play_pause },
  label = { drawing = false },
  background = { drawing = false },
  click_script = "nowplaying-cli togglePlayPause",
})

sbar.add("item", {
  position = "popup." .. media_playback.name,
  padding_left = 6,
  padding_right = 6,
  icon = { string = settings.icons.nerdfont.media.forward },
  label = { drawing = false },
  background = { drawing = false },
  click_script = "nowplaying-cli next",
})

media_playback:subscribe("media_change", function(env)
  print(env)
  if whitelist[env.INFO.app] then
    local is_playing = (env.INFO.state == "playing")
    media_playback:set {
      drawing = is_playing,
      label = {
        string = env.INFO.artist .. " - " .. env.INFO.title,
        padding_left = is_playing and 8 or 0,
      },
    }
  end
end)
