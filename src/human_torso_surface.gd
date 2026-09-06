class_name HumanTorsoSurface
extends Node2D

var size := Vector2(52, 72)
var skin := Color("f0bd91")
var hip: Node2D
var back_view := false


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	# Neck, shoulder slope, ribs, waist and pelvis belong to one silhouette.
	# The lower edge remains on the hip as the chest leans around the waist.
	var outline := PackedVector2Array([
		Vector2(-.15,-1.1), Vector2(.15,-1.1), Vector2(.17,-.98),
		Vector2(.38,-.9), Vector2(.42,-.73), Vector2(.35,-.48),
		Vector2(.32,-.12), Vector2(.39,.13), Vector2(.31,.24),
		Vector2(-.31,.24), Vector2(-.39,.13), Vector2(-.32,-.12),
		Vector2(-.35,-.48), Vector2(-.42,-.73), Vector2(-.38,-.9), Vector2(-.17,-.98),
	])
	for i in outline.size():
		outline[i] *= size
		if outline[i].y > 0 and is_instance_valid(hip):
			outline[i] = to_local(hip.to_global(outline[i]))
	# Subdivide the outline to avoid angular shoulders without inventing
	# separate ball-shaped joint caps.
	for iteration in 2:
		var rounded := PackedVector2Array()
		for i in outline.size():
			var next := outline[(i + 1) % outline.size()]
			rounded.append(outline[i].lerp(next, .25))
			rounded.append(outline[i].lerp(next, .75))
		outline = rounded
	var colors := PackedColorArray()
	for point in outline:
		colors.append(skin.darkened(.16) if point.x < -size.x * .15 else skin)
	draw_polygon(outline, colors)
	draw_polyline(outline + PackedVector2Array([outline[0]]), Color("795039"), .85, true)
	var line := skin.darkened(.26)
	if back_view:
		draw_polyline(PackedVector2Array([Vector2(-12,-56), Vector2(-9,-44), Vector2(-5,-41)]), line, .7, true)
		draw_polyline(PackedVector2Array([Vector2(12,-56), Vector2(9,-44), Vector2(5,-41)]), line, .7, true)
	else:
		draw_polyline(PackedVector2Array([Vector2(-12,-61), Vector2(-5,-59), Vector2(0,-61), Vector2(5,-59), Vector2(12,-61)]), line, .7, true)
