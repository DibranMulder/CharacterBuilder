extends SceneTree
func _initialize() -> void: _capture.call_deferred()

func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var scene = load("res://prototypes/training_clearing/training_clearing.tscn").instantiate()
	viewport.add_child(scene)
	scene.set_physics_process(false)
	# Staged progression for legibility checks; script profiles never save.
	scene.model.progression.award("attack",175)
	scene.model.progression.award("strength",130)
	scene.model.progression.award("defense",65)
	scene.model.progression.award("focus",45)
	scene._toggle_skills()
	scene.skill_overview.show_disciplines()
	for frame in 10: await process_frame
	RenderingServer.force_draw(false)
	RenderingServer.force_draw(false)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/discipline_overview.png") == OK)
	scene.skill_overview.discipline_panel.show_skill(4)
	for frame in 5: await process_frame
	RenderingServer.force_draw(false)
	RenderingServer.force_draw(false)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/discipline_skill_detail.png") == OK)
	scene.skill_overview._select_lineage("human")
	for frame in 5: await process_frame
	RenderingServer.force_draw(false)
	RenderingServer.force_draw(false)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/skill_unlocks.png") == OK)
	quit()
