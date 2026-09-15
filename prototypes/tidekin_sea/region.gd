extends RefCounted
const DATA_PATH := "res://prototypes/tidekin_sea/region.json"
static var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
static func maps() -> Array: return data.maps
static func spec(id: String) -> Dictionary:
	for entry in data.maps:
		if entry.id == id: return entry
	return {}
static func creature(id: String) -> Dictionary: return data.creatures[id]
static func index_of(id: String) -> int:
	for i in data.maps.size():
		if data.maps[i].id == id: return i
	return -1
static func allowed(id: String, lineage: String, shrine_open: bool) -> String:
	var entry := spec(id)
	if entry.is_empty(): return "Unknown destination"
	if entry.access == "Light" and lineage not in ["human","bogkin","centaur","fae"]: return "Pearl Citadel admits Light allegiance only"
	if entry.group == "story" and not shrine_open: return "Speak with Sera and investigate the wells first"
	return ""
