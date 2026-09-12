extends SceneTree
func _initialize() -> void: _capture.call_deferred()
func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var scene = load("res://prototypes/human_hometown/market_row.tscn").instantiate()
	viewport.add_child(scene)
	scene.set_physics_process(false)
	scene.get_window().focus_exited.disconnect(scene._lose_focus)
	for entry in [[430,"smith"],[1130,"armor"],[1780,"arcane"],[2140,"gate"]]:
		scene.model.position.x = entry[0]
		scene._update_view(1)
		for frame in 5: await process_frame
		RenderingServer.force_draw(false)
		RenderingServer.force_draw(false)
		assert(viewport.get_texture().get_image().save_png("res://artifacts/market_%s.png"%entry[1]) == OK)
	scene.model.position.x = 500
	scene._update_view(1)
	scene._talk_to_rowan()
	assert(is_instance_valid(scene.dialogue),"merchant dialogue opened")
	for frame in 5: await process_frame
	RenderingServer.force_draw(false)
	RenderingServer.force_draw(false)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/market_dialogue.png") == OK)
	scene._open_shop()
	assert(is_instance_valid(scene.shop),"specialist shop opened")
	for frame in 5: await process_frame
	RenderingServer.force_draw(false)
	RenderingServer.force_draw(false)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/market_shop.png") == OK)
	print("PASS: Market Row storefronts, captain, merchant portrait and specialized shop rendered")
	quit()
