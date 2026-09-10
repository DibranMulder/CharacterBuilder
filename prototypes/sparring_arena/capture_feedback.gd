extends SceneTree
## Staged visual QA of Field Notes feedback; not a balance playtest.
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
	scene.model.fighters[1].ward = 10
	scene.model._hit(0,28,"melee",400)
	scene.model.fighters[0].health = 70
	scene.model._note(0,"+26 HP","heal")
	for event in scene.model.events:
		scene.feedback.push(event)
		scene.reactions[event.target].receive(event)
	scene.feedback.advance(.08)
	for reaction in scene.reactions: reaction.advance(.08)
	scene._update_view()
	for frame in 10: await process_frame
	RenderingServer.force_draw(false)
	RenderingServer.force_draw(false)
	assert(viewport.get_texture().get_image().save_png("res://artifacts/combat_feedback.png") == OK)
	quit()
