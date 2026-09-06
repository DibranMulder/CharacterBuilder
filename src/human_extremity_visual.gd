class_name HumanExtremityVisual
extends Node2D

var part := "hand_open"
var skin := Color("f0bd91")
const INK := Color("795039")


func _shape(points: PackedVector2Array) -> void:
	var colors := PackedColorArray()
	for point in points:
		colors.append(skin.darkened(.13) if point.y > 3 else skin)
	draw_polygon(points, colors)
	# The closing edge is the wrist/ankle seam, which overlaps the limb.
	draw_polyline(points, INK, .7, true)


func _draw() -> void:
	if part == "foot":
		_shape(PackedVector2Array([
			Vector2(4,-7),Vector2(4,-2),Vector2(7,1),
			Vector2(14,3),Vector2(16,5),Vector2(15,7),Vector2(7,7),
			Vector2(2,6),Vector2(-4,6),Vector2(-5,3),Vector2(-4,-7),
		]))
		draw_line(Vector2(12,4),Vector2(12,6),skin.darkened(.23),.6,true)
		return
	if part == "hand_open":
		_shape(PackedVector2Array([
			Vector2(-6,-3),Vector2(-2,-4),Vector2(1,-8),Vector2(3,-10),
			Vector2(4,-9),Vector2(3,-5),Vector2(8,-8),Vector2(10,-8),
			Vector2(10,-6),Vector2(6,-3),Vector2(12,-4),Vector2(13,-3),
			Vector2(12,-1),Vector2(6,0),Vector2(12,1),Vector2(12,3),
			Vector2(10,4),Vector2(5,3),Vector2(9,6),Vector2(8,8),
			Vector2(5,7),Vector2(1,5),Vector2(-2,4),Vector2(-6,4),
		]))
		draw_polyline(PackedVector2Array([Vector2(1,-3),Vector2(2,0),Vector2(1,3)]),skin.darkened(.23),.6,true)
	else:
		_shape(PackedVector2Array([
			Vector2(-6,-3),Vector2(-2,-3),Vector2(0,-6),Vector2(4,-7),
			Vector2(8,-6),Vector2(9,-3),Vector2(8,0),Vector2(9,3),
			Vector2(7,6),Vector2(2,7),Vector2(-2,4),Vector2(-6,4),
		]))
		for y in [-2,1,4]:
			draw_line(Vector2(5,y),Vector2(8,y),skin.darkened(.24),.6,true)
		if part == "hand_grip":
			draw_polyline(PackedVector2Array([Vector2(0,-4),Vector2(4,-2),Vector2(5,1),Vector2(3,2)]),INK,.65,true)
