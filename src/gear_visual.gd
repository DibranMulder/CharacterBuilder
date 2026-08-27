class_name GearVisual
extends Node2D

var slot := "weapon"
var item := "none"
var accent := Color("d7a54f")

const REACH_ENDPOINTS := {
	"sword": Vector2(0, 88),
	"axe": Vector2(30, 92),
	"bow": Vector2(18, 80),
	"spear": Vector2(0, 126),
	"staff": Vector2(0, 120),
}


func setup(p_slot: String, p_item: String, p_accent: Color) -> GearVisual:
	slot = p_slot
	item = p_item
	accent = p_accent
	visible = item != "none"
	queue_redraw()
	return self


func reach_endpoint() -> Vector2:
	return REACH_ENDPOINTS.get(item, Vector2.ZERO)


func _draw() -> void:
	var ink := Color("202936")
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
					draw_line(Vector2(0,-18), Vector2(0,110), Color("795033"), 6.0, true)
					draw_colored_polygon(PackedVector2Array([Vector2(-8,105), Vector2(0,126), Vector2(8,105)]), metal)
				"staff":
					draw_line(Vector2(0,-18), Vector2(0,112), Color("6f4c31"), 7.0, true)
					draw_circle(Vector2(0,120), 12, accent.lightened(.15))
		"offhand":
			match item:
				"shield":
					draw_circle(Vector2(0,-20), 27, Color("8f6337"))
					draw_arc(Vector2(0,-20), 27, 0, TAU, 24, metal, 5.0)
					draw_circle(Vector2(0,-20), 7, accent)
				"lantern":
					draw_rect(Rect2(-13,-44,26,31), Color("f4b942"), true)
					draw_rect(Rect2(-13,-44,26,31), ink, false, 4.0)
				"spellbook":
					draw_rect(Rect2(-22,-48,44,35), accent.darkened(.2), true)
					draw_line(Vector2(0,-48), Vector2(0,-13), Color("f0dfb8"), 2.0)
		"armor":
			var armor_color: Color = {"cloth": accent, "leather": Color("754b32"), "plate": metal}.get(item, accent)
			draw_colored_polygon(PackedVector2Array([Vector2(-31,4), Vector2(31,4), Vector2(23,64), Vector2(-23,64)]), armor_color)
			draw_line(Vector2(-27,18), Vector2(27,18), ink, 3.0)
			if item == "plate": draw_line(Vector2(0,6), Vector2(0,61), ink, 2.0)
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
				"cape": draw_colored_polygon(PackedVector2Array([Vector2(-25,5),Vector2(25,5),Vector2(35,92),Vector2(-35,92)]), accent.darkened(.25))
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
