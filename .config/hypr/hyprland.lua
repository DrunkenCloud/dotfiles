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
local scripts     = "~/.config/hypr/scripts/"

-- Which desktop shell to run (takes effect at the next login):
--   "noctalia"  Noctalia does bar, launcher, notifications, OSD, lock, idle,
--               wallpaper, clipboard and night light (~/.config/noctalia/config.toml)
--   "classic"   the old setup: waybar, rofi, mako, swayosd, hyprlock/hypridle,
--               hyprpaper, cliphist, hyprsunset
local shell = "noctalia"
local noctalia = shell == "noctalia"
local ipc = "noctalia msg "
-- GL programs must use the Intel GPU (Mesa). Left alone they pick the NVIDIA
-- GPU and keep it awake (~5 W) just to draw a bar / a still wallpaper.
local on_intel = "__EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json "

local menu = noctalia and ipc .. "panel-toggle launcher" or "rofi -show drun"

-----------------
--- AUTOSTART ---
-----------------
hl.on("hyprland.start", function()
    -- Portals (dark mode, file pickers, screen sharing) are user services that
    -- outlive Hyprland. After a crash/re-login they stay tied to the dead session
    -- and make apps (browsers!) stall at startup, so hand them the new session.
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE && systemctl --user restart xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-desktop-portal")
    hl.exec_cmd("/usr/libexec/hyprpolkitagent")  -- password prompts for GUI apps that need admin rights
    hl.exec_cmd("udiskie --automount --notify --smart-tray") -- auto-mount USB drives; eject icon in the tray while one is plugged in
    hl.exec_cmd(scripts .. "power-mode.sh") -- power-saver on battery, balanced under load / on AC
    hl.exec_cmd("blueman-applet") -- Bluetooth pairing agent (tray icon disabled in blueman settings)
    if noctalia then
        hl.exec_cmd(on_intel .. "noctalia")
    else
        hl.exec_cmd("mako")           -- notifications (themed in ~/.config/mako/config)
        hl.exec_cmd("swayosd-server") -- volume / brightness pop-up
        -- Clipboard history (text AND images) for SUPER+SHIFT+W
        hl.exec_cmd("wl-paste --type text --watch cliphist store")
        hl.exec_cmd("wl-paste --type image --watch cliphist store")
        hl.exec_cmd(on_intel .. "hyprpaper")
        hl.exec_cmd("waybar")
        hl.exec_cmd("hypridle")       -- dim / lock / screen off / suspend when idle (hypridle.conf)
    end
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
        -- ...but only when the cursor crosses into another window. Otherwise any
        -- tiny mouse movement re-focuses the window under it and steals the
        -- keyboard from an open Noctalia panel (Esc stops closing it).
        mouse_refocus      = false,
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
-- Every bind has a description: SUPER + / lists them all (scripts/keybinds.sh).
local mainMod = "SUPER"
local function key(k) return mainMod .. " + " .. k end
local function bind(keys, action, desc, opts)
    opts = opts or {}
    opts.description = desc
    hl.bind(keys, action, opts)
end
-- Command for the active shell: pick(noctalia command, classic command)
local function pick(n, c) return hl.dsp.exec_cmd(noctalia and n or c) end

-- Apps
bind(key("Q"),         hl.dsp.exec_cmd(terminal),                   "Terminal")
bind(key("F"),         hl.dsp.exec_cmd("firefox"),                  "Firefox")
bind(key("W"),         hl.dsp.exec_cmd("brave-browser"),            "Brave")
bind(key("E"),         hl.dsp.exec_cmd(fileManager),                "File manager")
bind(key("space"),     hl.dsp.exec_cmd(menu),                       "App launcher")
bind(key("slash"),     hl.dsp.exec_cmd(scripts .. "keybinds.sh"),   "Show this keybinding list")
bind(key("SHIFT + W"), pick(ipc .. "panel-toggle clipboard", scripts .. "clipboard.sh"),  "Clipboard history (text + images)")
bind(key("R"),         pick(ipc .. "nightlight-force-toggle", scripts .. "nightlight.sh"), "Toggle night light")
bind(key("D"),         hl.dsp.exec_cmd(scripts .. "dictate.sh"),    "Voice typing: start / stop and type")

-- Windows
bind(key("C"), hl.dsp.window.close(),                     "Close window")
bind(key("M"), hl.dsp.exit(),                             "Log out (exit Hyprland)")
bind(key("V"), hl.dsp.window.float({ action = "toggle" }), "Toggle floating")
bind(key("P"), hl.dsp.window.pseudo(),                    "Pseudo-tile window")
bind(key("T"), hl.dsp.layout("togglesplit"),              "Toggle split direction")

-- Screenshots / recording
bind(key("SHIFT + S"), hl.dsp.exec_cmd(scripts .. "screenshot.sh"),        "Screenshot: select region")
bind("Print",          hl.dsp.exec_cmd(scripts .. "screenshot.sh full"),   "Screenshot: whole screen")
bind("SHIFT + Print",  hl.dsp.exec_cmd(scripts .. "screenshot.sh window"), "Screenshot: focused window")
bind(key("SHIFT + R"), hl.dsp.exec_cmd(scripts .. "record.sh"),            "Screen recording: start / stop")
bind(key("SHIFT + C"), hl.dsp.exec_cmd("pkill -INT wf-recorder"),          "Screen recording: emergency stop")

-- Focus: SUPER + hjkl / arrows; move window: SUPER + SHIFT + hjkl
local dirs = { H = "left", L = "right", K = "up", J = "down",
               left = "left", right = "right", up = "up", down = "down" }
for k, dir in pairs(dirs) do
    bind(key(k), hl.dsp.focus({ direction = dir }), "Focus " .. dir)
end
for _, k in ipairs({ "H", "J", "K", "L" }) do
    bind(key("SHIFT + " .. k), hl.dsp.window.move({ direction = dirs[k] }), "Move window " .. dirs[k])
end
if noctalia then
    bind(key("A"),            hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"), "Control center (Wi-Fi, Bluetooth, notifications...)")
    bind(key("comma"),        hl.dsp.exec_cmd(ipc .. "settings-toggle"),               "Noctalia settings")
    bind("ALT + Tab",         hl.dsp.exec_cmd(ipc .. "window-switcher hold"),          "Switch windows")
    bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher hold reverse"),  "Switch windows (backwards)")
else
    bind("ALT + Tab", hl.dsp.window.cycle_next(),   "Cycle windows")
    bind("ALT + Tab", hl.dsp.window.bring_to_top(), "Cycle windows (bring to front)")
end

-- Workspaces 1-10
for i = 1, 10 do
    local k = i % 10
    bind(key(k),              hl.dsp.focus({ workspace = i }),       "Go to workspace " .. i)
    bind(key("SHIFT + " .. k), hl.dsp.window.move({ workspace = i }), "Move window to workspace " .. i)
end

-- Scratchpad
bind(key("S"),       hl.dsp.workspace.toggle_special("magic"),             "Show / hide scratchpad")
bind(key("ALT + S"), hl.dsp.window.move({ workspace = "special:magic" }), "Move window to scratchpad")

-- Scroll through workspaces
bind(key("mouse_down"), hl.dsp.focus({ workspace = "e+1" }), "Next workspace (scroll)")
bind(key("mouse_up"),   hl.dsp.focus({ workspace = "e-1" }), "Previous workspace (scroll)")

-- Mouse move/resize
bind(key("mouse:272"), hl.dsp.window.drag(),   "Drag window (left mouse)",    { mouse = true })
bind(key("mouse:273"), hl.dsp.window.resize(), "Resize window (right mouse)", { mouse = true })

-- Lock screen
bind(key("Escape"), pick(ipc .. "session lock", "pidof hyprlock || hyprlock"), "Lock screen")

-- Power
bind("CTRL + ALT + S", hl.dsp.exec_cmd("systemctl poweroff"), "Shut down")
bind("CTRL + ALT + R", hl.dsp.exec_cmd("systemctl reboot"),   "Reboot")
bind("CTRL + ALT + Q", hl.dsp.exec_cmd("systemctl suspend"),  "Suspend")

-- Media / brightness keys: change the value AND show a pop-up slider
-- (Noctalia's OSD, or swayosd in classic). Options are fresh tables per bind
-- because bind() adds a description to them.
local function held() return { locked = true, repeating = true } end
bind("XF86AudioRaiseVolume",  pick(ipc .. "volume-up",       "swayosd-client --output-volume raise"),       "Volume up",       held())
bind("XF86AudioLowerVolume",  pick(ipc .. "volume-down",     "swayosd-client --output-volume lower"),       "Volume down",     held())
bind("XF86AudioMute",         pick(ipc .. "volume-mute",     "swayosd-client --output-volume mute-toggle"), "Mute",            held())
bind("XF86AudioMicMute",      pick(ipc .. "mic-mute",        "swayosd-client --input-volume mute-toggle"),  "Mute microphone", held())
bind("XF86MonBrightnessUp",   pick(ipc .. "brightness-up",   "swayosd-client --brightness raise"),          "Brightness up",   held())
bind("XF86MonBrightnessDown", pick(ipc .. "brightness-down", "swayosd-client --brightness lower"),          "Brightness down", held())
bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       "Next track",     { locked = true })
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), "Play / pause",   { locked = true })
bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), "Play / pause",   { locked = true })
bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   "Previous track", { locked = true })

--------------------
--- WINDOW RULES ---
--------------------
-- Noctalia: its settings window floats; its bar/panels animate themselves
-- (Hyprland's layer animations on top cause tearing) and get blur.
hl.window_rule({ name = "noctalia-settings", match = { class = "dev.noctalia.Noctalia" }, float = true, size = { 1080, 920 } })
local noctalia_layers = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$"
hl.layer_rule({ name = "noctalia-no-anim", match = { namespace = noctalia_layers }, no_anim = true })
hl.layer_rule({ name = "noctalia-blur", match = { namespace = noctalia_layers }, ignore_alpha = 0.5, blur = true, blur_popups = true })

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

-- Settings apps open as floating, centered windows instead of being tiled
hl.window_rule({
    name   = "settings-popups",
    match  = { class = "^(org.pulseaudio.pavucontrol|pavucontrol|blueman-manager|.blueman-manager-wrapped|nm-connection-editor|gdm-settings|io.github.realmazharhussain.GdmSettings)$" },
    float  = true,
    size   = "900 620",
    center = true,
})
