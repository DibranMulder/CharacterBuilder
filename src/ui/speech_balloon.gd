extends Panel
## Non-interactive, reusable Chronicle world speech. Position is bottom-center.
var caption: Label

func _ready() -> void:
	theme = preload("res://src/ui/chronicle_theme.gd").create()
	theme_type_variation = &"ParchmentPanel"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(238,56)
	caption = Label.new()
	caption.position = Vector2(12,6)
	caption.size = Vector2(214,44)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_color_override("font_color",Color("463d2b"))
	caption.add_theme_font_size_override("font_size",16)
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caption)

func show_line(line: String) -> void:
	visible = not line.is_empty()
	caption.text = line

func _draw() -> void:
	draw_colored_polygon(PackedVector2Array([Vector2(107,55),Vector2(119,65),Vector2(131,55)]),Color("c79b48"))
	draw_colored_polygon(PackedVector2Array([Vector2(110,54),Vector2(119,62),Vector2(128,54)]),Color("f3e5be"))
