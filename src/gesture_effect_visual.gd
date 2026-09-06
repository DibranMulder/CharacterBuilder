class_name GestureEffectVisual
extends Node2D

const INK := Color("302a29")
const ARROW := preload("res://assets/equipment/arrow_projectile_storybook.png")
const BOLT := preload("res://assets/equipment/crossbow_bolt_storybook.png")

var effect_id := ""
var accent := Color("7ed9e8")
var progress := 0.0


func setup(p_effect_id: String, p_accent: Color) -> GestureEffectVisual:
	effect_id = p_effect_id
	accent = p_accent
	progress = 0.0
	queue_redraw()
	return self


func play() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_method(set_progress,0.0,1.0,.46)
	tween.tween_callback(queue_free)


func set_progress(value: float) -> void:
	progress = clampf(value,0.0,1.0)
	queue_redraw()


func _alpha(color: Color, amount: float) -> Color:
	var result := color
	result.a *= clampf(amount,0.0,1.0)
	return result


func _star(center: Vector2, outer_radius: float, inner_radius: float, points := 5, rotation := 0.0, color := Color.WHITE) -> void:
	var polygon := PackedVector2Array()
	for point_index in points*2:
		var radius := outer_radius if point_index%2 == 0 else inner_radius
		var angle := rotation+PI*float(point_index)/float(points)
		polygon.append(center+Vector2.from_angle(angle)*radius)
	draw_colored_polygon(polygon,color)
	draw_polyline(polygon+PackedVector2Array([polygon[0]]),_alpha(INK,color.a),2.0,true)


func _diamond(center: Vector2, size: Vector2, color: Color) -> void:
	var polygon := PackedVector2Array([
		center+Vector2(0,-size.y), center+Vector2(size.x,0),
		center+Vector2(0,size.y), center+Vector2(-size.x,0),
	])
	draw_colored_polygon(polygon,color)
	draw_polyline(polygon+PackedVector2Array([polygon[0]]),_alpha(INK,color.a),2.0,true)


func _streak(from: Vector2, to: Vector2, width: float, color: Color) -> void:
	draw_line(from,to,_alpha(INK,color.a),width+3.0,true)
	draw_line(from,to,color,width,true)


