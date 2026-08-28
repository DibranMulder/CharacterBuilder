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
		"scale": 0.86, "head": Vector2(45, 50), "torso": Vector2(45, 66),
		"arm": 56.0, "leg": 54.0, "topology": "winged",
		"gestures": [
			{"name": "Wand Arc", "style": "slash"},
			{"name": "Gale Step", "style": "leap"},
			{"name": "Star Bloom", "style": "cast"},
		],
	},
	"frost_troll": {
		"name": "Frost Troll", "tagline": "Mountain-born breakers",
		"skin": Color("7195a9"), "accent": Color("687047"),
		"scale": 1.18, "head": Vector2(62, 58), "torso": Vector2(82, 88),
		"arm": 76.0, "leg": 58.0, "topology": "biped",
		"gestures": [
			{"name": "Glacier Cleave", "style": "smash"},
			{"name": "Boulder Rush", "style": "thrust"},
			{"name": "Avalanche", "style": "leap"},
		],
	},
	"goblin": {
		"name": "Goblin", "tagline": "Quick-handed tunnel inventors",
		"skin": Color("91a44a"), "accent": Color("b77c3f"),
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
		"scale": 0.96, "head": Vector2(47, 53), "torso": Vector2(54, 74),
		"arm": 62.0, "leg": 62.0, "topology": "biped",
		"gestures": [
			{"name": "Sirocco Thrust", "style": "thrust"},
			{"name": "Crescent Guard", "style": "slash"},
			{"name": "Sand Veil", "style": "cast"},
		],
	},
	"frostling": {
		"name": "Frostling", "tagline": "Small mystics of the aurora",
		"skin": Color("8795a7"), "accent": Color("37658b"),
		"scale": 0.76, "head": Vector2(55, 52), "torso": Vector2(48, 58),
		"arm": 48.0, "leg": 42.0, "topology": "biped",
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
