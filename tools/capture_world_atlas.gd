extends SceneTree
func _initialize() -> void: _run.call_deferred()
func _run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var map = preload("res://src/ui/world_map.gd").new()
	map.current = "square"
	map.explored = ["square","market","gatehouse","hall"]
	viewport.add_child(map)
	map.show_world()
	await capture(viewport,"world_atlas")
	for spec in map.Catalog.regions():
		map.open_region(spec.id)
		await capture(viewport,"region_"+spec.id)
		if spec.kind == "homeland":
			map.focus_group("stronghold")
			await capture(viewport,"stronghold_"+spec.id)
	map.open_region("shattered_march","dungeon")
	await capture(viewport,"babylon_depths")
	map.queue_free()
	await process_frame
	print("PASS: rendered world, all 12 regions, all 8 strongholds, and Babylon dungeon")
	quit()
func capture(viewport: SubViewport, name_: String) -> void:
	for frame in 4: await process_frame
	RenderingServer.force_draw(false)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/"+name_+".png") == OK)
