class_name FaePaintedAtlas
extends RefCounted

const BASE := "res://assets/base_sprites/fae_reference_base_v2.png"
const CLOTHES := "res://assets/base_sprites/fae_reference_clothes_v2.png"
const REGIONS := {
	"torso": Rect2(936, 152, 188, 282),
	"torso_back": Rect2(1250, 165, 188, 280),
	"arm": Rect2(187, 518, 89, 370),
	"leg": Rect2(480, 521, 126, 372),
	"hand_open": Rect2(855, 633, 187, 154),
	"hand_grip": Rect2(1281, 668, 145, 111),
	"hand_grip_back": Rect2(1190, 730, 138, 116),
	"tunic": Rect2(198, 54, 371, 450),
	"tunic_back": Rect2(660, 58, 344, 448),
	"wrapped_arm": Rect2(1190, 76, 106, 416),
	"baggy_leg": Rect2(236, 577, 224, 376),
	"foot_wraps": Rect2(714, 752, 239, 168),
}
static var _textures: Dictionary = {}


static func texture(part: String) -> AtlasTexture:
	if not _textures.has(part):
		var result := AtlasTexture.new()
		result.atlas = load(BASE if part in ["torso", "torso_back", "arm", "leg", "hand_open", "hand_grip"] else CLOTHES)
		result.region = REGIONS[part]
		result.filter_clip = true
		_textures[part] = result
	return _textures[part]
