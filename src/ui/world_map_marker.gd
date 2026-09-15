extends Button
## A small geographic pin; the name stays screen-sized while the terrain zooms.
var current := false
var discovered := false
var selected := false
var caption: Label
var accent := Color("f2c45f")

func _ready() -> void:
	focus_mode = FOCUS_NONE
	for state in ["normal","hover","pressed","disabled","focus"]:
		add_theme_stylebox_override(state,StyleBoxEmpty.new())
	caption = Label.new()
	caption.position = Vector2(24,-3)
	caption.size = Vector2(165,42)
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.add_theme_font_size_override("font_size",13)
	caption.add_theme_color_override("font_color",Color("fff4d4"))
	caption.add_theme_color_override("font_outline_color",Color("10212a"))
	caption.add_theme_constant_override("outline_size",5)
	caption.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(caption)
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)

func _draw() -> void:
	var center := size*.5
	if current or selected or is_hovered():
		draw_circle(center,13,Color(accent,.22))
		draw_arc(center,11,0,TAU,24,accent,1.5,true)
	draw_circle(center,6,Color("122937"))
	draw_circle(center,3.5,accent if discovered or selected else Color("91a6ae"))
	if current:
		var arrow := PackedVector2Array([center+Vector2(-4,-15),center+Vector2(4,-15),center+Vector2(0,-10)])
		draw_colored_polygon(arrow,Color("fff1bc"))
