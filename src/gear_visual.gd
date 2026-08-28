class_name GearVisual
extends Node2D

var slot := "weapon"
var item := "none"
var accent := Color("d7a54f")
var carried_on_back := false
var shield_exterior := false
var pants_piece := "full"
var pants_length := 30.0

const REACH_ENDPOINTS := {
	"sword": Vector2(0, 88),
	"axe": Vector2(30, 92),
	"bow": Vector2(18, 80),
	"spear": Vector2(0, 126),
	"staff": Vector2(0, 126),
}

const INK := Color("352b25")
const POLE_BUTT := Vector2(0,-72)
const SHIELD_CENTER := Vector2(0,-20)


func _outlined_polygon(points: PackedVector2Array, fill: Color, width := 2.5) -> void:
	draw_colored_polygon(points, fill)
	draw_polyline(points + PackedVector2Array([points[0]]), INK, width, true)


func setup(p_slot: String, p_item: String, p_accent: Color) -> GearVisual:
	slot = p_slot
	item = p_item
	accent = p_accent
	visible = item != "none"
	queue_redraw()
	return self


func reach_endpoint() -> Vector2:
	return REACH_ENDPOINTS.get(item, Vector2.ZERO)


func set_carried_on_back(enabled: bool) -> void:
	carried_on_back = enabled
	queue_redraw()


func set_shield_exterior(enabled: bool) -> void:
	shield_exterior = enabled
	queue_redraw()


func set_pants_piece(piece: String, length := 30.0) -> GearVisual:
	pants_piece = piece
	pants_length = length
	queue_redraw()
	return self


