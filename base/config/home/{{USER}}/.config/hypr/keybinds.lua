local mod = "SUPER"
local terminal = "kitty"
local noctalia = "noctalia msg "

---------------------
---- KEYBINDINGS ----
---------------------

hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + D", hl.dsp.exec_cmd(noctalia .. "panel-toggle launcher"))
hl.bind(mod .. " + S", hl.dsp.exec_cmd(noctalia .. "panel-toggle control-center"))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + E", hl.dsp.exit())
hl.bind(mod .. " + L", hl.dsp.exec_cmd(noctalia .. "session lock"))

hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }))

for i = 1, 9 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + SHIFT + G", hl.dsp.focus({ workspace = "name:gaming" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

hl.bind("Print", hl.dsp.exec_cmd("~/.local/bin/screenshot"))

----------------------------
---- CUSTOM KEYBINDINGS ----
----------------------------
hl.bind(mod .. " + SHIFT + up", hl.dsp.window.move({direction = "up" }))
hl.bind(mod .. " + SHIFT + down", hl.dsp.window.move({direction = "down" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({direction = "right" }))
hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({direction = "left" }))

hl.bind(mod .. "+ CTRL + right", hl.dsp.focus({ workspace = "+1"}))
hl.bind(mod .. "+ CTRL + left", hl.dsp.focus({ workspace = "-1"}))

--- XF86 Binds
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("flatpak run io.github.Qalculate"))
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))
