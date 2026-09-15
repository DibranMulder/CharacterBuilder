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
	for frame in 8: await process_frame
	RenderingServer.force_draw(false)
	viewport.get_texture().get_image().save_png("res://artifacts/golden_portal.png")
	scene._toggle_bindings()
	for frame in 8: await process_frame
	RenderingServer.force_draw(false)
	viewport.get_texture().get_image().save_png("res://artifacts/action_bindings.png")
	scene.queue_free()
	await process_frame
	quit()
