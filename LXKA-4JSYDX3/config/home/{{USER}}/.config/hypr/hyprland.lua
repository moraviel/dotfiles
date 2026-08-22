-- Hyprland config — LXKA-4JSYDX3 (work laptop, NVIDIA, shared desk).
-- Monitor layout is deliberately loose: this laptop docks at different desks
-- with 2-3 external monitors depending on the office.
-- Use Monique for setting Monitors up.

local mod = "SUPER"
local terminal = "kitty"
local noctalia = "noctalia msg "

-- NVIDIA + Wayland — see LXKA-4JSYDX3/hooks/nvidia-open.sh for the matching
-- mkinitcpio/kernel-cmdline side of this.
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- env for ssh-agent
hl.env("SSH_AUTH_SOCK", "/run/user/1000/ssh-agent.socket")

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
    hl.dsp.exec_cmd("wl-paste --type text --watch cliphist store &")
    hl.dsp.exec_cmd("wl-paste --type image --watch cliphist store &")
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
        layout = "master",
    },

    decoration = {
        rounding = 8,
    }, 

    misc = {
        disable_hyprland_logo = false,
        disable_splash_rendering = true,
    },
})

------------------------------
---- NOCTALIA LAYER RULES ----
------------------------------

hl.window_rule({
    match = { class = "dev.noctalia.Noctalia" },
    float = true,
    size = "1080 920",
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
        kb_layout = "us, de, ru",
        kb_options = "grp:win_space_toggle",
        follow_mouse = 1,
        resolve_binds_by_sym = true,

        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
        },
    },
})

-- Load configuration modules
require("keybinds")
require("monitors")
