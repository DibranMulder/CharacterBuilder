class_name HumanTorsoSurface
extends Node2D

var size := Vector2(52, 72)
var skin := Color("f0bd91")
var hip: Node2D
var back_view := false


func _ready() -> void:
	material = HumanPaintedAtlas.paint_material()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var texture := HumanPaintedAtlas.texture("torso_back" if back_view else "torso")
	# Rows below the waist remain hip-bound as the chest rotates.
	for row in 12:
		var points := PackedVector2Array()
		var uvs := PackedVector2Array()
		for corner in [Vector2(0, row), Vector2(1, row), Vector2(1, row + 1), Vector2(0, row + 1)]:
			var uv := Vector2(corner.x, corner.y / 12.0)
			var point := Vector2((uv.x - .5) * size.x * .9, lerpf(-1.1, .24, uv.y) * size.y)
			if point.y > 0 and is_instance_valid(hip):
				point = to_local(hip.to_global(point))
			points.append(point)
			# The source torso looks left; the unmirrored rig looks right.
			# Flip artwork only, leaving the chest/hip deformation unchanged.
			uvs.append(Vector2(1.0 - uv.x, uv.y))
		draw_polygon(points, PackedColorArray([Color.WHITE]), uvs, texture)
