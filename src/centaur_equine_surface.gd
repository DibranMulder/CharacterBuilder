class_name CentaurEquineSurface
extends Node2D

# One welded grid skins the complete barrel, near legs and hooves. The second
# mesh uses the same painting's leg areas behind it, driven by the far bones.
const SOURCE := "res://assets/base_sprites/centaur_equine_unified_v4.png"
const CROP := Rect2(269, 84, 980, 856)
const BIND_RECT := Rect2(-61, -8, 116, 110)
const COLUMNS := 32
const ROWS := 36
const ROOT_Y := 38.0

var bones: Dictionary
var rest_vertices := PackedVector2Array()
var uvs := PackedVector2Array()
var near_indices := PackedInt32Array()
var far_indices := PackedInt32Array()
var near_mesh := ArrayMesh.new()
var far_mesh := ArrayMesh.new()
var near_layer: MeshInstance2D
var far_layer: MeshInstance2D


static func leg_root(index: int) -> Vector2:
	return Vector2([-26.0, -44.0, 43.0, 29.0][index], ROOT_Y)


func setup(rig_bones: Dictionary) -> void:
	bones = rig_bones
	var texture: Texture2D = load(SOURCE)
	for row in ROWS + 1:
		for column in COLUMNS + 1:
			var uv := Vector2(float(column) / COLUMNS, float(row) / ROWS)
			rest_vertices.append(BIND_RECT.position + uv * BIND_RECT.size)
			uvs.append((CROP.position + uv * CROP.size) / texture.get_size())
	for row in ROWS:
		for column in COLUMNS:
			var a := row * (COLUMNS + 1) + column
			var quad := PackedInt32Array([a, a + 1, a + COLUMNS + 2, a, a + COLUMNS + 2, a + COLUMNS + 1])
			near_indices.append_array(quad)
			var center := (rest_vertices[a] + rest_vertices[a + COLUMNS + 2]) * .5
			# Far-leg caps end deep inside the opaque barrel; no second belly.
			if center.y > 35.0 and (absf(center.x + 44.0) < 18.0 or absf(center.x - 29.0) < 18.0):
				far_indices.append_array(quad)
	far_layer = _layer("FarLegs", texture, far_mesh, -3)
	var far_shader := Shader.new()
	far_shader.code = """
shader_type canvas_item;
void fragment() {
 vec4 paint = texture(TEXTURE, UV);
 float key = min(paint.r, paint.b) - paint.g;
 paint.a *= 1.0 - smoothstep(0.12, 0.4, key);
 paint.b = min(paint.b, paint.g + 0.05);
 // Feather the hidden proximal caps into the barrel instead of exposing a
 // rectangular slice of the source chest as a far leg swings forward.
 paint.a *= smoothstep(450.0, 570.0, UV.y * 1024.0);
 paint.rgb *= 0.82;
 COLOR = paint;
}
"""
	var far_material := ShaderMaterial.new()
	far_material.shader = far_shader
	far_layer.material = far_material
	near_layer = _layer("BodyAndNearLegs", texture, near_mesh, -1)
	update_meshes()


func _layer(label: String, texture: Texture2D, mesh: ArrayMesh, depth: int) -> MeshInstance2D:
	var layer := MeshInstance2D.new()
	layer.name = label
	layer.texture = texture
	layer.mesh = mesh
	layer.z_index = depth
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	layer.material = CentaurPaintedAtlas.paint_material()
	add_child(layer)
	return layer


func _process(_delta: float) -> void:
	if visible:
		update_meshes()


func deform_point(point: Vector2, far_side := false) -> Vector2:
	var near_index := 1 if point.x < -7.0 else 3
	var index := near_index - 1 if far_side else near_index
	var bind_root := leg_root(near_index)
	var upper: Node2D = bones["horse_leg_%d" % index]
	var lower: Node2D = bones["horse_shin_%d" % index]
	var knee_y := bind_root.y + lower.position.y
	var upper_point := to_local(upper.to_global(point - bind_root))
	var lower_point := to_local(lower.to_global(point - Vector2(bind_root.x, knee_y)))
	var knee_weight := smoothstep(knee_y - 9.0, knee_y + 9.0, point.y)
	var leg_point := upper_point.lerp(lower_point, knee_weight)
	if far_side:
		return point.lerp(leg_point, smoothstep(ROOT_Y - 6.0, ROOT_Y + 26.0, point.y))
	# Soft tissue above each thigh/shoulder blends into the stationary barrel.
	# Shared vertices at every boundary make an opening at the root impossible.
	var root_weight := smoothstep(ROOT_Y - 22.0, ROOT_Y + 16.0, point.y)
	var lateral_weight := 1.0 - smoothstep(17.0, 32.0, absf(point.x - bind_root.x))
	if point.y > 60.0:
		lateral_weight = 1.0
	return point.lerp(leg_point, root_weight * lateral_weight)


func deformed_vertices(far_side := false) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point in rest_vertices:
		result.append(deform_point(point, far_side))
	return result


func update_meshes() -> void:
	_upload(near_mesh, deformed_vertices(), near_indices)
	_upload(far_mesh, deformed_vertices(true), far_indices)


func _upload(mesh: ArrayMesh, points: PackedVector2Array, indices: PackedInt32Array) -> void:
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
