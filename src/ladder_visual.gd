class_name LadderVisual
extends Node2D


func _draw() -> void:
	var wood_dark := Color("513824")
	var wood := Color("8a6038")
	var rail_top := -245.0
	var rail_bottom := 105.0
	for x in [-42.0, 42.0]:
		draw_line(Vector2(x,rail_top),Vector2(x,rail_bottom),wood_dark,15.0,true)
		draw_line(Vector2(x,rail_top),Vector2(x,rail_bottom),wood,9.0,true)
	for y in range(-215, 91, 38):
		draw_line(Vector2(-42,y),Vector2(42,y),wood_dark,12.0,true)
		draw_line(Vector2(-38,y-2),Vector2(38,y-2),wood.lightened(.08),7.0,true)
