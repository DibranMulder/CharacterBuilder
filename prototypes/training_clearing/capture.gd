extends SceneTree
## Reproducible visual sample, not a claim of validated gameplay feel.

func _initialize() -> void:
	_capture.call_deferred()

func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152, 648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var scene = load("res://prototypes/training_clearing/training_clearing.tscn").instantiate()
	viewport.add_child(scene)
	scene.set_physics_process(false)
	scene.model.position.x = 520
	scene.model.guarding = true
	scene.model.moved = true
	scene.model.health = 72
	scene.model.mana = 55
	scene.model.xp = 40
	scene.feedback.push({"kind":"power", "text":"58", "position":Vector2(680,330), "impact":Vector2(620,440)})
	scene.feedback.push({"kind":"taken", "text":"−15 HP", "position":Vector2(500,290)})
	scene.feedback.advance(.12)
	scene.model.enemies[0].x = 620
	scene.model.enemies[0].state = "windup"
	scene.model.enemies[0].timer = .45
	scene._update_view(1)
	for frame in 6:
		await process_frame
	print("Staged pose: ", scene.last_pose, " / ", scene.avatar.loadout)
	var result := viewport.get_texture().get_image().save_png("res://artifacts/training_clearing.png")
	print("Clearing preview saved" if result == OK else "Capture failed")
	# Staged inventory contents for visual comparison, not starter rewards.
	scene.model.inventory.grant({"coins":16, "items":[{"slot":"weapon", "id":"crossbow"},
		{"slot":"head","id":"helm"},{"slot":"offhand","id":"shield"},
		{"slot":"back","id":"long_cape"},{"slot":"accessory","id":"amulet"},
		{"slot":"weapon","id":"axe"},{"slot":"boots","id":"leather"}]})
	scene._toggle_inventory()
	scene.inventory_panel.select_tile(scene.inventory_panel.tiles[0])
	scene._update_view(0)
	for frame in 3:
		await process_frame
	var inventory_result := viewport.get_texture().get_image().save_png("res://artifacts/training_inventory.png")
	if inventory_result != OK:
		quit(1)
		return
	quit(0 if result == OK else 1)
