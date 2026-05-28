local profile = os.getenv("HYPR_PROFILE") or "desktop"

local mainMod = "SUPER"

local terminal = "foot"
local browser = "zen"
local launcher = "tofi-drun --drun-launch=true"
local filemanager = "nemo"
local screenshot_area = os.getenv("HOME") .. "/.local/bin/screenshot-tool area"

-- =========================
-- Session bootstrap
-- =========================

-- hl.on("hyprland.start", function()
-- 	smth...
-- end)

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

  cursor = {
    no_hardware_cursors = 1,
    use_cpu_buffer = 2,
    default_monitor = "DP-3",
    inactive_timeout = 0,
		sync_gsettings_theme = true,
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

		["col.active_border"] = "rgba(7aa2f7ff)",
		["col.inactive_border"] = "rgba(292e42aa)",
	},

	decoration = {
		rounding = 0,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		fullscreen_opacity = 1.0,

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
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })

-- =========================
-- Helpers for rules
-- =========================

local function rule(match, options)
	options.match = match
	hl.window_rule(options)
end

local function float_class(class_regex)
	rule({ class = class_regex }, {
		float = true,
	})
end

local function float_class_sized(class_regex, width, height)
	rule({ class = class_regex }, {
		float = true,
		size = { width, height },
		center = true,
	})
end

local function float_title(title_regex)
	rule({ title = title_regex }, {
		float = true,
	})
end

local function workspace_class(class_regex, workspace)
	rule({ class = class_regex }, {
		workspace = workspace,
	})
end

-- =========================
-- Window rules: floating
-- =========================

-- Tiny/tools/debug windows
float_class("^(guifetch|yad|zenity|wev|feh|imv|swappy|org.quickshell)$")
float_class("^(system-config-printer|nm-connection-editor|blueman-manager)$")
float_class("^(org.gnome.FileRoller|file-roller|xarchiver)$")
float_class("^com.github.GradienceTeam.Gradience$")

-- Settings/control panels
float_class_sized("^(org.gnome.Settings)$", "monitor_w*0.70", "monitor_h*0.80")
float_class_sized("^(org.pulseaudio.pavucontrol|pavucontrol|yad-icon-browser)$", "monitor_w*0.60", "monitor_h*0.70")
float_class_sized("^(nwg-look|qt5ct|qt6ct|kvantummanager)$", "monitor_w*0.50", "monitor_h*0.60")

-- Terminal special tools
rule({
	class = "^foot$",
	title = "^(nmtui|btop|htop)$",
}, {
	float = true,
	size = { "monitor_w*0.60", "monitor_h*0.70" },
	center = true,
})

-- Launchers/dialog helpers
float_title("^(Open|Save|Save As|Select|Choose)( a)? (File|Folder)(s)?$")
float_title("^File (Operation|Upload|Download)( Progress)?$")
float_title("^(.* Properties|Export Image as PNG|GIMP Crash Debug|Library)$")
float_title("^(Authentication Required|Password Required)$")
float_title("^(Confirm|Confirmation|Warning|Error)$")

-- Java/ATLauncher
rule({
	class = "^com-atlauncher-App$",
	title = "^ATLauncher Console$",
}, {
	float = true,
})

-- Picture-in-Picture
rule({
	title = "^Picture(-| )in(-| )[Pp]icture$",
}, {
	float = true,
	pin = true,
	keep_aspect_ratio = true,
	move = {
		"monitor_w-window_w-(monitor_w*0.02)",
		"monitor_h-window_h-(monitor_h*0.03)",
	},
})

-- Steam popups
rule({
	class = "^steam$",
	title = "^$",
}, {
	rounding = 10,
})

rule({
	class = "^steam$",
	title = "^(Friends List|Settings|Steam - News|Special Offers)$",
}, {
	float = true,
})

-- =========================
-- Window rules: gaming / XWayland / Wine
-- =========================

rule({ class = "^steam_app_[0-9]+" }, {
	workspace = "5 silent",
	immediate = true,
	idle_inhibit = "always",
})

rule({ class = [[.*\.exe$]] }, {
	workspace = "5 silent",
	immediate = true,
})

rule({
	class = [[^fusion360\.exe$]],
	title = "^(Fusion360|Marking Menu)$",
}, {
	no_blur = true,
})

rule({
	xwayland = true,
	title = "^win[0-9]+$",
}, {
	no_dim = true,
	no_shadow = true,
	rounding = 10,
})

-- =========================
-- Window rules: opacity / native floating
-- =========================

rule({
	class = "^(foot|org.quickshell|imv|swappy)$",
}, {
	opaque = true,
})

rule({
	fullscreen = false,
}, {
	opacity = "1 override",
})

rule({
	float = true,
	xwayland = false,
}, {
	center = true,
})

-- =========================
-- Window rules: workspaces
-- =========================

-- 1: Browsers
workspace_class("^(firefox|zen|zen-browser|zen-beta|google-chrome|chromium|brave-browser)$", "1")

-- 2: Development
workspace_class("^(code|Code|code-url-handler|vscodium|VSCodium|jetbrains-idea|jetbrains-clion|neovide)$", "2")
workspace_class("^(pgadmin4|sqlitebrowser)$", "2")

-- 3: Notes/knowledge
workspace_class("^(obsidian|Obsidian)$", "3")

-- 4: Office/documents
workspace_class("^(libreoffice|soffice|libreoffice-writer|libreoffice-calc|libreoffice-impress)$", "4")

-- 5: Games
workspace_class("^(steam|lutris|heroic|com.usebottles.bottles|gamescope|ATLauncher|com-atlauncher-App)$", "5 silent")

-- 6: Files
workspace_class("^(nemo|org.gnome.Nautilus|dolphin|org.kde.dolphin)$", "6")

-- 7: Terminals
workspace_class("^(foot|kitty|Alacritty|org.wezfurlong.wezterm)$", "7")

-- 8: VMs / heavy system tools
workspace_class("^(virt-manager|virt-viewer|VirtualBox Manager|winboat|WinBoat)$", "8")

-- 9: Music/media
workspace_class("^(yandex-music|spotify|Spotify|vlc|mpv)$", "9")

-- 10: Chats
workspace_class([[(org\.telegram\.desktop|telegram-desktop|discord|vesktop|equibop|element-desktop)$]], "10")

-- 11: Screenshots / images / small visual tools
workspace_class("^(imv|feh|swappy|obs)$", "11")

-- JetBrains focus fix
rule({
	class = "^(.*jetbrains.*)$",
	title = "^(win.*)$",
}, {
	no_initial_focus = true,
})
