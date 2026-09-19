extends SceneTree
func _initialize() -> void: run.call_deferred()
func capture(viewport: SubViewport, label: String) -> void:
	for frame in 3: await process_frame
	RenderingServer.force_draw(false)
	viewport.get_texture().get_image().save_png("res://artifacts/tidekin_svg_"+label+".png")
func run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var scene = load("res://prototypes/tidekin_sea/tidekin_sea.tscn").instantiate()
	viewport.add_child(scene)
	scene.set_physics_process(false)
	if scene.get_window().focus_exited.is_connected(scene._lose_focus): scene.get_window().focus_exited.disconnect(scene._lose_focus)
	for spec in scene.MAPS:
		scene.enter_map(scene.Region.index_of(spec.id),false)
		var portal: Array = spec.portals.back().point
		scene.model.position = Vector2(portal[0],portal[1])
		scene.camera_x = clampf(scene.model.position.x-430,0,scene.model.world_width-1152)
		scene.camera_y = minf(0,scene.model.position.y-425)
		scene._update_view(0)
		await capture(viewport,spec.id)
	scene.enter_map(0,false)
	scene._toggle_world_map()
	await capture(viewport,"atlas")
	scene._toggle_world_map()
	scene.enter_map(scene.Region.index_of("tidekin_sea_cm"),false)
	scene.model.position = Vector2(scene.residents[0].x-75,480)
	scene.camera_x = maxf(0,scene.model.position.x-430)
	scene.interact()
	await capture(viewport,"dialogue")
	scene.queue_free()
	await process_frame
	print("PASS: captured all 39 SVG maps, atlas and resident dialogue")
	quit()
