extends RefCounted
const SPEC := {"id":"wendmere_market","name":"Market Row","width":2400.0,
	"rowan":true,"merchant_x":530.0,"enemies":[],"platforms":[],
	"art":"res://assets/maps/wendmere/market_row.png","sentries":[2250.0]}
const MERCHANTS := [
	{"id":"brann","name":"Brann","role":"Weaponsmith","x":530.0,
		"greeting":"A sound blade, a straight shaft.\nPick something that suits your hand.",
		"gear":{"weapon":"axe","offhand":"none","armor":"leather","head":"none","back":"none","accessory":"none"},
		"stock":[{"slot":"weapon","id":"sword","price":24},{"slot":"weapon","id":"axe","price":30},
			{"slot":"weapon","id":"spear","price":26},{"slot":"weapon","id":"bow","price":28},{"slot":"weapon","id":"crossbow","price":36}]},
	{"id":"tessa","name":"Tessa","role":"Armorer","x":1230.0,
		"greeting":"Try a shield, or find a better fit.\nYour old gear is welcome in trade.",
		"gear":{"weapon":"none","armor":"plate","head":"helm","back":"cape","accessory":"none"},
		"stock":[{"slot":"offhand","id":"shield","price":18},{"slot":"armor","id":"leather","price":24},
			{"slot":"armor","id":"plate","price":42},{"slot":"pants","id":"plate","price":28},
			{"slot":"boots","id":"leather","price":12},{"slot":"head","id":"helm","price":18},{"slot":"back","id":"cape","price":16}]},
	{"id":"orin","name":"Orin","role":"Staff Merchant","x":1880.0,
		"greeting":"A focus for the road ahead?\nI stock staves, spellbooks and mana potions.",
		"gear":{"weapon":"staff","offhand":"spellbook","armor":"cloth","head":"hood","back":"long_cape","accessory":"amulet"},
		"stock":[{"slot":"weapon","id":"staff","price":32},{"slot":"weapon","id":"branch_staff","price":32},
			{"slot":"offhand","id":"spellbook","price":18},{"slot":"offhand","id":"lantern","price":12},
			{"slot":"potion","id":"mana","price":6}]},
]
static func nearest(x: float) -> int:
	var result := 0
	for i in MERCHANTS.size():
		if absf(MERCHANTS[i].x-x) < absf(MERCHANTS[result].x-x): result = i
	return result
static func loadout(index: int) -> Dictionary:
	var outfit: Dictionary = CharacterCatalog.reference_loadout("human")
	outfit.merge(MERCHANTS[index].gear,true)
	return outfit