func _draw() -> void:
	var life := 1.0-progress
	var pulse := sin(progress*PI)
	var bright := accent.lightened(.42)
	match effect_id:
		"tongue_snap":
			var reach := sin(progress*PI)*118.0
			_streak(Vector2.ZERO,Vector2(reach,2),7.0,_alpha(Color("ef7f91"),life+.15))
			draw_circle(Vector2(reach,2),6.0,_alpha(Color("f4a0aa"),life+.15))
		"lily_leap":
			for ring_index in 3:
				var radius := 18.0+progress*72.0+ring_index*11.0
				draw_arc(Vector2.ZERO,radius,PI*.08,PI*.92,28,_alpha(accent.lightened(.2),life*.7),4.0-ring_index*.7,true)
			for side in [-1.0,1.0]:
				draw_circle(Vector2(side*(28.0+progress*35.0),-3),7.0,_alpha(Color("79b75a"),life))
		"bog_burst":
			for index in 8:
				var direction := Vector2.from_angle(TAU*float(index)/8.0)
				var center := direction*(12.0+progress*(42.0+index%3*8.0))
				draw_circle(center,6.0-index%2*1.5,_alpha(accent.lightened(.25),life*.8))
				draw_arc(center,7.0-index%2,0,TAU,16,_alpha(bright,life),2.0,true)
		"crosscut":
			for direction in [-1.0,1.0]:
				var angle: float = float(direction)*.62
				var axis: Vector2 = Vector2.from_angle(angle)
				_streak(-axis*(18.0+progress*22.0),axis*(42.0+progress*30.0),5.0,_alpha(bright,life))
		"shield_rush":
			for index in 3:
				var x := progress*95.0-index*18.0
				var chevron := PackedVector2Array([Vector2(x-16,-24),Vector2(x+5,0),Vector2(x-16,24)])
				draw_polyline(chevron,_alpha(accent.lightened(.35),life*(1.0-index*.2)),5.0,true)
		"heroic_vault":
			draw_arc(Vector2(0,24),48.0,-PI*.92,-PI*.08,32,_alpha(Color("f1cf72"),life),7.0,true)
			_star(Vector2(38,-8),8.0,3.5,5,progress*TAU,_alpha(bright,life))
		"gallop_shot", "snap_shot":
			var projectile: Texture2D = BOLT if effect_id == "snap_shot" else ARROW
			draw_texture(projectile,Vector2(-34+progress*175.0,-float(projectile.get_height())*.5))
			for index in 3:
				_streak(Vector2(-28-index*13,-5+index*5),Vector2(progress*105.0-index*18,-5+index*5),2.0,_alpha(accent.lightened(.3),life*.5))
		"rearing_strike":
			draw_arc(Vector2(25,5),30.0,-PI*.72,PI*.32,28,_alpha(Color("d5b17b"),life),8.0,true)
			for index in 5:
				draw_circle(Vector2(-15+index*14,-progress*(18+index*3)),4.0,_alpha(Color("b99563"),life))
		"grove_tempest":
			for index in 9:
				var angle := TAU*float(index)/9.0+progress*TAU*.75
				var center := Vector2.from_angle(angle)*(20.0+progress*45.0)
				var leaf := PackedVector2Array([center+Vector2(-7,0).rotated(angle),center+Vector2(0,-4).rotated(angle),center+Vector2(8,0).rotated(angle),center+Vector2(0,4).rotated(angle)])
				draw_colored_polygon(leaf,_alpha(Color("79b85d"),life))
				draw_polyline(leaf+PackedVector2Array([leaf[0]]),_alpha(INK,life),1.5,true)
		"wand_arc":
			draw_arc(Vector2.ZERO,35.0+progress*26.0,-PI*.85,PI*.35,30,_alpha(bright,life),7.0,true)
			for index in 3:
				_star(Vector2.from_angle(-1.9+index*.55)*(42.0+progress*28.0),6.0,2.5,4,progress*TAU,_alpha(accent.lightened(.48),life))
		"gale_step":
			for index in 4:
				var y := -24.0+index*16.0
				draw_arc(Vector2(progress*42.0-index*9.0,y),30.0+index*5.0,-PI*.35,PI*.42,20,_alpha(Color("c6edf0"),life*(.9-index*.13)),4.0,true)
		"star_bloom":
			for index in 7:
				var angle := TAU*float(index)/7.0
				_star(Vector2.from_angle(angle)*(10.0+progress*52.0),8.0-index%2*2.0,3.0,5,angle+progress*TAU,_alpha(Color("ffd979"),life))
		"glacier_cleave":
			for index in 5:
				var x := -30.0+index*18.0
				_diamond(Vector2(x,-progress*(32.0+index%2*18.0)),Vector2(7,18+index%2*6),_alpha(Color("9ce4f4"),life))
		"boulder_rush":
			for index in 6:
				var center := Vector2(progress*(55.0+index*8.0)-20.0,-8.0-index%3*12.0)
				var rock := PackedVector2Array([center+Vector2(-8,-5),center+Vector2(-2,-10),center+Vector2(9,-4),center+Vector2(7,7),center+Vector2(-6,8)])
				draw_colored_polygon(rock,_alpha(Color("8293a0"),life))
				draw_polyline(rock+PackedVector2Array([rock[0]]),_alpha(INK,life),2.0,true)
		"avalanche":
			for index in 10:
				var angle := TAU*float(index)/10.0
				var center := Vector2.from_angle(angle)*(12.0+progress*(35.0+index%4*7.0))+Vector2(0,progress*28.0)
				draw_circle(center,5.0+index%3,_alpha(Color("d7edf2"),life*.9))
		"low_blow":
			draw_arc(Vector2(15,10),42.0+progress*22.0,PI*.12,PI*.88,30,_alpha(Color("f0c56c"),life),8.0,true)
			_streak(Vector2(-30,20),Vector2(62,-3),3.0,_alpha(bright,life*.7))
		"powder_keg":
			var radius := 18.0+progress*52.0
			for index in 12:
				var direction := Vector2.from_angle(TAU*float(index)/12.0)
				var length := radius*(1.25 if index%2 == 0 else .78)
				_streak(direction*8.0,direction*length,6.0,_alpha(Color("f49a45" if index%2 == 0 else "ffd36d"),life))
			draw_circle(Vector2.ZERO,20.0*pulse,_alpha(Color("fff2b0"),life))
		"sirocco_thrust":
			for index in 6:
				var y := -25.0+index*10.0
				var start := Vector2(-30-index*5,y)
				var end := Vector2(35+progress*(65+index*5),y+sin(index)*8.0)
				_streak(start,end,3.0,_alpha(Color("ddb36c"),life*(1.0-index*.08)))
		"crescent_guard":
			draw_arc(Vector2.ZERO,34.0+progress*24.0,-PI*.62,PI*.62,36,_alpha(Color("efd28a"),life),10.0,true)
			draw_arc(Vector2(4,0),23.0+progress*19.0,-PI*.62,PI*.62,36,_alpha(Color("fff4ca"),life*.8),3.0,true)
		"sand_veil":
			for index in 14:
				var angle := TAU*float(index)/14.0+progress*2.4
				var radius := 18.0+float(index%5)*8.0+progress*20.0
				draw_circle(Vector2.from_angle(angle)*radius,2.5+index%3,_alpha(Color("d9ae68"),life*.8))
		"crystal_jab":
			var tip_x := 35.0+progress*82.0
			var shard := PackedVector2Array([Vector2(-12,-7),Vector2(tip_x,0),Vector2(-12,7),Vector2(3,0)])
			draw_colored_polygon(shard,_alpha(Color("8ce3f5"),life))
			draw_polyline(shard+PackedVector2Array([shard[0]]),_alpha(INK,life),2.0,true)
		"aurora_pulse":
			for index in 3:
				var radius := 16.0+progress*(45.0+index*17.0)
				var color: Color = [Color("77e6d1"),Color("76bff2"),Color("b58af0")][index]
				draw_arc(Vector2.ZERO,radius,0,TAU,40,_alpha(color,life*(1.0-index*.18)),6.0-index,true)
		"snowdrift":
			for index in 12:
				var x := -55.0+float((index*23)%110)
				var y := -42.0+progress*(75.0+index%4*12.0)
				_star(Vector2(x,y),4.5,1.7,6,progress+index,_alpha(Color("eaf8ff"),life))
