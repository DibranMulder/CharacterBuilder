extends Node2D
## Retained world sign: discovery at a distance, readiness only when action is legal.
var caption: Label
var ready_to_use := false
var kind := "trade"
var cached_text := ""

func _ready() -> void:
	z_index = 185
	caption = Label.new()
	caption.position = Vector2(-96,24)
	caption.size = Vector2(192,42)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size",14)
	caption.add_theme_color_override("font_color",Color("fff1cc"))
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caption)

func refresh(at: Vector2, title: String, usable: bool, shown: bool, symbol := "trade") -> void:
	position = at
	visible = shown
	if cached_text != title:
		cached_text = title
		caption.text = title
	if ready_to_use != usable or kind != symbol:
		ready_to_use = usable
		kind = symbol
		queue_redraw()

func _draw() -> void:
	var ink := Color("ffe09b") if ready_to_use else Color("bfcfce")
	draw_style_box(_plate(ink),Rect2(-100,20,200,46))
	draw_circle(Vector2.ZERO,21,Color("102536"))
	draw_arc(Vector2.ZERO,21,0,TAU,32,ink,2,true)
	if kind == "trade":
		# Speech bubble: a service, not a quest or decorative building.
		draw_rect(Rect2(-11,-8,22,14),ink,false,2)
		draw_polyline(PackedVector2Array([Vector2(-6,6),Vector2(-6,12),Vector2(1,6)]),ink,2,true)
		for x in [-6,0,6]: draw_circle(Vector2(x,-1),1.5,ink)
	else:
		var direction := -1 if kind == "west" else 1
		draw_line(Vector2(-11*direction,0),Vector2(11*direction,0),ink,2,true)
		draw_polyline(PackedVector2Array([Vector2(3*direction,-8),Vector2(11*direction,0),Vector2(3*direction,8)]),ink,2,true)
	if ready_to_use:
		# Ground bracket ties the sign to its actual world target.
		draw_arc(Vector2(0,260),36,0,PI,24,Color("ffe09baa"),3,true)
	draw_colored_polygon(PackedVector2Array([Vector2(-5,69),Vector2(5,69),Vector2(0,76)]),ink)

func _plate(ink: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("102536ed")
	style.border_color = ink
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	return style
