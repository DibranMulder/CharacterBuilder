extends SceneTree
func _initialize() -> void: _capture.call_deferred()
func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	for entry in [["square",1100,480,"routes",0],["square",1200,270,"portal",0],["hall",1570,270,"sealed_tower",0],["hall",1570,270,"open_tower",3],["barracks",994,410,"climbing",3]]:
		if "square-only" in OS.get_cmdline_user_args() and entry[0] != "square": continue
		set_meta("wendmere_destination",entry[0])
		set_meta("wendmere_quest",entry[4])
		var scene = load("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
		viewport.add_child(scene)
		scene.set_physics_process(false)
		scene.get_window().focus_exited.disconnect(scene._lose_focus)
		scene.model.position = Vector2(entry[1],entry[2])
		if entry[3] == "climbing":
			scene.model.climb_axis = -1
			scene.model.step(1.0/60,0,false)
		scene._update_view(1)
		for frame in 12: await process_frame
		RenderingServer.force_draw(false)
		assert(viewport.get_texture().get_image().save_png("res://artifacts/hometown_"+entry[3]+".png") == OK)
		scene.queue_free()
		await process_frame
	print("PASS: routes, portals, sealed/open tower and climbing rendered")
	quit()
