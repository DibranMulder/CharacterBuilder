extends SceneTree
func _initialize() -> void: _capture.call_deferred()
func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	for entry in [["approach",2040,480,"guardian"],["stair",2180,-220,"summit"],["apothecary",670,480,"provisions"],["square",1015,480,"map"],["solar",1335,480,"heir"]]:
		set_meta("wendmere_destination",entry[0])
		set_meta("wendmere_quest",3)
		var scene = load("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
		viewport.add_child(scene)
		scene.set_physics_process(false)
		scene.get_window().focus_exited.disconnect(scene._lose_focus)
		scene.model.position = Vector2(entry[1],entry[2])
		scene._update_view(1)
		if entry[3] in ["provisions","heir"]: scene._talk_to_rowan()
		if entry[3] == "map": scene._toggle_town_map()
		for frame in 3: await process_frame
		RenderingServer.force_draw(false)
		assert(viewport.get_texture().get_image().save_png("res://artifacts/hometown_"+entry[3]+".png") == OK)
		scene.queue_free()
		await process_frame
	print("PASS: guardian, summit, provisions, map and heir-warden rendered")
	quit()
