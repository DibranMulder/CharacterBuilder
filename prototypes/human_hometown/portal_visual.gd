extends Node2D
## Ground light marks the physical travel trigger without covering the scenery.
var locked := false
var elapsed := 0.0

func present(at: Vector2, sealed: bool, delta: float) -> void:
	position = at
	locked = sealed
	elapsed += delta
	visible = at.x > -100 and at.x < 1252
	if visible: queue_redraw()

func _draw() -> void:
	paint(self,Vector2.ZERO,locked,elapsed)

static func paint(canvas: CanvasItem, at: Vector2, sealed: bool, time: float) -> void:
	var gold := Color("ffc95b")
	var core := Color("fff8d9")
	var pulse := .92+.08*sin(time*1.8)
	var strength := .22 if sealed else 1.0
	# A wide pool of reflected gold anchors the portal to the floor.
	for layer in range(16,0,-1):
		var radius := 20.0+layer*(3.3 if sealed else 4.6)
		canvas.draw_colored_polygon(_oval(at+Vector2(0,-3),radius,.24),Color(gold,(.045 if sealed else .10)*pulse*strength))
	if not sealed:
		canvas.draw_colored_polygon(_oval(at+Vector2(0,-4),35,.20),Color(core,.34*pulse))
	# Feathered columns fade upward, like the reference's rising light curtain.
	if not sealed:
		for i in 13:
			var x := float(i-6)*6.5
			var height := 120.0+38.0*sin(i*1.7+time*.65)
			var shimmer := .80+.20*sin(time*1.9+i*.9)
			var foot := at+Vector2(x,-5)
			var points := PackedVector2Array([foot+Vector2(-6,0),foot+Vector2(6,0),foot+Vector2(3,-height),foot+Vector2(-3,-height)])
			canvas.draw_polygon(points,PackedColorArray([Color(gold,.26*shimmer),Color(gold,.26*shimmer),Color(gold,0),Color(gold,0)]))
			var beam := PackedVector2Array([foot+Vector2(-1.8,0),foot+Vector2(1.8,0),foot+Vector2(.5,-height*.86),foot+Vector2(-.5,-height*.86)])
			canvas.draw_polygon(beam,PackedColorArray([Color(core,.9*shimmer),Color(core,.9*shimmer),Color(gold,0),Color(gold,0)]))
	# Nested luminous ellipses give the floor contact a clear, bright edge.
	for layer in range(5,0,-1):
		canvas.draw_polyline(_oval(at+Vector2(0,-5),43,.22),Color(gold,.14*pulse*strength),float(layer)*3.5,true)
	canvas.draw_polyline(_oval(at+Vector2(0,-5),43,.22),Color(core,pulse*strength),3.0,true)
	canvas.draw_polyline(_oval(at+Vector2(0,-5),33,.20),Color(core,.85*pulse*strength),2.0,true)
	if not sealed:
		for i in 12:
			var phase := fmod(time*.23+i/12.0,1.0)
			var point := at+Vector2(sin(i*2.4)*40+sin(time+i)*3,-7-phase*115)
			var alpha := sin(phase*PI)*.8
			canvas.draw_circle(point,5.0,Color(gold,alpha*.24))
			canvas.draw_circle(point,1.5,Color(core,alpha))

static func _oval(center: Vector2, radius: float, depth: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 65:
		var angle := TAU*float(i)/64
		points.append(center+Vector2(cos(angle)*radius,sin(angle)*radius*depth))
	return points
