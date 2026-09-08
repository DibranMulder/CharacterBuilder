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
	scene.model.enemies[0].x = 620
	scene.model.enemies[0].state = "windup"
	scene.model.enemies[0].timer = .45
	scene._update_view(1)
	for frame in 6:
		await process_frame
	print("Staged pose: ", scene.last_pose, " / ", scene.avatar.loadout)
	var result := viewport.get_texture().get_image().save_png("res://artifacts/training_clearing.png")
	print("Clearing preview saved" if result == OK else "Capture failed")
	quit(0 if result == OK else 1)
