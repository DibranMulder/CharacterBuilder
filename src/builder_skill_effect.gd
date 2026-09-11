extends Node2D
## Procedural preview flourishes; blade ribbons use the real weapon trail.
var kind := "spark"
var progress := 0.0

func set_progress(value: float) -> void:
	progress = clampf(value,0.0,1.0)
	queue_redraw()

func _draw() -> void:
	var gold := Color("efbd62")
	gold.a = sin(PI * progress)
	var ivory := Color("fff0c2")
	ivory.a = gold.a
	_draw_flourish(gold,ivory)
	match kind:
		"rally":
			for i in 5:
				var x := (i - 2) * 24.0
				var y := -90.0 - sin(progress * PI) * 20.0 + absf(i-2) * 8.0
				draw_colored_polygon(PackedVector2Array([Vector2(x-8,y+30),Vector2(x-8,y),Vector2(x+9,y+4),Vector2(x+3,y+12),Vector2(x-5,y+9)]),gold)
			draw_arc(Vector2.ZERO,63,-PI*.95,-PI*.05,48,gold,3,true)
			draw_arc(Vector2.ZERO,60,0,PI,48,Color(gold,.13*gold.a),8,true)
		"heal":
			for side in [-1,1]:
				var vine := PackedVector2Array()
				for i in 7:
					var t := i / 6.0
					var p := Vector2(side*(43+sin(t*PI)*20),38-t*116)
					vine.append(p)
					var direction := Vector2(side*12,-13)
					var normal := direction.orthogonal().normalized()*4.5
					draw_colored_polygon(PackedVector2Array([p,p+direction*.3+normal,p+direction*.7+normal,p+direction,p+direction*.7-normal,p+direction*.3-normal]),gold)
				draw_polyline(vine,Color(gold,gold.a*.65),1.5,true)
			for i in 4:
				var y := 20-fmod(progress*120+i*25,100)
				draw_circle(Vector2(sin(i*2.4+progress*4)*25,y),2.5,ivory)
		"rush":
			for i in 4:
				var x := -progress*55-i*15
				draw_line(Vector2(x,-15+i*10),Vector2(x-24,-12+i*10),gold,4-i*.6,true)
			draw_polyline(PackedVector2Array([Vector2(-22,-30),Vector2(12,0),Vector2(-22,30)]),ivory,4,true)
		"crown":
			var points := PackedVector2Array()
			for i in 9:
				points.append(Vector2(-64+i*16,-65-(23 if i%2 == 1 else 0)))
			draw_polyline(points,gold,4,true)
			for i in 5:
				draw_line(Vector2(-55+i*27,-96),Vector2(-55+i*27,-103),ivory,2,true)
		"guard":
			draw_arc(Vector2.ZERO,24+progress*14,0,TAU,40,gold,4,true)
			draw_arc(Vector2.ZERO,18+progress*8,-PI*.8,PI*.6,30,ivory,2,true)
		"slash", "quick", "heavy", "sweep", "pommel", "cross_first", "cross_second":
			pass # Authored below; no generic burst over the distinct stroke.
		_:
			for i in 7:
				var direction := Vector2.from_angle(i*TAU/7)
				draw_line(direction*(3+progress*6),direction*(10+progress*19),ivory,2,true)

