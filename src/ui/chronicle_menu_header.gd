extends RefCounted
## Shared navigation for Chronicle menus; content panels keep their own layout.
const Chronicle = preload("res://src/ui/chronicle_theme.gd")

static func install(host: Control, active: String, close_key: String, close: Callable, pouch: Callable, skills: Callable, show_pouch := true, disciplines := Callable()) -> void:
	var frame := Panel.new()
	frame.position = Vector2(12,6)
	frame.size = Vector2(1128,66)
	frame.theme_type_variation = &"InkPanel"
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	host.add_child(frame)
	var title := Label.new()
	title.text = "THE CHRONICLE"
	title.position = Vector2(30,23)
	title.add_theme_font_size_override("font_size",20)
	title.add_theme_color_override("font_color",Chronicle.GOLD)
	title.add_theme_font_override("font",host.theme.get_font("font","ChronicleHeading"))
	host.add_child(title)
	var entries := [
		["Gear & Pouch",Rect2(300,18,185,42),pouch,"pouch"],
		["Combat Skills",Rect2(495,18,230,42),skills,"skills"],
		["Disciplines & Levels",Rect2(735,18,215,42),disciplines if disciplines.is_valid() else skills,"disciplines"],
		["Close · %s / Esc"%close_key,Rect2(965,18,157,42),close,"close"],
	]
	for entry in entries:
		if entry[3] == "pouch" and not show_pouch: continue
		var button := Button.new()
		button.text = entry[0]
		button.position = entry[1].position
		button.size = entry[1].size
		button.focus_mode = Control.FOCUS_NONE
		button.theme_type_variation = &"PrimaryButton" if entry[3] == active else &"Button"
		button.pressed.connect(entry[2])
		host.add_child(button)
