extends SceneTree
func _initialize() -> void: _capture.call_deferred()
func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var scene = load("res://prototypes/sparring_arena/arena.tscn").instantiate()
	viewport.add_child(scene)
	scene.set_physics_process(false)
	scene.model.countdown = 0
	scene.model.fighters[0].position.x = 400
	scene.model.fighters[1].position.x = 700
	scene.model.fighters[1].request(0)
	scene.model.fighters[1].action_time = .2
	scene._update_view()
	for frame in 10: await process_frame
	RenderingServer.force_draw(false)
	RenderingServer.force_draw(false)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/sparring_arena.png") == OK)
	scene._toggle_skills()
	scene.skill_overview._select_skill(2)
	for frame in 10: await process_frame
	RenderingServer.force_draw(false)
	RenderingServer.force_draw(false)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/skill_overview.png") == OK)
	quit()
