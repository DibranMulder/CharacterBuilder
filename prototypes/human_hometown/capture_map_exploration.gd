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
	scene._toggle_town_map()
	scene.map_panel.open_region("open_lands")
	for view in ["fog","zoom_out"]:
		if view == "zoom_out": scene.map_panel.show_world()
		for frame in 3: await process_frame
		RenderingServer.force_draw(false)
		assert(viewport.get_texture().get_image().save_png("res://artifacts/hometown_map_"+view+".png") == OK)
	scene.queue_free()
	await process_frame
	set_meta("wendmere_destination","market")
	scene = load("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
	viewport.add_child(scene)
	scene.set_physics_process(false)
	scene.get_window().focus_exited.disconnect(scene._lose_focus)
	scene.model.position = Vector2(500,480)
	scene._select_nearby_merchant()
	scene._update_view(0)
	for frame in 3: await process_frame
	RenderingServer.force_draw(false)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/hometown_trade_hints.png") == OK)
	print("PASS: region exploration mist, world overview and trade markers rendered")
	quit()
