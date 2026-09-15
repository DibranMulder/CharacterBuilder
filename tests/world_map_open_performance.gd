extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
	if DisplayServer.get_name() == "headless":
		print("SKIP: rendered opening benchmark requires a graphics display (omit --headless)")
		quit()
		return
	var scene = load("res://prototypes/tidekin_sea/tidekin_sea.tscn").instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	for frame in 5: await process_frame
	var failed := false
	for attempt in 3:
		var start := Time.get_ticks_usec()
		scene._toggle_world_map()
		await RenderingServer.frame_post_draw
		var ms := (Time.get_ticks_usec()-start)/1000.0
		print("OPEN %d: %.1f ms" % [attempt,ms])
		var budget := 250.0 if attempt == 0 else 150.0
		if ms > budget: failed = true
		scene._toggle_world_map()
		await process_frame
	scene.queue_free()
	await process_frame
	print("FAIL: map opening exceeds 250ms cold / 150ms warm budget" if failed else "PASS: map opening within 250ms cold / 150ms warm budget")
	quit(1 if failed else 0)
