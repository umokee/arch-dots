local profile = os.getenv("HYPR_PROFILE") or "desktop"

local mainMod = "SUPER"

local terminal = "foot"
local browser = "zen"
local launcher = "tofi-drun --drun-launch=true"
local filemanager = "nemo"
local screenshot_area = os.getenv("HOME") .. "/.local/bin/screenshot-tool area"

-- =========================
-- Autostart / exec-once
-- =========================

hl.on("hyprland.start", function()
  hl.exec_cmd("/usr/local/bin/arch-session-start")
	-- hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	-- hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("echo 'Xft.dpi: 125' | xrdb -merge")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface text-scaling-factor 1.25")
	hl.exec_cmd("steam")
	hl.exec_cmd("telegram-desktop")
	hl.exec_cmd("zen-browser")
	hl.exec_cmd("spotify")
end)

-- =========================
-- Monitors
-- =========================

hl.monitor({
	output = "",
	mode = "1920x1080@60",
	position = "auto",
	scale = 1,
})

-- =========================
-- Workspace rules
-- =========================

local function workspace_rule(workspace, monitor, is_default)
	local rule = {
		workspace = tostring(workspace),
		monitor = monitor,
	}

	if is_default then
		rule.default = true
	end

	hl.workspace_rule(rule)
end

if profile == "desktop" then
	workspace_rule(1, "DP-3", true)
	workspace_rule(2, "DP-3")
	workspace_rule(3, "DP-3")
	workspace_rule(4, "DP-3")
	workspace_rule(5, "DP-3")

	workspace_rule(6, "HDMI-A-5", true)
	workspace_rule(7, "HDMI-A-5")
	workspace_rule(8, "HDMI-A-5")
	workspace_rule(9, "HDMI-A-5")
	workspace_rule(10, "HDMI-A-5")

	-- В старом Nix-конфиге default:true был на 11-15 сразу.
	-- Это странно: дефолтный workspace на монитор логично держать один.
	workspace_rule(11, "DP-4", true)
	workspace_rule(12, "DP-4")
	workspace_rule(13, "DP-4")
	workspace_rule(14, "DP-4")
	workspace_rule(15, "DP-4")
else
	workspace_rule(1, "eDP-1", true)
	workspace_rule(2, "eDP-1")
	workspace_rule(3, "eDP-1")
	workspace_rule(4, "eDP-1")
	workspace_rule(5, "eDP-1")
	workspace_rule(6, "eDP-1")
	workspace_rule(7, "eDP-1")
	workspace_rule(8, "eDP-1")
	workspace_rule(9, "eDP-1")
	workspace_rule(10, "eDP-1")
end

-- =========================
-- Main config
-- =========================

hl.config({
	xwayland = {
		force_zero_scaling = false,
	},

	input = {
		kb_layout = "us,ru-custom",
		kb_options = "grp:ctrl_shift_toggle",
		repeat_rate = 50,
		repeat_delay = 300,

		follow_mouse = 1,
		focus_on_close = 1,
		sensitivity = 0,

		touchpad = {
			natural_scroll = true,
			disable_while_typing = true,
			scroll_factor = 0.3,
		},
	},

	general = {
		gaps_in = 2,
		gaps_out = 2,
		border_size = 1,
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 0,
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		blur = {
			enabled = false,
			xray = false,
			special = false,
			ignore_opacity = true,
			new_optimizations = true,
			popups = true,
			input_methods = true,
			size = 8,
			passes = 2,
		},

		shadow = {
			enabled = false,
		},
	},

	animations = {
		enabled = false,
	},

	dwindle = {
		preserve_split = true,
		smart_split = false,
		smart_resizing = true,
	},

	misc = {
		vrr = 1,
		animate_manual_resizes = false,
		animate_mouse_windowdragging = false,
		disable_hyprland_logo = true,
		force_default_wallpaper = 0,
		on_focus_under_fullscreen = 2,
		allow_session_lock_restore = true,
		middle_click_paste = false,
		focus_on_activate = false,
	},
})

-- =========================
-- Keybinds
-- =========================

local function bind(keys, dispatcher, flags)
	hl.bind(keys, dispatcher, flags)
end

bind(mainMod .. " + A", hl.dsp.exec_cmd(launcher))
bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
bind(mainMod .. " + W", hl.dsp.exec_cmd(browser))
bind(mainMod .. " + E", hl.dsp.exec_cmd(filemanager))
bind(mainMod .. " + S", hl.dsp.exec_cmd(screenshot_area))

bind(mainMod .. " + Q", hl.dsp.window.close())
bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

for i = 1, 10 do
	local key = tostring(i)

	if i == 10 then
		key = "0"
	end

	bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
	bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
end

-- Mouse binds
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys
-- В твоём старом конфиге обе команды ставили громкость в 5%.
-- Здесь исправлено на повышение/понижение.
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })

