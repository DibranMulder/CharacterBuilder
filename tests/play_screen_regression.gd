extends SceneTree

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	var Encounter = load("res://prototypes/training_clearing/encounter.gd")
	for lineage in CharacterCatalog.race_ids():
		for slot in 4:
			var model = Encounter.new()
			model.inventory.configure(lineage,CharacterCatalog.reference_loadout(lineage))
			model.position.x = 530
			model.health = 50
			model.invulnerable = 10
			var skill: Dictionary = model.lineage_kit()[slot]
			assert(model.begin_lineage_skill(slot))
			assert(is_equal_approx(model.mana,100-skill.mana))
			assert(not model.begin_lineage_skill(slot))
			for i in 100: model.step(.01,0,false)
			match skill.kind:
				"heal": assert(model.health > 50)
				"ward": assert(model.ward == skill.power)
				"retreat": assert(model.position.x < 530)
				_: assert(model.enemies[0].hp < 50,"Skill must affect clearing target: "+skill.name)
			assert(model.lineage_cooldowns[slot] > 0)
			model.attack_time = 0
			model.lineage_cooldowns[slot] = 0
			model.mana = 0
			assert(not model.begin_lineage_skill(slot))
	var clearing = load("res://prototypes/training_clearing/training_clearing.tscn").instantiate()
	root.add_child(clearing)
	clearing.set_physics_process(false)
	assert(clearing.skill_buttons.size() == 6)
	for i in 6:
		var tile = clearing.skill_buttons[i]
		assert(tile.visible and tile.hotkey == str(i+3) and tile.position.y == 116)
	for child in clearing.get_children():
		if child is BaseButton and child not in clearing.skill_buttons: assert(not child.visible)
	var event := InputEventKey.new()
	event.pressed = true
	event.physical_keycode = KEY_5
	clearing._unhandled_key_input(event)
	assert(clearing.model.active_skill.is_empty(),"A locked shortcut must not activate")
	clearing.model.progression.award("defense",preload("res://src/discipline_progress.gd").threshold(5))
	clearing._unhandled_key_input(event)
	assert(clearing.model.active_skill.name == clearing.skill_buttons[2].skill.name)
	clearing._toggle_inventory()
	var pouch_tabs := {}
	for child in clearing.inventory_panel.get_children():
		if child is Button and child.position.y == 18: pouch_tabs[child.text] = child.position
	clearing._toggle_skills()
	for child in clearing.skill_overview.get_children():
		if child is Button and child.text in ["Gear & Pouch","Combat Skills"]:
			assert(pouch_tabs[child.text] == child.position)
	clearing.free()
	var arena = load("res://prototypes/sparring_arena/arena.tscn").instantiate()
	root.add_child(arena)
	arena.set_physics_process(false)
	arena._update_view()
	for child in arena.get_children():
		if child is BaseButton and child not in arena.skill_buttons: assert(not child.visible)
	arena.free()
	print("PASS: all 32 clearing skills, real hotkeys, shared menu tabs, clean play screens")
	quit()
