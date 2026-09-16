extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var scene = load("res://prototypes/tidekin_sea/tidekin_sea.tscn").instantiate()
	viewport.add_child(scene)
	scene.set_physics_process(false)
	if scene.get_window().focus_exited.is_connected(scene._lose_focus): scene.get_window().focus_exited.disconnect(scene._lose_focus)
	for spec in [["landing",0,180],["market",3,1800],["trainers",6,1700],["guardian",8,1500],["combat",1,650],["shrine",16,1800]]:
		scene.enter_map(spec[1],false)
		scene.model.position = Vector2(spec[2],480)
		scene.camera_x = maxf(0,spec[2]-430)
		if spec[0] == "combat":
			var enemy: Dictionary = scene.model.enemies[0]
			enemy.state = "strike"
			enemy.attack_origin = enemy.x
			enemy.target_x = scene.model.position.x
			enemy.timer = .1
		scene._update_view(0)
		for i in 8: await process_frame
		RenderingServer.force_draw(false)
		viewport.get_texture().get_image().save_png("res://artifacts/tidekin_updated_"+spec[0]+".png")
	scene.enter_map(4,false)
	scene.model.position = Vector2(scene.residents[0].x,480)
	scene.camera_x = scene.model.position.x-430
	scene.interact()
	for i in 8: await process_frame
	RenderingServer.force_draw(false)
	viewport.get_texture().get_image().save_png("res://artifacts/tidekin_updated_dialogue.png")
	scene.queue_free()
	await process_frame
	quit()
