extends SceneTree

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var arena = load("res://prototypes/sparring_arena/arena.tscn").instantiate()
	root.add_child(arena)
	arena.set_physics_process(false)
	for tile in arena.skill_buttons:
		assert(tile.position.y >= 108 and tile.position.y+tile.size.y < 190)
		assert(tile.position.x >= 112 and tile.position.x+tile.size.x <= 424)
		assert(tile.icon_atlas != null and tile.skill.has("name"))
	arena._toggle_skills()
	assert(arena.paused and is_instance_valid(arena.skill_overview))
	var start: Vector2 = arena.model.fighters[0].position
	arena._physics_process(.5)
	assert(arena.model.fighters[0].position == start)
	var event := InputEventKey.new()
	event.pressed = true
	event.physical_keycode = KEY_R
	var before = arena.model
	arena._unhandled_key_input(event)
	assert(arena.model == before,"Modal must consume restart/combat shortcuts")
	for lineage in CharacterCatalog.race_ids():
		arena.skill_overview._select_lineage(lineage)
		for slot in 4:
			arena.skill_overview._select_skill(slot)
			assert(arena.skill_overview.detail_name.text == arena.skill_overview.tiles[slot].skill.name)
	assert(arena.selection.lineage == "human","Browsing skills must not change the hero")
	arena._toggle_skills()
	assert(not arena.paused)
	arena.model.fighters[0].cooldowns[0] = 2
	arena.model.fighters[0].mana = 0
	arena._update_view()
	assert(arena.skill_buttons[0].cooldown == 2 and arena.skill_buttons[0].disabled)
	assert(not arena.skill_buttons[1].mana_available)
	arena._set_paused(true)
	arena._toggle_skills()
	arena._toggle_skills()
	assert(arena.paused,"Closing overview preserves an existing pause")
	arena.free()
	var clearing = load("res://prototypes/training_clearing/training_clearing.tscn").instantiate()
	root.add_child(clearing)
	clearing.set_physics_process(false)
	clearing._toggle_inventory()
	clearing.inventory_panel.skills_requested.emit()
	assert(not is_instance_valid(clearing.inventory_panel) and is_instance_valid(clearing.skill_overview))
	assert(clearing.paused)
	clearing.skill_overview.pouch_requested.emit()
	assert(is_instance_valid(clearing.inventory_panel) and not is_instance_valid(clearing.skill_overview))
	clearing._toggle_inventory()
	assert(not clearing.paused,"Pouch/skills switching must restore play")
	clearing.free()
	print("PASS: HUD skill placement/icons, all 32 skill details, pause safety and pouch/skills navigation")
	quit()
