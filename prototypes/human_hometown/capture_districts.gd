extends SceneTree
const Districts = preload("res://prototypes/human_hometown/districts.gd")
func _initialize() -> void: _capture.call_deferred()
func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1152,648)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	for id in Districts.NAMES:
		set_meta("wendmere_destination",id)
		var scene = load("res://prototypes/human_hometown/human_hometown.tscn").instantiate()
		viewport.add_child(scene)
		scene.set_physics_process(false)
		scene.get_window().focus_exited.disconnect(scene._lose_focus)
		scene.model.position.x = 1200
		scene._update_view(1)
		for frame in 3: await process_frame
		RenderingServer.force_draw(false)
		var result := viewport.get_texture().get_image().save_png("res://artifacts/hometown_"+id+".png")
		assert(result == OK)
		scene.queue_free()
		await process_frame
	print("PASS: rendered all fifteen districts")
	quit()
