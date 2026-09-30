extends RefCounted
## Which build is running and what it needs. One code base, four builds (export_presets.cfg):
##   desktop – Windows/Linux download: keyboard, mouse, gamepad, no store
##   steam   – Windows build with the "steam" feature tag (GodotSteam when present)
##   mobile  – Android APK for sideloading: touch first, reduced graphics
##   play    – Android AAB for Google Play ("play" feature tag): touch, Play Billing
## Tests and the editor can force a profile with the command line argument --platform=<name>
## and switch touch controls on with --touch.

const SETTINGS := "user://platform.cfg"

## Tests set this to simulate another build ("mobile", "play", "steam").
static var forced := ""

static func _arg(name: String) -> String:
	for a in OS.get_cmdline_user_args():
		if a == "--" + name: return "1"
		if a.begins_with("--%s=" % name): return a.trim_prefix("--%s=" % name)
	return ""

static func build() -> String:
	if forced != "": return forced
	var arg := _arg("platform")
	if arg != "": return arg
	if OS.has_feature("play"): return "play"
	if OS.has_feature("steam"): return "steam"
	if OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios"): return "mobile"
	return "desktop"

static func is_mobile() -> bool:
	return build() in ["mobile", "play"]

## Touch controls: on phones always, elsewhere when forced or switched on in the options
## (touch laptops, Steam Deck touchscreen).
static func touch_enabled() -> bool:
	if _arg("touch") != "": return true
	if is_mobile(): return true
	return bool(setting("touch_on_desktop", false))

## Graphics profile: phones get the light profile (fewer particles and shadows, no glow).
static func low_graphics() -> bool:
	if _arg("low") != "": return true
	return is_mobile() and not bool(setting("high_graphics", false))

static func setting(key: String, default_value: Variant) -> Variant:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS) != OK: return default_value
	return cfg.get_value("platform", key, default_value)

static func set_setting(key: String, value: Variant) -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS)
	cfg.set_value("platform", key, value)
	cfg.save(SETTINGS)
