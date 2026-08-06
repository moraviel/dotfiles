-- Hyprland config — LXKA-4JSYDX3 (work laptop, NVIDIA, shared desk).
-- Monitor layout is deliberately loose: this laptop docks at different desks
-- with 2-3 external monitors depending on the office. Run `hyprctl monitors`
-- after docking to get real connector names, then uncomment/adjust below.

local mod = "SUPER"
local terminal = "kitty"
local noctalia = "noctalia msg "

-- NVIDIA + Wayland — see LXKA-4JSYDX3/hooks/nvidia-open.sh for the matching
-- mkinitcpio/kernel-cmdline side of this.
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

------------------
---- MONITORS ----
------------------

-- Built-in panel, undocked default.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 1 })

-- Uncomment and rename connectors to match `hyprctl monitors` at each desk.
-- hl.monitor({ output = "DP-1", mode = "preferred", position = "1920x0", scale = 1 })
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "3840x0", scale = 1 })

------------------
---- AUTOSTART ----
------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 12,
        border_size = 2,
        col = {
            active_border = "rgb(cba6f7)",
            inactive_border = "rgb(45475a)",
        },
        layout = "dwindle",
    },

    decoration = {
        rounding = 8,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
})

------------------------------
---- NOCTALIA LAYER RULES ----
------------------------------

hl.window_rule({
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size = { 1080, 920 },
})

hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
    },
    no_anim = true,
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})

---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout = "us",
        follow_mouse = 1,

        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
        },
    },
})

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

for i = 1, 5 do
    hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%s).png'))
