class_name ClothSurface
extends RefCounted

# Existing animation curves describe the free end's bend. Distribute that bend
# along the cloth instead of rotating the clasp/neck wrap with the entire image.
static func deform(point: Vector2, uv: Vector2, bend: float) -> Vector2:
	var weight := smoothstep(.22, 1.0, uv.y)
	# Cancel the animated socket rotation at the pinned top. The parent's
	# transform still carries the cloth with the torso, including mirrored facing.
	return point.rotated(bend * (weight - 1.0))


static func mesh(size: Vector2, origin: Vector2, bend: float) -> ArrayMesh:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	const COLUMNS := 8
	const ROWS := 12
	for row in ROWS + 1:
		for column in COLUMNS + 1:
			var uv := Vector2(float(column) / COLUMNS, float(row) / ROWS)
			var point := deform(origin + uv * size, uv, bend)
			vertices.append(Vector3(point.x, point.y, 0))
			uvs.append(uv)
	for row in ROWS:
		for column in COLUMNS:
			var a := row * (COLUMNS + 1) + column
			var b := a + COLUMNS + 1
			indices.append_array(PackedInt32Array([a, a + 1, b, a + 1, b + 1, b]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var result := ArrayMesh.new()
	result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return result
