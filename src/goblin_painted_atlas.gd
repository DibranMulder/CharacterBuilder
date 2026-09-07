class_name GoblinPaintedAtlas
extends RefCounted

const BASE := "res://assets/base_sprites/goblin_reference_base_v2.png"
const CLOTHES := "res://assets/base_sprites/goblin_reference_clothes_v2.png"
const REGIONS := {
	"torso": Rect2(857, 210, 244, 230),
	"torso_back": Rect2(1199, 188, 256, 252),
	"arm": Rect2(163, 561, 119, 312),
	"leg": Rect2(516, 549, 115, 321),
	"hand_open": Rect2(806, 623, 272, 220),
	"hand_grip": Rect2(1188, 660, 256, 174),
	"hand_grip_back": Rect2(1188, 660, 256, 174),
	"vest": Rect2(67, 105, 258, 324),
	"vest_back": Rect2(459, 117, 240, 306),
	"braced_arm": Rect2(911, 125, 105, 298),
	"leather_leg": Rect2(1248, 97, 162, 344),
	"boot": Rect2(100, 708, 219, 168),
	"pack": Rect2(436, 626, 265, 269),
	"goggles": Rect2(823, 723, 275, 112),
	"foot": Rect2(1241, 720, 227, 144),
}
static var _textures: Dictionary = {}


static func texture(part: String) -> AtlasTexture:
	if not _textures.has(part):
		var result := AtlasTexture.new()
		result.atlas = load(BASE if part in ["torso", "torso_back", "arm", "leg", "hand_open", "hand_grip", "hand_grip_back"] else CLOTHES)
		result.region = REGIONS[part]
		result.filter_clip = true
		_textures[part] = result
	return _textures[part]
