class_name GarmentSurface
extends RefCounted

# Bind an authored garment to the same pose as the wearer. Upper fabric follows
# the chest, the belt follows the pelvis, and the skirt shares thigh motion.
# Coordinates and inverse binds are local, so facing and avatar scale cancel.
const COLUMNS := 8
const ROWS := 12
var wearer: Node2D
var anchors: Array[Node2D] = []
var inverse_binds: Array[Transform2D] = []
var _mesh_key: Array = []
var _cached_mesh: ArrayMesh


func bind(surface: Node2D, hip: Node2D, left_leg: Node2D, right_leg: Node2D, left_arm: Node2D = null, right_arm: Node2D = null) -> void:
	wearer = surface
	anchors = [hip, left_leg, right_leg]
	if left_arm and right_arm:
		anchors.append(left_arm)
		anchors.append(right_arm)
	_mesh_key.clear()
	inverse_binds.clear()
	for anchor in anchors:
		inverse_binds.append(anchor.global_transform.affine_inverse() * wearer.global_transform)


func deform(point: Vector2, size: Vector2, rigid: bool = false) -> Vector2:
	var height := point.y / size.y
	var shoulder_weight := smoothstep(.18, .36, absf(point.x) / size.x) * smoothstep(0.0, .12, height) * (1.0 - smoothstep(.28, .52, height))
	# The source garments were authored for a broad shared mannequin. Fit the
	# chest and arm openings to the human shoulder span before pose deformation.
	# Keep the skirt width so it can still drape over the moving upper legs.
	point.x *= lerpf(.70, 1.0, smoothstep(.30, .72, height))
	# Preserve the breastplate itself; only its lower articulated skirt bends.
	var waist_weight := smoothstep(.38 if not rigid else .66, .76, height)
	var skirt_weight := smoothstep(.76, 1.0, height) * (.28 if rigid else .65)
	var side := smoothstep(-size.x * .22, size.x * .22, point.x)
	var local := wearer.global_transform.affine_inverse()
	var chest_point := point
	if anchors.size() == 5:
		# Lift the shared mannequin's low armhole onto the human shoulder, then
		# let that opening follow the arm. Central chest/neck vertices stay rigid.
		point.y -= 10.0 * shoulder_weight
		var arm_index := 3 if point.x > 0 else 4
		var arm_point: Vector2 = local * anchors[arm_index].global_transform * inverse_binds[arm_index] * point
		chest_point = point.lerp(arm_point, shoulder_weight * .75)
	var hip_point: Vector2 = local * anchors[0].global_transform * inverse_binds[0] * point
	var left_point: Vector2 = local * anchors[1].global_transform * inverse_binds[1] * point
	var right_point: Vector2 = local * anchors[2].global_transform * inverse_binds[2] * point
	return chest_point.lerp(hip_point.lerp(right_point.lerp(left_point, side), skirt_weight), waist_weight)


func mesh(size: Vector2, rigid: bool = false) -> ArrayMesh:
	var key: Array = [size, rigid]
	var local := wearer.global_transform.affine_inverse()
	for anchor in anchors:
		key.append(local * anchor.global_transform)
	if _cached_mesh and key == _mesh_key:
		return _cached_mesh
	_mesh_key = key
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for row in ROWS + 1:
		for column in COLUMNS + 1:
			var uv := Vector2(float(column) / COLUMNS, float(row) / ROWS)
			var point := deform(Vector2(-41, 0) + uv * size, size, rigid)
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
	_cached_mesh = result
	return result
