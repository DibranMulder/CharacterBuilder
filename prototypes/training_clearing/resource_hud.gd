extends Node2D
## Compact portrait/HP/MP/XP composition from npc-interaction-mockup.png.
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
var model
var player_name := ""
var show_guard := true
var font: Font = Chronicle.create().get_font("font","ChronicleHeading")
var portrait := preload("res://src/ui/character_portrait.gd").new()
var badge := Node2D.new()
const CENTER := Vector2(64,68)

func _init() -> void:
	z_index = 200

func _ready() -> void:
	portrait.position = CENTER
	portrait.z_index = 1
	add_child(portrait)
	badge.z_index = 2
	add_child(badge)
	badge.draw.connect(_draw_level)

func set_character(race_id: String, loadout: Dictionary) -> void:
	portrait.configure(race_id,loadout)
	queue_redraw()

func _text(value: String, at: Vector2, size: int, color := Chronicle.IVORY) -> void:
	draw_string_outline(font,at,value,0,-1,size,2,Chronicle.NAVY)
	draw_string(font,at,value,0,-1,size,color)

func _bar(rect: Rect2, fraction: float, color: Color, caption: String, size := 12) -> void:
	var frame := StyleBoxFlat.new()
	frame.bg_color = Chronicle.NAVY
	frame.border_color = Chronicle.BRASS
	frame.set_border_width_all(1)
	frame.set_corner_radius_all(2)
	draw_style_box(frame,rect)
	var inner := rect.grow(-3)
	inner.size.x *= clampf(fraction,0,1)
	if inner.size.x > 0:
		var tip := minf(4,inner.size.x*.25)
		var points := PackedVector2Array([inner.position,Vector2(inner.end.x-tip,inner.position.y),Vector2(inner.end.x,inner.get_center().y),Vector2(inner.end.x-tip,inner.end.y),Vector2(inner.position.x,inner.end.y)])
		draw_polygon(points,PackedColorArray([color.lightened(.2),color.lightened(.2),color,color.darkened(.3),color.darkened(.3)]))
		draw_line(inner.position+Vector2(1,0),Vector2(inner.end.x-tip,inner.position.y),color.lightened(.45),1,true)
	var width := font.get_string_size(caption,0,-1,size).x
	_text(caption,rect.get_center()+Vector2(-width*.5,size*.34),size)

func _draw() -> void:
	if model == null:
		return
	# Only a narrow backing behind the name and bars; the world remains visible.
	draw_style_box(Chronicle.create().get_stylebox("panel","InkPanel"),Rect2(88,14,228,94))
	_text(player_name,Vector2(116,33),16,Chronicle.PARCHMENT)
	_bar(Rect2(112,41,196,20),model.health/100.0,Color("b84f36"),"%d / 100" % ceil(model.health))
	_bar(Rect2(112,65,196,20),model.mana/100.0,Color("24649f"),"%d / 100" % floor(model.mana))
	var progress: float = float(model.xp)/model.xp_required()
	_bar(Rect2(112,89,196,12),progress,Color("698345"),"%d%%" % floor(progress*100),9)
	# Layered brass medallion and engraved rim, not a generic circular outline.
	draw_circle(CENTER,55,Color("574126"))
	draw_circle(CENTER,53,Chronicle.BRASS)
	draw_circle(CENTER,50,Color("20353a"))
	draw_arc(CENTER,54,0,TAU,100,Chronicle.GOLD,1,true)
	draw_arc(CENTER,51,0,TAU,100,Color("f3df9d"),1,true)
	for i in 24:
		var axis := Vector2.from_angle(i*TAU/24)
		draw_line(CENTER+axis*51,CENTER+axis*53,Color("7c602f"),1,true)
	# The foliage is kept outside the portrait, following the reference silhouette.
	for i in 7:
		var angle := 2.5+i*.17
		var at := CENTER+Vector2.from_angle(angle)*57
		var tangent := Vector2.from_angle(angle+PI*.5)
		var outward := Vector2.from_angle(angle)
		draw_line(at,at+tangent*10,Chronicle.BRASS,1,true)
		draw_colored_polygon(PackedVector2Array([at,at+outward*7+tangent*3,at+outward*5+tangent*12,at+tangent*9]),Color("b9954d"))
	if show_guard:
		_bar(Rect2(366,600,300,18),model.stamina/100.0,Chronicle.TEAL,"GUARD  %d / 100" % model.stamina,11)
	badge.queue_redraw()

func _draw_level() -> void:
	if model == null:
		return
	var center := Vector2(35,115)
	var shape := PackedVector2Array()
	for i in 6:
		shape.append(center+Vector2.from_angle(i*TAU/6+PI/6)*21)
	badge.draw_colored_polygon(shape,Chronicle.NAVY)
	shape.append(shape[0])
	badge.draw_polyline(shape,Chronicle.BRASS,3,true)
	var value := str(model.adventure_level)
	var width := font.get_string_size(value,0,-1,23).x
	badge.draw_string(font,center+Vector2(-width*.5,8),value,0,-1,23,Chronicle.GOLD)
