extends SceneTree
func _initialize() -> void:
	_capture.call_deferred()

func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var scene = load("res://prototypes/training_clearing/training_clearing.tscn").instantiate()
	viewport.add_child(scene)
	scene.set_physics_process(false)
	scene.model.rowan.step(2.1,scene.model.position,true)
	scene._update_view(1)
	for frame in 6: await process_frame
	assert(viewport.get_texture().get_image().save_png("res://artifacts/rowan_alive.png") == OK)
	for frame in 240:
		scene.model.rowan.step(1.0/60,scene.model.position,true)
		scene._update_view(1.0/60)
	for frame in 4: await process_frame
	assert(viewport.get_texture().get_image().save_png("res://artifacts/rowan_walking.png") == OK)
	scene.model.position.x = 230
	scene.model.inventory.grant({"coins":46,"items":[{"slot":"weapon","id":"crossbow"},{"slot":"back","id":"cape"},{"slot":"offhand","id":"shield"}]})
	scene._update_view(1)
	scene._talk_to_rowan()
	for frame in 6: await process_frame
	assert(viewport.get_texture().get_image().save_png("res://artifacts/rowan_dialogue.png") == OK)
	scene._open_shop()
	scene.shop.select_tile(scene.shop.tiles[6])
	for frame in 4: await process_frame
	assert(viewport.get_texture().get_image().save_png("res://artifacts/rowan_shop.png") == OK)
	quit()
