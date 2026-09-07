class_name HumanTorsoSurface
extends Node2D

var size := Vector2(52, 72)
var skin := Color("f0bd91")
var hip: Node2D
var back_view := false
var centaur := false


func _ready() -> void:
	material = CentaurPaintedAtlas.paint_material() if centaur else HumanPaintedAtlas.paint_material()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var texture := HumanPaintedAtlas.texture("torso_back" if back_view else "torso")
	if centaur:
		texture = CentaurPaintedAtlas.texture("torso_back" if back_view else "torso")
	# Rows below the waist remain hip-bound as the chest rotates.
	for row in 12:
		var points := PackedVector2Array()
		var uvs := PackedVector2Array()
		for corner in [Vector2(0, row), Vector2(1, row), Vector2(1, row + 1), Vector2(0, row + 1)]:
			var uv := Vector2(corner.x, corner.y / 12.0)
			var point := Vector2((uv.x - .5) * size.x * .9, lerpf(-1.1, .14 if centaur else .24, uv.y) * size.y)
			if centaur:
				# Tuck only the lower abdominal seam into the painted withers;
				# preserve the broad chest instead of narrowing the whole torso.
				point.x *= lerpf(1.0, .72, smoothstep(.7, 1.0, uv.y))
			if is_instance_valid(hip):
				if centaur:
					# Blend across the lower abdomen: a wider chest must not
					# fold a whole strip at a hard chest/hip binding boundary.
					var weight := smoothstep(-size.y * .25, 0.0, point.y)
					point = point.lerp(to_local(hip.to_global(point + Vector2(30, 0))), weight)
				elif point.y > 0:
					point = to_local(hip.to_global(point))
			points.append(point)
			# The source torso looks left; the unmirrored rig looks right.
			# Flip artwork only, leaving the chest/hip deformation unchanged.
			uvs.append(uv if centaur else Vector2(1.0 - uv.x, uv.y))
		for indices in [[0, 1, 2], [0, 2, 3]]:
			var triangle := PackedVector2Array([points[indices[0]], points[indices[1]], points[indices[2]]])
			if absf((triangle[1] - triangle[0]).cross(triangle[2] - triangle[0])) < .0001:
				continue
			draw_polygon(triangle, PackedColorArray([Color.WHITE]),
				PackedVector2Array([uvs[indices[0]], uvs[indices[1]], uvs[indices[2]]]), texture)
