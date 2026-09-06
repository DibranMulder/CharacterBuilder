extends SceneTree

const Avatar := preload("res://src/modular_character.gd")


func _initialize() -> void:
	assert(&"pants" in CharacterCatalog.SLOT_ORDER)
	assert(CharacterCatalog.items_for(&"pants").size() >= 4)
	assert(&"boots" in CharacterCatalog.SLOT_ORDER)
	assert(CharacterCatalog.items_for(&"boots") == ["none", "wraps", "leather", "plate"])
	assert(CharacterCatalog.SHIELD_ITEMS == ["shield", "marsh_shield", "dune_shield"])
	for shield_item in CharacterCatalog.SHIELD_ITEMS:
		assert(shield_item in CharacterCatalog.items_for(&"offhand"))
	var avatar := Avatar.new()
	root.add_child(avatar)
	for race_id in CharacterCatalog.race_ids():
		var reference_loadout := CharacterCatalog.reference_loadout(race_id)
		assert(reference_loadout.size() == CharacterCatalog.SLOT_ORDER.size(), "%s reference kit does not define all slots" % race_id)
		for slot in CharacterCatalog.SLOT_ORDER:
			assert(reference_loadout.has(String(slot)), "%s reference kit omits %s" % [race_id,slot])
			assert(reference_loadout[String(slot)] in CharacterCatalog.items_for(slot), "%s reference kit uses unknown %s item %s" % [race_id,slot,reference_loadout[String(slot)]])
		avatar.configure(race_id, {})
		assert(avatar.available_gestures().size() == 3)
		for slot in CharacterCatalog.SLOT_ORDER:
			for item in CharacterCatalog.items_for(slot):
				if avatar.supports_equipment_slot(slot):
					assert(avatar.equip(slot, item), "%s rejected %s" % [slot, item])
				else:
					assert(not avatar.equip(slot,item), "%s accepted unsupported %s" % [race_id,slot])
		for gesture_index in avatar.available_gestures().size():
			avatar.play_gesture(gesture_index)
	print("PASS: 8 races, 8 equipment slots, all items, and 24 gestures")
	quit()
