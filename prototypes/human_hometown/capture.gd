extends SceneTree
func _initialize() -> void: _capture.call_deferred()
func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var scene = load("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
	viewport.add_child(scene)
	scene.set_physics_process(false)
	scene.get_window().focus_exited.disconnect(scene._lose_focus)
	for entry in [[350,"west"],[1150,"square"],[1510,"market"],[2180,"east"]]:
		scene.model.position.x = entry[0]
		scene._update_view(1)
		for frame in 5: await process_frame
		RenderingServer.force_draw(false)
		RenderingServer.force_draw(false)
		assert(viewport.get_texture().get_image().save_png("res://artifacts/wendmere_%s.png"%entry[1]) == OK)
	scene.model.position.x = 1560
	scene._update_view(1)
	scene._talk_to_rowan()
	scene._open_shop()
	for frame in 5: await process_frame
	assert(is_instance_valid(scene.shop))
	RenderingServer.force_draw(false)
	RenderingServer.force_draw(false)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/wendmere_shop.png") == OK)
	print("PASS: Wendmere west, square, market, east and working shop rendered")
	quit()
