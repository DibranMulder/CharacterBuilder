class_name CharacterCatalog
extends RefCounted


const SLOT_ORDER := [&"weapon", &"offhand", &"armor", &"pants", &"boots", &"head", &"back", &"accessory"]
const SHIELD_ITEMS := ["shield", "marsh_shield", "dune_shield"]

const EQUIPMENT := {
	"weapon": ["none", "sword", "axe", "bow", "crossbow", "spear", "staff", "branch_staff"],
	"offhand": ["none", "shield", "marsh_shield", "dune_shield", "lantern", "spellbook"],
	"armor": ["none", "cloth", "marsh_tunic", "leather", "woodland_harness", "troll_jerkin", "fur_coat", "fae_tunic", "lamellar", "plate"],
	"pants": ["none", "cloth", "ranger", "baggy", "leather", "plate"],
	"boots": ["none", "wraps", "leather", "plate"],
	"head": ["none", "hood", "balaclava", "helm", "crown"],
	"back": ["none", "cape", "long_cape", "pack", "quiver"],
	"accessory": ["none", "scarf", "amulet", "goggles"],
}

# Full-slot modular presets reconstructed from the two supplied lineage
# paintings. Keeping them in the catalog makes the authored designs available
# in the actual builder, while every piece remains independently swappable.
const REFERENCE_LOADOUTS := {
	"bogkin": {"weapon":"sword", "offhand":"marsh_shield", "armor":"marsh_tunic", "pants":"cloth", "boots":"none", "head":"none", "back":"none", "accessory":"scarf"},
	"human": {"weapon":"sword", "offhand":"shield", "armor":"marsh_tunic", "pants":"ranger", "boots":"leather", "head":"none", "back":"long_cape", "accessory":"scarf"},
	"centaur": {"weapon":"bow", "offhand":"none", "armor":"woodland_harness", "pants":"none", "boots":"none", "head":"none", "back":"quiver", "accessory":"none"},
	"fae": {"weapon":"branch_staff", "offhand":"none", "armor":"fae_tunic", "pants":"baggy", "boots":"wraps", "head":"none", "back":"none", "accessory":"none"},
	"frost_troll": {"weapon":"axe", "offhand":"none", "armor":"troll_jerkin", "pants":"leather", "boots":"none", "head":"none", "back":"none", "accessory":"none"},
	"goblin": {"weapon":"crossbow", "offhand":"none", "armor":"leather", "pants":"leather", "boots":"leather", "head":"none", "back":"pack", "accessory":"goggles"},
	"duneborn": {"weapon":"spear", "offhand":"dune_shield", "armor":"lamellar", "pants":"cloth", "boots":"leather", "head":"balaclava", "back":"cape", "accessory":"none"},
	"frostling": {"weapon":"staff", "offhand":"none", "armor":"fur_coat", "pants":"cloth", "boots":"leather", "head":"hood", "back":"pack", "accessory":"none"},
}

