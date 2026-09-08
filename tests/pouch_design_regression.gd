extends SceneTree
const Clearing = preload("res://prototypes/training_clearing/training_clearing.tscn")

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	for lineage in CharacterCatalog.race_ids():
		set_meta("training_character", {"lineage":lineage,"loadout":CharacterCatalog.reference_loadout(lineage)})
		var scene = Clearing.instantiate()
		root.add_child(scene)
		scene.set_physics_process(false)
		scene.model.inventory.grant({"items":[{"slot":"weapon","id":"crossbow"},{"slot":"pants","id":"cloth"}]})
		scene._toggle_inventory()
		var panel = scene.inventory_panel
		assert(panel.tiles.size() == 32, "24 pouch cells and 8 supported equipment slots")
		assert(panel.preview.loadout == scene.avatar.loadout)
		for tile in panel.tiles:
			assert(Rect2(Vector2.ZERO,panel.size).encloses(tile.get_rect()))
		var weapon_tile: Control
		var pants_tile: Control
		for tile in panel.tiles:
			if tile.equipment_slot == "weapon": weapon_tile = tile
			if tile.equipment_slot == "pants": pants_tile = tile
		var data := {"panel":panel,"index":0,"slot":"","item":{"slot":"weapon","id":"crossbow"}}
		assert(panel.can_drop_on(weapon_tile,data))
		assert(not panel.can_drop_on(pants_tile,data))
		assert(not panel.can_drop_on(weapon_tile,{"panel":panel}))
		panel.highlight_targets(data)
		assert(weapon_tile.compatible and not pants_tile.compatible)
		panel.drop_on(pants_tile,data)
		assert(scene.model.inventory.items.size() == 2)
		panel.drop_on(weapon_tile,data)
		assert(scene.avatar.loadout.weapon == "crossbow")
		assert(panel.preview.loadout == scene.avatar.loadout)
		for tile in panel.tiles:
			if tile.equipment_slot == "pants": pants_tile = tile
		var pants_data := {"panel":panel,"index":0,"slot":"","item":{"slot":"pants","id":"cloth"}}
		assert(panel.can_drop_on(pants_tile,pants_data) == (lineage != "centaur"))
		var unequip := {"panel":panel,"index":-1,"slot":"weapon","item":{"slot":"weapon","id":"crossbow"}}
		assert(panel.can_drop_on(panel.tiles[23],unequip))
		panel.drop_on(panel.tiles[23],unequip)
		assert(scene.model.weapon == "none")
		assert(not panel.can_drop_on(panel.tiles[23],unequip), "stale drag must not duplicate equipment")
		panel.filter = "Potions"
		panel.refresh()
		assert(panel.tiles[0].item.slot == "potion")
		for i in 30:
			scene.model.inventory.grant({"items":[{"slot":"weapon","id":"sword"}]})
		panel.filter = "Gear"
		panel.page = 1
		panel.refresh()
		assert(panel.tiles[0].bag_index == 24, "paging keeps real inventory indices")
		scene.free()
	remove_meta("training_character")
	print("PASS: parchment pouch layout, eight lineage previews, equip/unequip drops, invalid drops, filtering and paging")
	quit()
