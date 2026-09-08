extends StyleBox
## Internal drawing implementation for scalable notched brass/leather frames.
var fill := Color("183454")
var border := Color("c79b48")
var pressed := false
var disabled := false
var focus_only := false
var parchment := false

func _outline(rect: Rect2, notch: float) -> PackedVector2Array:
	var p := rect.position
	var e := rect.end
	return PackedVector2Array([p+Vector2(notch,0),Vector2(e.x-notch,p.y),Vector2(e.x,p.y+notch),Vector2(e.x-2,rect.get_center().y),Vector2(e.x,e.y-notch),e-Vector2(notch,0),Vector2(p.x+notch,e.y),Vector2(p.x,e.y-notch),Vector2(p.x+2,rect.get_center().y),p+Vector2(0,notch)])

func _stroke(canvas: RID, points: PackedVector2Array, color: Color, width := 1.0) -> void:
	var closed := points.duplicate()
	closed.append(points[0])
	RenderingServer.canvas_item_add_polyline(canvas,closed,PackedColorArray([color]),width,true)

func _draw(canvas: RID, rect: Rect2) -> void:
	var outer := rect.grow(-2)
	var points := _outline(outer,5)
	if focus_only:
		_stroke(canvas,_outline(rect.grow(-.5),6),Color("72d6e5"),2)
		_stroke(canvas,_outline(rect.grow(-4),4),Color("72d6e5"),1)
		return
	var shades := PackedColorArray()
	for point in points:
		var depth := (point.y-outer.position.y)/outer.size.y
		shades.append(fill.lightened(.08).lerp(fill.darkened(.16),depth if not pressed else 1-depth))
	RenderingServer.canvas_item_add_polygon(canvas,points,shades)
	# Fine material grain: deterministic, without tiling seams or raster scaling.
	var rng := RandomNumberGenerator.new()
	rng.seed = 31
	for i in mini(600,int(rect.size.x*rect.size.y/65)):
		var at := rect.position + Vector2(rng.randf_range(7,rect.size.x-7),rng.randf_range(6,rect.size.y-6))
		RenderingServer.canvas_item_add_circle(canvas,at,rng.randf_range(.3,.85),Color(1,.87,.56,.045))
	_stroke(canvas,points,border,1.5)
	_stroke(canvas,_outline(outer.grow(-3),3),Color(border,.5),1)
	var top_color := border.lightened(.25) if not pressed else border.darkened(.35)
	RenderingServer.canvas_item_add_line(canvas,outer.position+Vector2(7,1),Vector2(outer.end.x-7,outer.position.y+1),top_color,1,true)
	RenderingServer.canvas_item_add_line(canvas,Vector2(outer.position.x+7,outer.end.y-1),outer.end-Vector2(7,1),border.darkened(.45),2,true)
	if not disabled:
		for at in [outer.position+Vector2(4,5),Vector2(outer.end.x-4,outer.position.y+5),outer.end-Vector2(4,5),Vector2(outer.position.x+4,outer.end.y-5)]:
			var gem := PackedVector2Array([at+Vector2(0,-2),at+Vector2(2,0),at+Vector2(0,2),at-Vector2(2,0)])
			RenderingServer.canvas_item_add_polygon(canvas,gem,PackedColorArray([border.lightened(.2)]))
	if parchment:
		for at in [outer.position+Vector2(13,13),outer.end-Vector2(13,13)]:
			var direction := 1 if at.x < rect.get_center().x else -1
			for leaf in 4:
				var stem: Vector2 = at+Vector2(leaf*8,leaf*6)*direction
				RenderingServer.canvas_item_add_line(canvas,at,stem,Color("929568"),1,true)
				RenderingServer.canvas_item_add_polygon(canvas,PackedVector2Array([stem,stem+Vector2(2,-8)*direction,stem+Vector2(7,-10)*direction,stem+Vector2(6,-3)*direction]),PackedColorArray([Color("929568")]))
