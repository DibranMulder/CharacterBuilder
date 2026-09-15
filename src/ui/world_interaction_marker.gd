extends Node2D
## Icon-first world hint. Hover for details; tap toggles details on touch.
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
var caption: Label
var hit_area: Control
var expanded := false
var touch_pinned := false
var ready_to_use := false
var kind := "trade"
var cached_text := ""

func _ready() -> void:
	z_index = 185
	caption = Label.new()
	caption.theme = Chronicle.create()
	caption.add_theme_font_override("font",caption.theme.get_font("font","ChronicleHeading"))
	caption.position = Vector2(-112,32)
	caption.size = Vector2(224,42)
	caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption.visible = false
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size",14)
	caption.add_theme_color_override("font_color",Color("fff1cc"))
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(caption)
	caption.resized.connect(queue_redraw)
	hit_area = Control.new()
	hit_area.position = Vector2(-24,-24)
	hit_area.size = Vector2(48,48)
	hit_area.mouse_filter = Control.MOUSE_FILTER_STOP
	hit_area.mouse_entered.connect(func(): _set_expanded(true))
	hit_area.mouse_exited.connect(func():
		if not touch_pinned: _set_expanded(false)
	)
	hit_area.gui_input.connect(_hint_input)
	add_child(hit_area)
	visibility_changed.connect(func():
		if not is_visible_in_tree():
			touch_pinned = false
			_set_expanded(false)
	)

func _hint_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		touch_pinned = not touch_pinned
		_set_expanded(touch_pinned)
		hit_area.accept_event()

func _input(event: InputEvent) -> void:
	if touch_pinned and event is InputEventScreenTouch and event.pressed:
		var local: Vector2 = hit_area.get_global_transform_with_canvas().affine_inverse()*event.position
		if not Rect2(Vector2.ZERO,hit_area.size).has_point(local):
			touch_pinned = false
			_set_expanded(false)

func _set_expanded(value: bool) -> void:
	value = value and is_visible_in_tree()
	if expanded == value: return
	expanded = value
	caption.visible = value
	z_index = 280 if value else 185
	queue_redraw()

func refresh(at: Vector2, title: String, usable: bool, shown: bool, symbol := "trade") -> void:
	position = at
	visible = shown
	caption.position.x = clampf(-112,12-at.x,916-at.x)
	if cached_text != title:
		cached_text = title
		caption.text = title
	if ready_to_use != usable or kind != symbol:
		ready_to_use = usable
		kind = symbol
		queue_redraw()

func _draw() -> void:
	var ink := Chronicle.GOLD if ready_to_use or kind == "quest_active" else Chronicle.BRASS
	var plate = Chronicle.Frame.new()
	plate.fill = Chronicle.NAVY
	plate.border = ink
	if expanded:
		draw_style_box(plate,Rect2(caption.position-Vector2(8,6),caption.size+Vector2(16,12)))
	draw_circle(Vector2.ZERO,23,Color("403522"))
	draw_circle(Vector2.ZERO,20,Chronicle.NAVY)
	draw_arc(Vector2.ZERO,23,0,TAU,48,ink,1.5,true)
	draw_arc(Vector2.ZERO,19,0,TAU,48,Color(ink,.6),1,true)
	match kind:
		"trade":
			# A tied coin pouch remains legible at discovery distance.
			var bag := PackedVector2Array([Vector2(-5,-6),Vector2(-10,2),Vector2(-9,10),Vector2(0,13),Vector2(9,10),Vector2(10,2),Vector2(5,-6)])
			draw_colored_polygon(bag,Color("9a713a"))
			bag.append(bag[0])
			draw_polyline(bag,ink,1.5,true)
			draw_colored_polygon(PackedVector2Array([Vector2(-5,-8),Vector2(-7,-13),Vector2(6,-13),Vector2(4,-8)]),ink)
			draw_line(Vector2(-6,-6),Vector2(7,-6),Chronicle.IVORY,2,true)
			draw_circle(Vector2(0,4),4,Chronicle.GOLD)
			draw_line(Vector2(0,1),Vector2(0,7),Color("8b622e"),1,true)
		"quest", "quest_active":
			draw_colored_polygon(PackedVector2Array([Vector2(-4,-13),Vector2(4,-13),Vector2(2,4),Vector2(-2,4)]),ink)
			draw_circle(Vector2(0,10),3,ink)
		"hint":
			draw_circle(Vector2(0,-10),2.5,ink)
			draw_line(Vector2(0,-3),Vector2(0,11),ink,3,true)
		"up":
			draw_line(Vector2(-8,9),Vector2(8,-9),ink,2,true)
			draw_polyline(PackedVector2Array([Vector2(-3,-9),Vector2(8,-9),Vector2(8,2)]),ink,2,true)
		"west", "east":
			var direction := -1 if kind == "west" else 1
			draw_line(Vector2(-11*direction,0),Vector2(11*direction,0),ink,2,true)
			draw_polyline(PackedVector2Array([Vector2(3*direction,-8),Vector2(11*direction,0),Vector2(3*direction,8)]),ink,2,true)
		_:
			draw_rect(Rect2(-11,-8,22,14),ink,false,2)
			draw_polyline(PackedVector2Array([Vector2(-6,6),Vector2(-6,12),Vector2(1,6)]),ink,2,true)
			for x in [-6,0,6]: draw_circle(Vector2(x,-1),1.5,ink)
