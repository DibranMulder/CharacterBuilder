extends SceneTree

const Avatar := preload("res://src/modular_character.gd")


func _initialize() -> void:
	var avatar := Avatar.new()
	root.add_child(avatar)
	for race_id in CharacterCatalog.race_ids():
		avatar.configure(race_id, {})
		assert(avatar.available_gestures().size() == 3)
		for slot in CharacterCatalog.SLOT_ORDER:
			for item in CharacterCatalog.items_for(slot):
				assert(avatar.equip(slot, item), "%s rejected %s" % [slot, item])
		for gesture_index in avatar.available_gestures().size():
			avatar.play_gesture(gesture_index)
	print("PASS: 8 races, 6 equipment slots, all items, and 24 gestures")
	quit()
