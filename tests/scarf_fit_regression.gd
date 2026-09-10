extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for race in CharacterCatalog.race_ids():
		var avatar := preload("res://src/modular_character.gd").new()
		root.add_child(avatar)
		var outfit := CharacterCatalog.reference_loadout(race)
		outfit.accessory = "scarf"
		avatar.configure(race,outfit)
		avatar.play_motion(&"stand")
		if race == "frost_troll":
			assert(avatar.loadout.accessory == "none")
			assert(not avatar.equip(&"accessory","scarf"))
			assert(not avatar._gear.accessory.visible)
			var inventory = preload("res://prototypes/training_clearing/inventory.gd").new()
			inventory.configure(race,outfit)
			assert(inventory.equipped.accessory == "none")
			inventory.grant({"items":[{"slot":"accessory","id":"scarf"}]})
			assert(not inventory.equip(0) and inventory.items.size() == 1)
			assert(avatar.equip(&"accessory","amulet"))
			avatar.free()
			continue
		var scarf: GearVisual = avatar._gear.accessory
		assert(scarf.fitted_cloth and scarf.z_index < avatar._head_base.z_index,"Jaw must occlude scarf on every lineage")
		assert(scarf.scale.x > .7 and scarf.scale.x < 1.8)
		for facing in [&"left",&"right"]:
			avatar.set_facing(facing)
			for rear in [false,true]:
				avatar._set_back_view(rear)
				assert(scarf.back_view == rear)
				for bend in [-.3,0.0,.3]:
					var anchor := Vector2(0,4)
					var deformed := ClothSurface.deform(anchor,Vector2(.5,0),bend)
					assert(deformed.rotated(bend).is_equal_approx(anchor),"Collar cannot swing away with the tail")
		avatar.free()
	print("PASS: scarf fit for supported lineages; trolls reject scarves in rig and inventory")
	quit()
