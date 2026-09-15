extends RefCounted
## Explicit test navigation resolves only maps with an implemented scene.
const Catalog = preload("res://src/world/world_catalog.gd")
const Districts = preload("res://prototypes/human_hometown/districts.gd")
const Region = preload("res://prototypes/tidekin_sea/region.gd")
const Tutorial = preload("res://prototypes/training_clearing/tutorial.gd")
static func destination(id: String) -> Dictionary:
	var entry := Catalog.node(id)
	if entry.is_empty() or entry.runtime_id.is_empty(): return {}
	if entry.region == "open_lands" and Districts.NAMES.has(id):
		return {"kind":"town","id":id,"scene":"res://prototypes/human_hometown/human_hometown.tscn"}
	if entry.region == "tidekin_sea":
		var index := Region.index_of(entry.runtime_id)
		if index >= 0: return {"kind":"tidekin","id":id,"index":index,"scene":"res://prototypes/tidekin_sea/tidekin_sea.tscn"}
	for i in Tutorial.MAPS.size():
		if Tutorial.MAPS[i].id == entry.runtime_id:
			return {"kind":"training","id":id,"index":i,"scene":"res://prototypes/training_clearing/training_clearing.tscn"}
	return {}
