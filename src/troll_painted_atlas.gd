class_name TrollPaintedAtlas
extends RefCounted

const BASE := "res://assets/base_sprites/troll_reference_base_v3.png"
const CLOTHES := "res://assets/base_sprites/troll_reference_clothes_v3.png"
const REGIONS := {
	"torso": Rect2(782, 136, 314, 341),
	"torso_back": Rect2(1142, 111, 331, 365),
	"arm": Rect2(77, 524, 205, 390),
	"leg": Rect2(426, 526, 195, 381),
	"hand_open": Rect2(699, 549, 374, 330),
	"hand_grip": Rect2(1142, 586, 332, 258),
	"jerkin": Rect2(77, 55, 425, 456),
	"jerkin_back": Rect2(601, 54, 387, 454),
	"braced_arm": Rect2(1140, 23, 219, 529),
	"foot": Rect2(103, 666, 395, 261),
	"hand_grip_back": Rect2(567, 620, 445, 310),
	"leather_leg": Rect2(1098, 583, 291, 398),
}
static var _textures: Dictionary = {}
static var _material: ShaderMaterial


static func texture(part: String) -> AtlasTexture:
	if not _textures.has(part):
		var result := AtlasTexture.new()
		result.atlas = load(BASE if part in ["torso", "torso_back", "arm", "leg", "hand_open", "hand_grip"] else CLOTHES)
		result.region = REGIONS[part]
		result.filter_clip = true
		_textures[part] = result
	return _textures[part]


static func paint_material() -> ShaderMaterial:
	if _material == null:
		var shader := Shader.new()
		# Remove magenta spill without desaturating the troll's blue skin.
		shader.code = """shader_type canvas_item;
void fragment() {
 vec4 paint = texture(TEXTURE, UV);
 float spill = max(min(paint.r, paint.b) - paint.g, 0.0);
 paint.a *= 1.0 - smoothstep(0.12, 0.4, spill);
 paint.r = max(paint.r - spill * 0.9, 0.0);
 paint.b = max(paint.b - spill * 0.9, 0.0);
 COLOR = paint;
}"""
		_material = ShaderMaterial.new()
		_material.shader = shader
	return _material
