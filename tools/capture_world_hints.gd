extends SceneTree
func _initialize() -> void: _capture.call_deferred()
func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	set_meta("wendmere_destination","square")
	var scene = load("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
	viewport.add_child(scene)
	scene.set_physics_process(false)
	scene.get_window().focus_exited.disconnect(scene._lose_focus)
	scene.model.position = Vector2(1200,270)
	scene._update_view(1)
	await capture(viewport,"world_hints_icons")
	for marker in scene.exit_markers:
		if marker.visible:
			marker._set_expanded(true)
			break
	await capture(viewport,"world_hints_hover")
	scene._toggle_world_map()
	scene.map_panel.open_region("tidekin_sea")
	scene.map_panel.select_node("tidekin_sea_return_116")
	await capture(viewport,"map_test_teleport")
	scene.queue_free()
	await process_frame
	quit()
func capture(viewport: SubViewport, title: String) -> void:
	for frame in 8: await process_frame
	RenderingServer.force_draw(false)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/"+title+".png") == OK)
