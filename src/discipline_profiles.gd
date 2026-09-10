extends RefCounted
## Temporary local profiles per builder lineage, until hero IDs exist.
const Progress = preload("res://src/discipline_progress.gd")
const PATH := "user://discipline_profiles_v1.json"

static func get_profile(tree: SceneTree, lineage: String):
	if not tree.has_meta("discipline_profiles"):
		var profiles := {}
		var saved: Variant = {}
		# Script-driven tests/captures must never read or overwrite player saves.
		if tree.get_script() == null and FileAccess.file_exists(PATH): saved = JSON.parse_string(FileAccess.get_file_as_string(PATH))
		for id in CharacterCatalog.race_ids():
			var progress := Progress.new()
			if saved is Dictionary and saved.get(id,{}) is Dictionary: progress.restore(saved.get(id,{}))
			profiles[id] = progress
		tree.set_meta("discipline_profiles",profiles)
	return tree.get_meta("discipline_profiles")[lineage]

static func save(tree: SceneTree) -> Error:
	if tree.get_script() != null: return OK
	if not tree.has_meta("discipline_profiles"): return OK
	var data := {}
	for id in tree.get_meta("discipline_profiles"):
		data[id] = tree.get_meta("discipline_profiles")[id].snapshot()
	var file := FileAccess.open(PATH+".tmp",FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	file.store_string(JSON.stringify(data))
	file.close()
	return DirAccess.rename_absolute(PATH+".tmp",PATH)
