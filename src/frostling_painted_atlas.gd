class_name FrostlingPaintedAtlas
extends RefCounted

const BASE := "res://assets/base_sprites/frostling_reference_base_v4.png"
const CLOTHES := "res://assets/base_sprites/frostling_reference_clothes_v4.png"
const REGIONS := {
	"torso": Rect2(787, 151, 271, 280),
	"torso_back": Rect2(1160, 129, 299, 309),
	"arm": Rect2(208, 524, 104, 359),
	"leg": Rect2(470, 552, 143, 338),
	"hand_open": Rect2(743, 579, 323, 260),
	"hand_grip": Rect2(1142, 625, 252, 194),
	"hand_grip_back": Rect2(1142, 625, 252, 194),
	"hood": Rect2(90, 62, 316, 358),
	"hood_back": Rect2(476, 82, 305, 310),
	"coat": Rect2(895, 89, 267, 327),
	"coat_back": Rect2(116, 468, 263, 317),
	"braced_arm": Rect2(554, 481, 135, 283),
	"cloth_leg": Rect2(949, 479, 131, 310),
	"boot": Rect2(127, 917, 234, 178),
	"pack": Rect2(490, 851, 273, 275),
	"foot": Rect2(912, 949, 214, 140),
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