# Working Lineage names from docs/game/0008-playable-lineage-art-direction.md.
# Legacy rig IDs stay stable for saved loadouts, artwork, and animation tools.
const RACES := {
	"bogkin": {
		"name": "Tidekin",
		"tagline": "Amphibious navigators of reefs and tides",
		"skin": Color("42b9a5"), "accent": Color("f2a65a"),
		"visual": {"face": "frog", "hair_style": "none", "eye": Color("b8892e"), "boot": Color("795238")},
		# The light-lineage sheet places the frogfolk at roughly two-thirds of the
		# Human's standing height. Preserve a broad spring-loaded construction
		# inside that compact scale: wide short trunk, compact limbs, oversized
		# webbed extremities, and a head that dominates the upper silhouette.
		"scale": 0.74, "head": Vector2(58, 49), "torso": Vector2(64, 54),
		"arm": 46.0, "leg": 38.0, "limb_width": 19.0, "leg_width": 23.0,
		"shoulder_spread": 0.34, "extremity_scale": 1.22, "head_sprite_scale": 1.52,
		"armor_width_scale": 1.12, "pants_width_scale": 1.10, "topology": "biped",
		"gestures": [
			{"name": "Tongue Snap", "style": "thrust"},
			{"name": "Lily Leap", "style": "leap"},
			{"name": "Bog Burst", "style": "cast"},
		],
	},
	"human": {
		"name": "Humans", "tagline": "Road builders and adventurers of the Open Lands",
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
		"name": "Grove Centaurs", "tagline": "Swift guardians of the Elder Forests",
		"skin": Color("a66f45"), "accent": Color("6d9b57"),
		"visual": {"hair_style": "long", "hair": Color("4a3328"), "eye": Color("39291e"), "boot": Color("392c24")},
		"scale": 0.9, "head": Vector2(48, 54), "torso": Vector2(70, 70),
		"head_y_adjust": 9.0, "limb_width": 22.0, "leg_width": 38.0,
		"armor_width_scale": 1.2, "armor_height_scale": 1.25,
		"arm": 62.0, "leg": 58.0, "topology": "centaur",
		"gestures": [
			{"name": "Gallop Shot", "style": "shoot"},
			{"name": "Rearing Strike", "style": "leap"},
			{"name": "Grove Tempest", "style": "cast"},
		],
	},
	"fae": {
		"name": "Aeralith", "tagline": "Wind-shaped navigators of the Sky Reaches",
		"skin": Color("f2c29b"), "accent": Color("e05b52"),
		"visual": {"hair_style": "ponytail", "hair": Color("24272a"), "eye": Color("47301e"), "boot": Color("ded4bf"), "body_shape": "slender"},
		# The reference's poised winged figure is approximately Human-height, not
		# a miniature fairy. A slightly taller global scale retains the slender
		# anatomy while letting staff, wings, and wind-pulled garments read clearly.
		"scale": 1.02, "head": Vector2(45, 50), "torso": Vector2(48, 64),
		"head_y_adjust": 4.0,
		"arm": 57.0, "leg": 59.0, "limb_width": 17.0, "leg_width": 21.0,
		"shoulder_spread": 0.30, "extremity_scale": 0.90, "topology": "winged",
		"gestures": [
			{"name": "Wand Arc", "style": "slash"},
			{"name": "Gale Step", "style": "leap"},
			{"name": "Star Bloom", "style": "cast"},
		],
	},
	"frost_troll": {
		"name": "Crag Trolls", "tagline": "Storm-hardened clans of the Broken Mountains",
		"skin": Color("7195a9"), "accent": Color("687047"),
		"visual": {"hair_style": "crest", "hair": Color("343b3e"), "eye": Color("332c25"), "boot": Color("4b4238"), "body_shape": "top_heavy", "skin_pattern": "mottled"},
		"scale": 1.16, "head": Vector2(70, 64), "torso": Vector2(136, 86),
		"arm": 100.0, "leg": 54.0, "limb_width": 48.0, "leg_width": 42.0,
		"shoulder_spread": 0.40, "extremity_scale": 1.85, "head_sprite_scale": 1.6, "head_y_adjust": 14.0,
		"armor_width_scale": 1.45, "pants_width_scale": 1.35, "topology": "biped",
		"gestures": [
			{"name": "Glacier Cleave", "style": "smash"},
			{"name": "Boulder Rush", "style": "thrust"},
			{"name": "Avalanche", "style": "leap"},
		],
	},
	"goblin": {
		"name": "Deep Goblins", "tagline": "Ingenious tunnel societies of the Underdeep",
		"skin": Color("91a44a"), "accent": Color("b77c3f"),
		"visual": {"hair_style": "crop", "hair": Color("493527"), "eye": Color("d7a63d"), "boot": Color("55402d")},
		"scale": 0.8, "head": Vector2(58, 46), "torso": Vector2(70, 54),
		"arm": 50.0, "leg": 40.0, "limb_width": 24.0, "leg_width": 24.0,
		"head_sprite_scale": 1.8, "head_y_adjust": 12.0, "topology": "biped",
		"gestures": [
			{"name": "Snap Shot", "style": "shoot"},
			{"name": "Low Blow", "style": "slash"},
			{"name": "Powder Keg", "style": "cast"},
		],
	},
	"duneborn": {
		"name": "Sunscour", "tagline": "Desert travelers and keepers of water routes",
		"skin": Color("bf825d"), "accent": Color("8d493d"),
		"visual": {"hair_style": "none", "hair": Color("302823"), "eye": Color("9b6b2e"), "boot": Color("6b4a35"), "body_shape": "lean"},
		"scale": 0.94, "head": Vector2(50, 56), "torso": Vector2(90, 74),
		"arm": 61.0, "leg": 64.0, "limb_width": 26.0, "leg_width": 26.0,
		"shoulder_spread": 0.30, "head_sprite_scale": 1.52, "topology": "biped",
		"gestures": [
			{"name": "Sirocco Thrust", "style": "thrust"},
			{"name": "Crescent Guard", "style": "slash"},
			{"name": "Sand Veil", "style": "cast"},
		],
	},
	"frostling": {
		"name": "Rimeborn", "tagline": "Cold-adapted keepers of warmth in the Ice Lands",
		"skin": Color("8795a7"), "accent": Color("37658b"),
		"visual": {"hair_style": "shaggy", "hair": Color("e3e7e5"), "eye": Color("73c9ef"), "boot": Color("3b5366"), "body_shape": "compact"},
		"scale": 0.84, "head": Vector2(61, 57), "torso": Vector2(80, 55),
		"arm": 47.0, "leg": 39.0, "limb_width": 24.0, "leg_width": 25.0,
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


static func is_shield(item_id: String) -> bool:
	return item_id in SHIELD_ITEMS


static func reference_loadout(race_id: String) -> Dictionary:
	return REFERENCE_LOADOUTS.get(race_id,REFERENCE_LOADOUTS["human"]).duplicate()
