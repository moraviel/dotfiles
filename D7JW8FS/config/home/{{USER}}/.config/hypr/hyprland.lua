-- Hyprland config — D7JW8FS (personal desktop, no dedicated GPU, 2 fixed monitors).
-- Connector names below are placeholders — run `hyprctl monitors` once and
-- adjust "DP-1"/"DP-2" to match your actual setup.

local mod = "SUPER"
local terminal = "kitty"
local noctalia = "noctalia msg "


-- env for ssh-agent
hl.env("SSH_AUTH_SOCK", "/run/user/1000/ssh-agent.socket")

------------------
---- MONITORS ----
------------------

--hl.monitor({ output = "DP-1", mode = "preferred", position = "0x0", scale = 1 })
--hl.monitor({ output = "DP-2", mode = "preferred", position = "1920x0", scale = 1 })

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

---------------
---- RULES ----
---------------

hl.workspace_rule({
    workspace = "name:gaming"
    layout = "monocle"
})

hl.window_rule({
    match = { class = "steam_app.*" },
    content = "game",
})

hl.window_rule({
    match = { class = "game" },
    idle_inhibit = "focus",
    workspace = "gaming"
    fullscreen = true,
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

-- Load configuration modules | uncomment monitors-requirement after adding config using monique
require("keybinds")
--require("monitors")


