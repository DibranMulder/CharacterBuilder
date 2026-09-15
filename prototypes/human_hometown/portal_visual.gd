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
	var core := Color("fff3be")
	var pulse := .88+.12*sin(time*1.8)
	var strength := .22 if sealed else 1.0
	# A wide pool of reflected gold anchors the portal to the floor.
	for layer in range(16,0,-1):
		var radius := 20.0+layer*3.3
		canvas.draw_colored_polygon(_oval(at+Vector2(0,-3),radius,.24),Color(gold,.045*pulse*strength))
	# Feathered columns fade upward, like the reference's rising light curtain.
	if not sealed:
		for i in 13:
			var x := float(i-6)*6.5
			var height := 76.0+32.0*sin(i*1.7+time*.65)
			var shimmer := .65+.35*sin(time*1.9+i*.9)
			var foot := at+Vector2(x,-5)
			var points := PackedVector2Array([foot+Vector2(-6,0),foot+Vector2(6,0),foot+Vector2(3,-height),foot+Vector2(-3,-height)])
			canvas.draw_polygon(points,PackedColorArray([Color(gold,.13*shimmer),Color(gold,.13*shimmer),Color(gold,0),Color(gold,0)]))
			var beam := PackedVector2Array([foot+Vector2(-1.1,0),foot+Vector2(1.1,0),foot+Vector2(.5,-height*.86),foot+Vector2(-.5,-height*.86)])
			canvas.draw_polygon(beam,PackedColorArray([Color(core,.6*shimmer),Color(core,.6*shimmer),Color(gold,0),Color(gold,0)]))
	# Nested luminous ellipses give the floor contact a clear, bright edge.
	for layer in range(5,0,-1):
		canvas.draw_polyline(_oval(at+Vector2(0,-5),43,.22),Color(gold,.065*pulse*strength),float(layer)*2.4,true)
	canvas.draw_polyline(_oval(at+Vector2(0,-5),43,.22),Color(core,.85*pulse*strength),1.8,true)
	canvas.draw_polyline(_oval(at+Vector2(0,-5),33,.20),Color(gold,.65*pulse*strength),1.2,true)
	if not sealed:
		for i in 12:
			var phase := fmod(time*.23+i/12.0,1.0)
			var point := at+Vector2(sin(i*2.4)*40+sin(time+i)*3,-7-phase*80)
			var alpha := sin(phase*PI)*.8
			canvas.draw_circle(point,3.2,Color(gold,alpha*.12))
			canvas.draw_circle(point,1.1,Color(core,alpha))

static func _oval(center: Vector2, radius: float, depth: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in 65:
		var angle := TAU*float(i)/64
		points.append(center+Vector2(cos(angle)*radius,sin(angle)*radius*depth))
	return points
