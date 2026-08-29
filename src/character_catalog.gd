class_name CharacterCatalog
extends RefCounted


const SLOT_ORDER := [&"weapon", &"offhand", &"armor", &"pants", &"head", &"back", &"accessory"]

const EQUIPMENT := {
	"weapon": ["none", "sword", "axe", "bow", "spear", "staff"],
	"offhand": ["none", "shield", "lantern", "spellbook"],
	"armor": ["none", "cloth", "leather", "plate"],
	"pants": ["none", "cloth", "leather", "plate"],
	"head": ["none", "hood", "helm", "crown"],
	"back": ["none", "cape", "pack", "quiver"],
	"accessory": ["none", "scarf", "amulet", "goggles"],
}

# Working names derived from the two supplied concept illustrations. Rename freely;
# stable IDs are deliberately separate from display names.
const RACES := {
	"bogkin": {
		"name": "Bogkin",
		"tagline": "Spring-legged marsh wardens",
		"skin": Color("42b9a5"), "accent": Color("f2a65a"),
		"visual": {"face": "frog", "hair_style": "none", "eye": Color("b8892e"), "boot": Color("795238")},
		"scale": 0.78, "head": Vector2(54, 46), "torso": Vector2(48, 58),
		"arm": 48.0, "leg": 43.0, "topology": "biped",
		"gestures": [
			{"name": "Tongue Snap", "style": "thrust"},
			{"name": "Lily Leap", "style": "leap"},
			{"name": "Bog Burst", "style": "cast"},
		],
	},
	"human": {
		"name": "Human", "tagline": "Versatile frontier adventurers",
		"skin": Color("f0bd91"), "accent": Color("4778b8"),
		"visual": {"hair_style": "crop", "hair": Color("71482c"), "eye": Color("4b3522"), "boot": Color("67462f")},
		"scale": 0.92, "head": Vector2(48, 52), "torso": Vector2(52, 72),
		"arm": 58.0, "leg": 62.0, "topology": "biped",
		"gestures": [
			{"name": "Crosscut", "style": "slash"},
			{"name": "Shield Rush", "style": "thrust"},
			{"name": "Heroic Vault", "style": "leap"},
		],
	},
	"centaur": {
		"name": "Centaur", "tagline": "Swift guardians of the old groves",
		"skin": Color("a66f45"), "accent": Color("6d9b57"),
		"visual": {"hair_style": "long", "hair": Color("4a3328"), "eye": Color("39291e"), "boot": Color("392c24")},
		"scale": 0.9, "head": Vector2(48, 54), "torso": Vector2(54, 76),
		"arm": 62.0, "leg": 58.0, "topology": "centaur",
		"gestures": [
			{"name": "Gallop Shot", "style": "shoot"},
			{"name": "Rearing Strike", "style": "leap"},
			{"name": "Grove Tempest", "style": "cast"},
		],
	},
	"fae": {
		"name": "Fae", "tagline": "Airborne keepers of wild magic",
		"skin": Color("f2c29b"), "accent": Color("e05b52"),
		"visual": {"hair_style": "ponytail", "hair": Color("24272a"), "eye": Color("47301e"), "boot": Color("ded4bf"), "body_shape": "slender"},
		"scale": 0.86, "head": Vector2(45, 50), "torso": Vector2(40, 66),
		"arm": 57.0, "leg": 59.0, "limb_width": 14.0, "leg_width": 16.0,
		"shoulder_spread": 0.30, "extremity_scale": 0.90, "topology": "winged",
		"gestures": [
			{"name": "Wand Arc", "style": "slash"},
			{"name": "Gale Step", "style": "leap"},
			{"name": "Star Bloom", "style": "cast"},
		],
	},
	"frost_troll": {
		"name": "Frost Troll", "tagline": "Mountain-born breakers",
		"skin": Color("7195a9"), "accent": Color("687047"),
		"visual": {"hair_style": "crest", "hair": Color("343b3e"), "eye": Color("332c25"), "boot": Color("4b4238"), "body_shape": "top_heavy", "skin_pattern": "mottled"},
		"scale": 1.16, "head": Vector2(70, 64), "torso": Vector2(108, 84),
		"arm": 86.0, "leg": 54.0, "limb_width": 25.0, "leg_width": 25.0,
		"shoulder_spread": 0.40, "extremity_scale": 1.85, "head_sprite_scale": 1.58, "head_y_adjust": 4.0,
		"armor_width_scale": 1.45, "pants_width_scale": 1.35, "topology": "biped",
		"gestures": [
			{"name": "Glacier Cleave", "style": "smash"},
			{"name": "Boulder Rush", "style": "thrust"},
			{"name": "Avalanche", "style": "leap"},
		],
	},
	"goblin": {
		"name": "Goblin", "tagline": "Quick-handed tunnel inventors",
		"skin": Color("91a44a"), "accent": Color("b77c3f"),
		"visual": {"hair_style": "crop", "hair": Color("493527"), "eye": Color("d7a63d"), "boot": Color("55402d")},
		"scale": 0.72, "head": Vector2(58, 46), "torso": Vector2(44, 54),
		"arm": 46.0, "leg": 40.0, "topology": "biped",
		"gestures": [
			{"name": "Snap Shot", "style": "shoot"},
			{"name": "Low Blow", "style": "slash"},
			{"name": "Powder Keg", "style": "cast"},
		],
	},
	"duneborn": {
		"name": "Duneborn", "tagline": "Disciplined travelers of the glass sea",
		"skin": Color("bf825d"), "accent": Color("8d493d"),
		"visual": {"hair_style": "none", "hair": Color("302823"), "eye": Color("9b6b2e"), "boot": Color("6b4a35"), "body_shape": "lean"},
		"scale": 0.94, "head": Vector2(50, 56), "torso": Vector2(48, 74),
		"arm": 61.0, "leg": 64.0, "limb_width": 15.0, "leg_width": 17.0,
		"shoulder_spread": 0.30, "head_sprite_scale": 1.52, "topology": "biped",
		"gestures": [
			{"name": "Sirocco Thrust", "style": "thrust"},
			{"name": "Crescent Guard", "style": "slash"},
			{"name": "Sand Veil", "style": "cast"},
		],
	},
	"frostling": {
		"name": "Frostling", "tagline": "Small mystics of the aurora",
		"skin": Color("8795a7"), "accent": Color("37658b"),
		"visual": {"hair_style": "shaggy", "hair": Color("e3e7e5"), "eye": Color("73c9ef"), "boot": Color("3b5366"), "body_shape": "compact"},
		"scale": 0.78, "head": Vector2(61, 57), "torso": Vector2(54, 55),
		"arm": 47.0, "leg": 39.0, "limb_width": 17.0, "leg_width": 20.0,
		"shoulder_spread": 0.32, "extremity_scale": 1.08, "head_sprite_scale": 1.55, "head_y_adjust": 2.0, "topology": "biped",
		"gestures": [
			{"name": "Crystal Jab", "style": "thrust"},
			{"name": "Aurora Pulse", "style": "cast"},
			{"name": "Snowdrift", "style": "leap"},
		],
	},
}


static func race_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in RACES:
		ids.append(id)
	return ids


static func race(id: String) -> Dictionary:
	return RACES.get(id, RACES["human"])


static func items_for(slot: StringName) -> Array:
	return EQUIPMENT.get(String(slot), ["none"])
