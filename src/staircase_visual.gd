class_name StaircaseVisual
extends Node2D


func _draw() -> void:
	var stone_dark := Color("37465a")
	var stone := Color("53677c")
	var edge := Color("7d91a3")
	var mortar := Color("293747")
	# The avatar stands on the center tread and faces up toward screen-right.
	# Deep blocks keep every animated foot silhouette visually grounded.
	for step_index in range(-5,7):
		var x := float(step_index)*52.0
		var y := -float(step_index)*22.0
		var block := PackedVector2Array([
			Vector2(x,y), Vector2(x+52,y), Vector2(x+52,150), Vector2(x,150),
		])
		draw_colored_polygon(block,stone_dark)
		draw_rect(Rect2(Vector2(x+3,y+5),Vector2(46,145-y)),stone)
		draw_line(Vector2(x,y),Vector2(x+52,y),mortar,8.0,true)
		draw_line(Vector2(x+2,y-2),Vector2(x+50,y-2),edge,3.0,true)
		if step_index%2 == 0:
			draw_line(Vector2(x+27,y+10),Vector2(x+27,minf(y+36,145.0)),stone_dark,2.0,true)