-- =========================
-- Window rules
-- =========================

-- Floating windows
hl.window_rule({
	match = { class = "^(guifetch|yad|zenity|wev|feh|imv|system-config-printer|org.quickshell)$" },
	float = true,
})

hl.window_rule({
	match = { class = "^(org.gnome.FileRoller|file-roller|blueman-manager)$" },
	float = true,
})

hl.window_rule({
	match = { class = "^com.github.GradienceTeam.Gradience$" },
	float = true,
})

-- Foot + nmtui
hl.window_rule({
	match = {
		class = "^foot$",
		title = "nmtui",
	},
	float = true,
	size = { "monitor_w*0.60", "monitor_h*0.70" },
	center = true,
})

-- GNOME Settings
hl.window_rule({
	match = { class = "^org.gnome.Settings$" },
	float = true,
	size = { "monitor_w*0.70", "monitor_h*0.80" },
	center = true,
})

-- Pavucontrol & yad-icon-browser
hl.window_rule({
	match = { class = "^(org.pulseaudio.pavucontrol|yad-icon-browser)$" },
	float = true,
	size = { "monitor_w*0.60", "monitor_h*0.70" },
	center = true,
})

-- nwg-look
hl.window_rule({
	match = { class = "^nwg-look$" },
	float = true,
	size = { "monitor_w*0.50", "monitor_h*0.60" },
	center = true,
})

-- ATLauncher Console
hl.window_rule({
	match = {
		class = "^com-atlauncher-App$",
		title = "^ATLauncher Console$",
	},
	float = true,
})

-- File dialogs
hl.window_rule({
	match = { title = "^(Select|Open)( a)? (File|Folder)(s)?$" },
	float = true,
})

hl.window_rule({
	match = { title = "^File (Operation|Upload)( Progress)?$" },
	float = true,
})

hl.window_rule({
	match = { title = "^(.* Properties|Export Image as PNG|GIMP Crash Debug|Save As|Library)$" },
	float = true,
})

-- Picture-in-Picture
hl.window_rule({
	match = { title = "^Picture(-| )in(-| )[Pp]icture$" },
	float = true,
	pin = true,
	keep_aspect_ratio = true,
	move = {
		"monitor_w-window_w-(monitor_w*0.02)",
		"monitor_h-window_h-(monitor_h*0.03)",
	},
})

-- Steam
hl.window_rule({
	match = {
		class = "^steam$",
		title = "^$",
	},
	rounding = 10,
})

hl.window_rule({
	match = {
		class = "^steam$",
		title = "^Friends List$",
	},
	float = true,
})

-- Steam games
hl.window_rule({
	match = { class = "^steam_app_[0-9]+" },
	workspace = "5 silent",
	immediate = true,
	idle_inhibit = "always",
})

-- Wine / Proton .exe
hl.window_rule({
	match = { class = [[.*\.exe$]] },
	workspace = "5 silent",
	immediate = true,
})

-- Fusion360
hl.window_rule({
	match = {
		class = [[^fusion360\.exe$]],
		title = "^(Fusion360|Marking Menu)$",
	},
	no_blur = true,
})

-- Opaque windows
hl.window_rule({
	match = { class = "^(foot|equibop|org.quickshell|imv|swappy)$" },
	opaque = true,
})

-- XWayland windows
hl.window_rule({
	match = {
		xwayland = true,
		title = "^win[0-9]+$",
	},
	no_dim = true,
	no_shadow = true,
	rounding = 10,
})

-- Fullscreen opacity
hl.window_rule({
	match = { fullscreen = false },
	opacity = "1 override",
})

-- Center floating native Wayland windows
hl.window_rule({
	match = {
		float = true,
		xwayland = false,
	},
	center = true,
})

-- Workspace assignments
hl.window_rule({
	match = { class = "^(firefox|zen-beta|google-chrome|chromium|brave-browser)$" },
	workspace = "1",
})

hl.window_rule({
	match = { class = "^(code|vscodium|jetbrains-idea|jetbrains-clion|neovide)$" },
	workspace = "2",
})

hl.window_rule({
	match = { class = "^(steam|lutris|heroic|com.usebottles.bottles|gamescope)$" },
	workspace = "5 silent",
})

hl.window_rule({
	match = { class = "^nemo$" },
	workspace = "6",
})

hl.window_rule({
	match = { class = "^foot$" },
	workspace = "7",
})

hl.window_rule({
	match = { class = "^(yandex-music|spotify)$" },
	workspace = "9",
})

hl.window_rule({
	match = { class = [[^(org\.telegram\.desktop|discord|vesktop|element-desktop)$]] },
	workspace = "10",
})

-- JetBrains fix
hl.window_rule({
	match = {
		class = "^(.*jetbrains.*)$",
		title = "^(win.*)$",
	},
	no_initial_focus = true,
})