func _draw_flourish(gold: Color, ivory: Color) -> void:
	if progress <= 0.0 or progress >= 1.0:
		return
	match kind:
		"rally":
			_ellipse(Vector2(0,4),Vector2(65,88)*(.85+.15*sin(progress*PI)),Color(gold,gold.a*.65),2.4)
			_ellipse(Vector2(0,94),Vector2(76,13),Color(gold,gold.a*.65),2)
			_ellipse(Vector2(0,94),Vector2(86,17),Color(gold,gold.a*.25),1)
			for side in [-1,1]:
				for i in 7:
					var p := Vector2(side*(57+sin(i*.5)*8),66-i*19.0-progress*15)
					_leaf(p,Vector2(side*9,-12),Color(gold,gold.a*.6))
		"heal":
			for i in 3:
				var ribbon := PackedVector2Array()
				for j in 41:
					var t := j/40.0
					ribbon.append(Vector2(sin(t*TAU+progress*TAU+i*2)*(44-t*25),65-t*125))
				draw_polyline(ribbon,Color(gold,gold.a*.08),10,true)
				draw_polyline(ribbon,Color(ivory,ivory.a*.35),1.8,true)
			for i in 12:
				var t := fposmod(progress*1.4+i/12.0,1.0)
				var p := Vector2(sin(i*2.4+t*3)*42,62-t*140)
				draw_circle(p,1.8,Color(ivory,ivory.a*sin(t*PI)))
			_ellipse(Vector2(0,94),Vector2(64+sin(progress*PI*3)*4,12),Color(gold,gold.a*.45),2)
		"rush":
			var wedge := PackedVector2Array([Vector2(-23,-46),Vector2(22,-12),Vector2(29,0),Vector2(22,12),Vector2(-23,46)])
			draw_polyline(wedge,Color(gold,gold.a*.12),16,true)
			draw_polyline(wedge,Color(gold,gold.a*.65),3,true)
			for i in 9:
				var p := Vector2(-25-i*10-progress*30,83-sin(progress*PI)*(4+i%3*5))
				_ellipse(p,Vector2(7+progress*9,3+progress*4),Color(.75,.46,.24,gold.a*.35),2)
		"crown":
			for side in [-1,1]:
				for i in 5:
					_leaf(Vector2(side*(54+i*4),-28-i*13),Vector2(side*13,-13),Color(gold,gold.a*.75))
			_burst(Vector2(0,-85),13,68,gold)
			_ellipse(Vector2(0,94),Vector2(75,13),Color(gold,gold.a*.6),2.5)
		"guard":
			_ellipse(Vector2.ZERO,Vector2(31,43)*(1.0+progress*.3),Color(gold,gold.a*.65),2)
			_burst(Vector2(22,-8),8,28,ivory)
		"cross_first", "cross_second":
			_stroke(Vector2.ZERO,-.7 if kind == "cross_first" else .7,39,6,gold,ivory)
			_burst(Vector2.ZERO,5,23,ivory)
		"slash":
			_stroke(Vector2.ZERO,-.7,32,4,ivory,ivory)
			_burst(Vector2.ZERO,5,22,gold)
		"quick":
			_stroke(Vector2.ZERO,-.5,44,3,ivory,ivory)
			for i in 3:
				_stroke(Vector2(-18-i*9,10+i*7),-.5,16,1.5,gold,ivory)
			_burst(Vector2.ZERO,6,24,ivory)
		"heavy":
			_stroke(Vector2.ZERO,1.0,52,9,gold,ivory)
			_ellipse(Vector2.ZERO,Vector2(1,.65)*(12+progress*43),Color(gold,gold.a*.6),3)
			_burst(Vector2.ZERO,11,56,gold)
			_burst(Vector2.ZERO,6,26,ivory)
		"sweep":
			for i in 3:
				var arc := PackedVector2Array()
				for j in 33:
					var angle := -.9+j/32.0*2.1
					arc.append(Vector2(-36,0)+Vector2(cos(angle)*(52+i*9),sin(angle)*(27+i*5)))
				draw_polyline(arc,Color(gold,gold.a*(.65-i*.16)),4.0-i,true)
			_burst(Vector2.ZERO,7,35,ivory)
		"pommel":
			_ellipse(Vector2.ZERO,Vector2.ONE*(10+progress*22),gold,3)
			for i in 4:
				_stroke(Vector2.from_angle(i*PI/2)*(9+progress*16),i*PI/2,8,4,gold,ivory)

func _ellipse(center: Vector2, radius: Vector2, color: Color, width: float) -> void:
	var points := PackedVector2Array()
	for i in 65:
		points.append(center+Vector2.from_angle(i*TAU/64)*radius)
	draw_polyline(points,color,width,true)

func _stroke(center: Vector2, angle: float, length: float, width: float, color: Color, core: Color) -> void:
	var axis := Vector2.from_angle(angle)
	var normal := axis.orthogonal()*width
	var extent := length*(.65+progress*.5)
	draw_colored_polygon(PackedVector2Array([center-axis*extent,center-axis*extent*.18+normal,center+axis*extent,center+axis*extent*.12-normal]),Color(color,color.a*.65))
	draw_line(center-axis*extent*.7,center+axis*extent*.8,core,1.5,true)

func _burst(center: Vector2, count: int, radius: float, color: Color) -> void:
	for i in count:
		var axis := Vector2.from_angle(i*2.39996+.2)
		var travel := (8+progress*radius)*(.7+(i%3)*.15)
		var p := center+axis*travel+Vector2(0,progress*progress*12)
		draw_line(p-axis*(7*(1-progress)+2),p,color,1.5+(i%2),true)
		if i%3 == 0:
			draw_circle(p,2*(1-progress)+.4,color)

func _leaf(p: Vector2, direction: Vector2, color: Color) -> void:
	var normal := direction.orthogonal().normalized()*4.5
	draw_colored_polygon(PackedVector2Array([p,p+direction*.4+normal,p+direction,p+direction*.4-normal]),color)
