class_name DunebornPaintedAtlas
extends RefCounted

const BASE := "res://assets/base_sprites/duneborn_reference_base_v4.png"
const CLOTHES := "res://assets/base_sprites/duneborn_reference_clothes_v4.png"
const REGIONS := {
	"torso": Rect2(842, 174, 226, 251),
	"torso_back": Rect2(1226, 156, 216, 267),
	"arm": Rect2(133, 590, 96, 316),
	"leg": Rect2(505, 558, 121, 368),
	"hand_open": Rect2(806, 621, 306, 242),
	"hand_grip": Rect2(1192, 673, 246, 196),
	"hand_grip_back": Rect2(1192, 673, 246, 196),
	"mask": Rect2(85, 41, 249, 334),
	"mask_back": Rect2(504, 45, 253, 325),
	"robe": Rect2(835, 43, 359, 357),
	"robe_back": Rect2(68, 440, 322, 379),
	"braced_arm": Rect2(557, 461, 116, 344),
	"cloth_leg": Rect2(940, 452, 138, 379),
	"boot": Rect2(104, 961, 256, 202),
	"cape": Rect2(440, 906, 365, 270),
	"foot": Rect2(916, 955, 250, 192),
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
