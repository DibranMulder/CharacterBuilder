class_name CentaurPaintedAtlas
extends RefCounted

const EQUINE := "res://assets/base_sprites/centaur_reference_equine_v3.png"
const UPPER := "res://assets/base_sprites/centaur_reference_upper_v3.png"
const REGIONS := {
	"horse_body": Rect2(138, 102, 404, 310),
	"horse_body_back": Rect2(648, 102, 316, 314),
	"front_leg": Rect2(1150, 40, 180, 421),
	"hind_leg": Rect2(200, 518, 198, 431),
	"hoof": Rect2(620, 748, 226, 132),
	"horse_tail": Rect2(1040, 515, 288, 438),
	"torso": Rect2(814, 170, 268, 358),
	"torso_back": Rect2(1170, 170, 282, 358),
	"arm": Rect2(115, 620, 124, 342),
	"hand_open": Rect2(404, 710, 298, 207),
	"hand_grip": Rect2(803, 735, 231, 161),
	"hand_grip_back": Rect2(1189, 745, 240, 155),
}
static var _textures: Dictionary = {}
static var _material: ShaderMaterial

# Root axes measured in the barrel atlas, above its four painted leg exits.
# Order follows the rig: far hind, near hind, far fore, near fore. The near
# foreleg is under the large shoulder, not at the leading edge of the chest.
const LEG_ROOT_PIXELS := [Vector2(270, 306), Vector2(194, 306), Vector2(477, 306), Vector2(395, 306)]


static func leg_root(index: int, body_size: Vector2) -> Vector2:
	var crop: Rect2 = REGIONS.horse_body
	var uv: Vector2 = (LEG_ROOT_PIXELS[index] - crop.position) / crop.size
	# Body parts are centered horizontally but start at y=0 vertically.
	return Vector2((uv.x - .5) * body_size.x, uv.y * body_size.y)


static func texture(part: String) -> AtlasTexture:
	if not _textures.has(part):
		var result := AtlasTexture.new()
		result.atlas = load(EQUINE if part in ["horse_body", "horse_body_back", "front_leg", "hind_leg", "hoof", "horse_tail"] else UPPER)
		result.region = REGIONS[part]
		result.filter_clip = true
		_textures[part] = result
	return _textures[part]


static func paint_material() -> ShaderMaterial:
	if _material == null:
		var shader := Shader.new()
		shader.code = """
shader_type canvas_item;
void fragment() {
 vec4 paint = texture(TEXTURE, UV);
 float key = min(paint.r, paint.b) - paint.g;
 paint.a *= 1.0 - smoothstep(0.12, 0.4, key);
 paint.b = min(paint.b, paint.g + 0.05);
 COLOR = paint;
}
"""
		_material = ShaderMaterial.new()
		_material.shader = shader
	return _material
