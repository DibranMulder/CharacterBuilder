extends RefCounted
## Each resident has a dedicated painted identity, shared by world and conversation.
const SHEETS := {
	"villagers":["elowen","broker","brann","tessa","orin","mira"],
	"townsfolk":["grocer","innkeeper","quartermaster","orchard","cook","smith"],
	"trainers":["trainer_0","trainer_1","trainer_2","trainer_3","trainer_4","trainer_5"],
	"wardens":["gatecaptain","courier","aldren","recruit","herald","steward"],
	"court":["king","counsellor","meriel","treasurer","lyra","attendant"],
	"towerfolk":["keeper","lamplighter"],
}
static var portraits := {}
static var key_material: ShaderMaterial
static func material() -> ShaderMaterial:
	if key_material == null:
		key_material = ShaderMaterial.new()
		key_material.shader = preload("res://prototypes/training_clearing/pouch_art.gdshader")
	return key_material
static func texture(id: String) -> AtlasTexture:
	if portraits.has(id): return portraits[id]
	for sheet in SHEETS:
		var index: int = SHEETS[sheet].find(id)
		if index < 0: continue
		var source: Texture2D = load("res://assets/npcs/wendmere/residents_"+sheet+".png")
		var columns := 2 if sheet == "towerfolk" else 3
		var rows := 1 if sheet == "towerfolk" else 2
		var cell := Vector2i(source.get_width()/columns,source.get_height()/rows)
		var origin := Vector2i(index%columns,index/columns)*cell
		var art := AtlasTexture.new()
		art.atlas = source
		art.region = Rect2(origin,cell)
		portraits[id] = art
		return art
	push_error("Missing resident artwork: "+id)
	return null
static func height(id: String) -> float:
	if id == "king": return 220
	if id in ["brann","smith","aldren","gatecaptain","trainer_0","trainer_1"]: return 190
	return 174