func _draw() -> void:
	var ink := INK
	var metal := Color("cbd4d8")
	match slot:
		"weapon":
			match item:
				"sword":
					draw_line(Vector2(0, 10), Vector2(0, 72), metal, 9.0, true)
					draw_colored_polygon(PackedVector2Array([Vector2(-4,72), Vector2(0,88), Vector2(4,72)]), metal)
					draw_line(Vector2(-13,8), Vector2(13,8), accent, 6.0, true)
					draw_line(Vector2.ZERO, Vector2(0,-12), Color("70472b"), 7.0, true)
				"axe":
					draw_line(Vector2.ZERO, Vector2(0, 82), Color("70472b"), 8.0, true)
					draw_colored_polygon(PackedVector2Array([Vector2(0,80), Vector2(30,92), Vector2(27,65), Vector2(0,62)]), metal)
				"bow":
					draw_arc(Vector2(18,40), 40, PI/2, PI*1.5, 20, Color("8a5c34"), 5.0)
					draw_line(Vector2(18,0), Vector2(18,80), Color("e8dcc6"), 2.0)
				"spear":
					draw_line(POLE_BUTT, Vector2(0,110), Color("795033"), 6.0, true)
					draw_colored_polygon(PackedVector2Array([Vector2(-8,105), Vector2(0,126), Vector2(8,105)]), metal)
				"staff":
					draw_line(POLE_BUTT, Vector2(0,108), Color("6f4c31"), 7.0, true)
					draw_circle(Vector2(0,114), 12, accent.lightened(.15))
		"offhand":
			match item:
				"shield":
					var center := SHIELD_CENTER
					if carried_on_back or shield_exterior:
						# A back-mounted shield presents its exterior toward the rear camera.
						draw_circle(center,27,Color("8f6337"))
						draw_circle(center,20,Color("a87842"))
						draw_arc(center,27,0,TAU,24,metal,5.0)
						draw_circle(center,7,accent)
					else:
						# The wielded far-side shield presents its inside straps and grip.
						draw_circle(center, 27, Color("68462f"))
						draw_circle(center, 21, Color("815a3b"))
						draw_arc(center, 27, 0, TAU, 24, metal.darkened(.12), 5.0)
						# Bias straps toward the half exposed beyond the torso.
						draw_line(center + Vector2(-20,-10), center + Vector2(3,8), Color("3e2b22"), 7.0, true)
						draw_line(center + Vector2(-18,12), center + Vector2(3,-10), Color("ad7b4b"), 4.0, true)
						for rivet in [Vector2(-17,-12), Vector2(17,-12), Vector2(-17,12), Vector2(17,12)]:
							draw_circle(center + rivet, 2.5, metal)
				"lantern":
					draw_rect(Rect2(-13,-44,26,31), Color("f4b942"), true)
					draw_rect(Rect2(-13,-44,26,31), ink, false, 4.0)
				"spellbook":
					draw_rect(Rect2(-22,-48,44,35), accent.darkened(.2), true)
					draw_line(Vector2(0,-48), Vector2(0,-13), Color("f0dfb8"), 2.0)
		"armor":
			var armor_color: Color = {"cloth": accent, "leather": Color("754b32"), "plate": metal}.get(item, accent)
			var tunic := PackedVector2Array([Vector2(-31,4),Vector2(31,4),Vector2(27,39),Vector2(35,66),Vector2(4,58),Vector2(0,70),Vector2(-5,58),Vector2(-35,66),Vector2(-27,39)])
			_outlined_polygon(tunic,armor_color)
			# Layered shoulder pieces and a wide belt give the small silhouette the
			# same readable fantasy-adventurer language as the supplied painting.
			draw_arc(Vector2(-25,10),13,PI*.72,TAU*.92,10,INK,9.0,true)
			draw_arc(Vector2(-25,10),13,PI*.72,TAU*.92,10,armor_color.lightened(.12),5.5,true)
			draw_arc(Vector2(25,10),13,PI*.08,PI*.32,10,INK,9.0,true)
			draw_arc(Vector2(25,10),13,PI*.08,PI*.32,10,armor_color.lightened(.12),5.5,true)
			draw_rect(Rect2(-28,35,56,10),Color("5a3b29"),true)
			draw_rect(Rect2(-28,35,56,10),INK,false,2.2)
			draw_rect(Rect2(-6,34,12,12),Color("d2a849"),true)
			draw_rect(Rect2(-6,34,12,12),INK,false,2.0)
			draw_line(Vector2(-25,19),Vector2(25,19),armor_color.darkened(.24),2.5)
			if item == "plate":
				draw_line(Vector2(0,6),Vector2(0,34),ink,2.0)
				draw_arc(Vector2(0,20),19,0,PI,12,Color("f6fbfa"),1.5)
		"pants":
			var pants_color: Color = {"cloth": accent.darkened(.2), "leather": Color("65412e"), "plate": metal.darkened(.1)}.get(item, accent)
			if pants_piece == "waist":
				draw_rect(Rect2(-25,-2,50,15),pants_color,true)
				draw_rect(Rect2(-25,-2,50,15),INK,false,2.2)
				_outlined_polygon(PackedVector2Array([Vector2(-23,11),Vector2(23,11),Vector2(14,21),Vector2(5,17),Vector2(0,24),Vector2(-5,17),Vector2(-14,21)]),pants_color,1.4)
				draw_line(Vector2(-25,11),Vector2(25,11),ink,1.5)
			elif pants_piece in ["thigh","shin"]:
				var width := 21.0 if pants_piece == "thigh" else 18.0
				var covered_length := pants_length*.98
				draw_line(Vector2.ZERO,Vector2(0,covered_length),INK,width+2.0,true)
				draw_line(Vector2.ZERO,Vector2(0,covered_length),pants_color,width,true)
				draw_line(Vector2(-width*.42,covered_length*.82),Vector2(width*.42,covered_length*.82),pants_color.darkened(.18),2.0,true)
				if item == "plate":
					draw_line(Vector2(-width*.32,4),Vector2(-width*.32,covered_length-3),Color("f5faf9"),1.5,true)
			else:
				draw_rect(Rect2(-25,-2,50,16),pants_color,true)
				draw_rect(Rect2(-25,-2,50,16),INK,false,2.2)
		"head":
			match item:
				"hood":
					draw_arc(Vector2(0,-17), 34, PI, TAU, 20, accent.darkened(.2), 15.0)
				"helm":
					draw_arc(Vector2(0,-17), 32, PI, TAU, 20, metal, 14.0)
					draw_line(Vector2(0,-50), Vector2(0,-12), ink, 4.0)
				"crown":
					draw_colored_polygon(PackedVector2Array([Vector2(-27,-35),Vector2(-24,-58),Vector2(-9,-44),Vector2(0,-65),Vector2(10,-44),Vector2(25,-58),Vector2(27,-35)]), Color("e1b84a"))
		"back":
			match item:
				"cape":
					var cape := PackedVector2Array([Vector2(-25,5),Vector2(25,5),Vector2(31,45),Vector2(40,88),Vector2(15,82),Vector2(0,94),Vector2(-17,82),Vector2(-38,90),Vector2(-30,45)])
					_outlined_polygon(cape,accent.darkened(.18),3.0)
					draw_line(Vector2(-18,12),Vector2(18,12),accent.lightened(.18),3.0)
				"pack": draw_rect(Rect2(-34,14,68,65), Color("725238"), true)
				"quiver":
					draw_line(Vector2(-20,65),Vector2(20,-35),Color("70472b"),18.0)
					for x in [-8, 0, 8]: draw_line(Vector2(x,0),Vector2(x,-43),Color("d5c29c"),3.0)
		"accessory":
			match item:
				"scarf":
					draw_line(Vector2(-27,2), Vector2(27,2), accent, 12.0, true)
					draw_colored_polygon(PackedVector2Array([Vector2(18,3),Vector2(42,42),Vector2(25,35)]), accent)
				"amulet":
					draw_arc(Vector2(0,0), 21, 0.2, PI-.2, 16, Color("e3c978"), 2.0)
					draw_circle(Vector2(0,20),6,accent)
				"goggles":
					draw_circle(Vector2(-13,-25),10,Color("6fd3db")); draw_circle(Vector2(13,-25),10,Color("6fd3db")); draw_line(Vector2(-3,-25),Vector2(3,-25),ink,4)
