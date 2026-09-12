extends SceneTree
func _initialize() -> void: _capture.call_deferred()
func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	set_meta("start_clearing_tutorial",true)
	var scene = load("res://prototypes/training_clearing/training_clearing.tscn").instantiate()
	viewport.add_child(scene)
	scene.set_physics_process(false)
	for index in 4:
		scene._adopt_map(scene.tutorial._enter(index))
		if index == 1:
			scene.model.position.x = 640
			scene.model.enemies[0].state = "windup"
			scene.model.enemies[0].timer = .7
		elif index == 2: scene.model.position.x = 250
		elif index == 3: scene.model.position.x = 850
		scene._update_view(1)
		for frame in 5: await process_frame
		if scene.talk_button.visible:
			assert(not scene.tutorial_panel.get_global_rect().intersects(scene.talk_button.get_global_rect()),"hint must not cover Rowan interaction")
		assert(scene.tutorial_panel.size.y == 64,"only a compact world hint")
		assert(scene.tutorial_panel.title.get_minimum_size().x <= 316,"hint heading must fit")
		assert(scene.tutorial_panel.body.get_minimum_size().x <= 316,"one-line action must fit")
		assert(viewport.get_texture().get_image().save_png("res://artifacts/tutorial_map_%d.png"%index) == OK)
	scene._adopt_map(scene.tutorial._enter(2))
	scene.model.position.x = 250
	scene.model.inventory.grant({"coins":16})
	scene._talk_to_rowan()
	scene._open_shop()
	scene._update_view(0)
	for frame in 5: await process_frame
	assert(not scene.tutorial_panel.visible and scene.menu_hint.visible)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/tutorial_shop_hint.png") == OK)
	scene._close_rowan()
	# A smaller viewport uses the same supported canvas scaling and keeps hints inside it.
	viewport.size = Vector2i(800,600)
	scene._update_view(0)
	for frame in 5: await process_frame
	var bounds: Rect2 = scene.tutorial_panel.get_global_rect()
	assert(bounds.position.x >= 0 and bounds.end.x <= 800 and bounds.end.y <= 600)
	print("PASS: four distinct maps, short world hints, contextual menu hint and 800×600 bounds")
	quit()
