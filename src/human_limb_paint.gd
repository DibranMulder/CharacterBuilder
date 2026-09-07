extends Node2D

var surface: HumanLimbSurface


func _ready() -> void:
	material = surface.paint_material if surface.paint_material != null else HumanPaintedAtlas.paint_material()


func _draw() -> void:
	if not is_instance_valid(surface.lower):
		return
	var centers := surface.centerline()
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var distances := PackedFloat32Array([0.0])
	for i in centers.size():
		var tangent := (centers[mini(i + 1, centers.size() - 1)] - centers[maxi(0, i - 1)]).normalized()
		var normal := Vector2(tangent.y, -tangent.x)
		left.append(centers[i] - normal * surface.width * .53)
		right.append(centers[i] + normal * surface.width * .53)
		if i > 0:
			distances.append(distances[i - 1] + centers[i].distance_to(centers[i - 1]))
	var texture := HumanPaintedAtlas.texture("leg" if surface.is_leg else "arm")
	if surface.paint_texture != null:
		texture = surface.paint_texture
	for i in range(centers.size() - 1):
		var v0 := distances[i] / distances[-1]
		var v1 := distances[i + 1] / distances[-1]
		var points := PackedVector2Array([left[i], right[i], right[i + 1], left[i + 1]])
		var uvs := PackedVector2Array([Vector2(0, v0), Vector2(1, v0), Vector2(1, v1), Vector2(0, v1)])
		# Explicit triangles also cover tightly folded joints, where a quad
		# can cross itself and automatic polygon triangulation would fail.
		for indices in [[0, 1, 2], [0, 2, 3]]:
			var triangle := PackedVector2Array([points[indices[0]], points[indices[1]], points[indices[2]]])
			if absf((triangle[1] - triangle[0]).cross(triangle[2] - triangle[0])) < .0001:
				continue
			draw_polygon(triangle, PackedColorArray([Color.WHITE]),
				PackedVector2Array([uvs[indices[0]], uvs[indices[1]], uvs[indices[2]]]), texture)
