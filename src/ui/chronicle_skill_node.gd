extends Button
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
var unlocked := false
var selected := false
var portrait: TextureRect

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	for state in ["normal","hover","pressed","disabled","focus"]:
		add_theme_stylebox_override(state,StyleBoxEmpty.new())
	mouse_entered.connect(queue_redraw)
	mouse_exited.connect(queue_redraw)
	portrait = preload("res://src/ui/chronicle_round_icon.gd").new()
	portrait.position = Vector2(8,8)
	portrait.size = Vector2(56,56)
	add_child(portrait)

func _draw() -> void:
	var center := Vector2(36,36)
	var edge := Chronicle.CYAN if selected or is_hovered() else (Color("45bfb0") if unlocked else Color("917d54"))
	if selected or unlocked:
		for ring in 5: draw_arc(center,36+ring,0,TAU,64,Color(edge,.16-ring*.025),2,true)
	draw_circle(center,35,Chronicle.NAVY)
	draw_arc(center,34,0,TAU,64,Chronicle.BRASS,3,true)
	draw_arc(center,30,0,TAU,64,edge,2,true)
	draw_arc(center,37,0,TAU,64,edge,1,true)
	for axis in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
		var point: Vector2 = center+axis*35
		draw_colored_polygon(PackedVector2Array([point+Vector2(0,-4),point+Vector2(4,0),point+Vector2(0,4),point+Vector2(-4,0)]),Chronicle.BRASS)
	if portrait: portrait.modulate = Color.WHITE if unlocked else Color(.58,.57,.49)
	if not unlocked:
		draw_circle(Vector2(64,8),10,Chronicle.NAVY)
		draw_arc(Vector2(64,5),4,PI,TAU,12,Chronicle.GOLD,2,true)
		draw_rect(Rect2(59,5,10,10),Chronicle.GOLD)
		draw_line(Vector2(64,8),Vector2(64,11),Chronicle.NAVY,2)
