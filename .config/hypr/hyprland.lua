-- Hyprland config (Lua format, Hyprland 0.56+)
-- Migrated from hyprland.conf. Reference: /usr/share/hypr/hyprland.lua
-- Validate after editing:  Hyprland --verify-config -c ~/.config/hypr/hyprland.lua

-----------
--- GPU ---
-----------
-- Use only the Intel GPU (it drives the built-in screen). Hyprland then never
-- opens the NVIDIA GPU, so it can power off when unused (~5 W at idle).
-- Side effect: the HDMI port is wired to the NVIDIA GPU and won't work here
-- (use Windows for external monitors). Apps can still use NVIDIA on demand
-- (e.g. whisper dictation), it just wakes up for them.
-- Card numbers can swap between boots, so find Intel (vendor 0x8086) by ID.
-- If none is found, nothing is set and Hyprland uses its default behaviour.
for i = 0, 9 do
    local f = io.open("/sys/class/drm/card" .. i .. "/device/vendor", "r")
    if f then
        local vendor = f:read("*l")
        f:close()
        if vendor == "0x8086" then
            hl.env("AQ_DRM_DEVICES", "/dev/dri/card" .. i)
            break
        end
    end
end

----------------
--- MONITORS ---
----------------
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-------------------
--- MY PROGRAMS ---
-------------------
local terminal    = "alacritty"
local fileManager = "nautilus"
local menu        = "rofi -show drun"
local scripts     = "~/.config/hypr/scripts/"

-----------------
--- AUTOSTART ---
-----------------
hl.on("hyprland.start", function()
    -- Portals (dark mode, file pickers, screen sharing) are user services that
    -- outlive Hyprland. After a crash/re-login they stay tied to the dead session
    -- and make apps (browsers!) stall at startup, so hand them the new session.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE && systemctl --user restart xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal")
    hl.exec_cmd("wl-paste -t text --watch clipman store")
    -- Force hyprpaper onto the Intel GPU (Mesa). Left alone it picks the NVIDIA
    -- GPU and keeps it awake (~5 W) just to show a still wallpaper.
    hl.exec_cmd("__EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json hyprpaper")
    hl.exec_cmd(scripts .. "power-mode.sh") -- battery: 60 Hz + power-saver; AC: 120 Hz + balanced
    hl.exec_cmd("waybar")
    hl.exec_cmd("hypridle")       -- dim / lock / screen off / suspend when idle (hypridle.conf)
    hl.exec_cmd("blueman-applet") -- Bluetooth pairing agent (tray icon disabled in blueman settings)
end)

-----------------------------
--- ENVIRONMENT VARIABLES ---
-----------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

---------------------
--- LOOK AND FEEL ---
---------------------
hl.config({
    general = {
        gaps_in     = 3,
        gaps_out    = 6,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgb(c084fc)", "rgb(a855f7)" }, angle = 45 },
            inactive_border = { colors = { "rgb(3a2e4f)", "rgb(241c35)" }, angle = 45 },
        },
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2,
        dim_inactive   = true,
        dim_strength   = 0.1,
        dim_around     = 0.5,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = { enabled = true },

    dwindle = {
        preserve_split = true,
        force_split    = 2, -- new windows always open to the right/bottom
    },

    master = { new_status = "master" },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
        -- If hyprlock ever crashes, allow a new hyprlock to take over the lock
        -- instead of leaving the screen blocked.
        allow_session_lock_restore = true,
    },

    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse       = 1, -- focus follows the mouse
        numlock_by_default = true,
        sensitivity        = 0,
        touchpad = { natural_scroll = true },
    },

    gestures = { workspace_swipe_distance = 300 },

    -- Keep a full log so crashes can be diagnosed (/run/user/1000/hypr/*/hyprland.log)
    debug = { disable_logs = false },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}  } })

hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- 3-finger horizontal swipe switches workspaces
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-------------------
--- KEYBINDINGS ---
-------------------
local mainMod = "SUPER"
local function key(k) return mainMod .. " + " .. k end

-- Apps
hl.bind(key("Q"), hl.dsp.exec_cmd(terminal))
hl.bind(key("F"), hl.dsp.exec_cmd("firefox"))
hl.bind(key("W"), hl.dsp.exec_cmd("brave-browser"))
hl.bind(key("E"), hl.dsp.exec_cmd(fileManager))
hl.bind(key("space"), hl.dsp.exec_cmd(menu)) -- app launcher
hl.bind(key("SHIFT + W"), hl.dsp.exec_cmd("clipman pick -t rofi")) -- clipboard history

-- Windows
hl.bind(key("C"), hl.dsp.window.close())
hl.bind(key("M"), hl.dsp.exit())
hl.bind(key("V"), hl.dsp.window.float({ action = "toggle" }))
hl.bind(key("P"), hl.dsp.window.pseudo())
hl.bind(key("T"), hl.dsp.layout("togglesplit")) -- dwindle

-- Screenshot / recording
hl.bind(key("SHIFT + S"), hl.dsp.exec_cmd(scripts .. "screenshot.sh"))
hl.bind(key("SHIFT + R"), hl.dsp.exec_cmd(scripts .. "record.sh"))        -- toggle start/stop
hl.bind(key("SHIFT + C"), hl.dsp.exec_cmd("pkill -INT wf-recorder"))      -- emergency stop

-- Voice typing (whisper.cpp, offline): press to start listening, press again to type it
hl.bind(key("D"), hl.dsp.exec_cmd(scripts .. "dictate.sh"))

-- Focus: SUPER + hjkl / arrows; move window: SUPER + SHIFT + hjkl
local dirs = { H = "left", L = "right", K = "up", J = "down",
               left = "left", right = "right", up = "up", down = "down" }
for k, dir in pairs(dirs) do
    hl.bind(key(k), hl.dsp.focus({ direction = dir }))
end
for _, k in ipairs({ "H", "J", "K", "L" }) do
    hl.bind(key("SHIFT + " .. k), hl.dsp.window.move({ direction = dirs[k] }))
end
hl.bind("ALT + Tab", hl.dsp.window.cycle_next())
hl.bind("ALT + Tab", hl.dsp.window.bring_to_top())

-- Workspaces 1-10
for i = 1, 10 do
    local k = i % 10
    hl.bind(key(k),              hl.dsp.focus({ workspace = i }))
    hl.bind(key("SHIFT + " .. k), hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(key("S"),       hl.dsp.workspace.toggle_special("magic"))
hl.bind(key("ALT + S"), hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through workspaces
hl.bind(key("mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(key("mouse_up"),   hl.dsp.focus({ workspace = "e-1" }))

-- Mouse move/resize
hl.bind(key("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(key("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- Lock screen
hl.bind(key("Escape"), hl.dsp.exec_cmd("pidof hyprlock || hyprlock")) -- works even if hypridle is not running

-- Power
hl.bind("CTRL + ALT + S", hl.dsp.exec_cmd("systemctl poweroff"))
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd("systemctl reboot"))
hl.bind("CTRL + ALT + Q", hl.dsp.exec_cmd("systemctl suspend"))

-- Media / brightness keys
local held = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      held)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     held)
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   held)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  held)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  held)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------
--- WINDOW RULES ---
--------------------
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
    no_focus = true,
})

-- Calendar (right-click the clock) opens as a centered floating window
hl.window_rule({
    name   = "calendar-popup",
    match  = { class = "org.gnome.Calendar" },
    float  = true,
    size   = "760 560",
    center = true,
})
