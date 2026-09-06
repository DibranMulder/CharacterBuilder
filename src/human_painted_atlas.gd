class_name HumanPaintedAtlas
extends RefCounted

# Tight source bounds; painted alpha owns the silhouette.
const REGIONS := {
	"torso": Rect2(71, 86, 268, 423),
	"torso_back": Rect2(461, 91, 261, 419),
	"arm": Rect2(903, 67, 110, 436),
	"leg": Rect2(1242, 37, 133, 485),
	"hand_open": Rect2(68, 630, 288, 222),
	"hand_grip": Rect2(450, 659, 229, 170),
	"hand_grip_back": Rect2(823, 667, 222, 164),
	"foot": Rect2(1183, 645, 277, 208),
}
static var _textures: Dictionary = {}
static var _material: ShaderMaterial


static func texture(part: String) -> AtlasTexture:
	if not _textures.has(part):
		var atlas := AtlasTexture.new()
		atlas.atlas = load("res://assets/base_sprites/human_anatomy_painted.png")
		atlas.region = REGIONS[part]
		atlas.filter_clip = true
		_textures[part] = atlas
	return _textures[part]


static func paint_material() -> ShaderMaterial:
	if _material == null:
		var shader := Shader.new()
		# Key out the neutral checkerboard while preserving warm painted edges.
		shader.code = """
shader_type canvas_item;
void fragment() {
 vec4 paint = texture(TEXTURE, UV);
 float warmth = paint.r - paint.b;
 paint.a *= smoothstep(0.035, 0.15, warmth);
 COLOR = paint;
}
"""
		_material = ShaderMaterial.new()
		_material.shader = shader
	return _material
