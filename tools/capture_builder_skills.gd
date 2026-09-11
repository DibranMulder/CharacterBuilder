extends SceneTree

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	root.size = Vector2i(1152,648)
	var builder: Node = load("res://main.tscn").instantiate()
	root.add_child(builder)
	await process_frame
	builder.get_node("BuilderPanel").hide()
	builder.skills_panel.show()
	var cases := [
		[0,0,.42,"crosscut"],
		[0,1,.65,"resolute_rush"],
		[0,2,.95,"rally"],
		[0,3,1.8,"second_wind"],
		[1,0,.42,"basic_slash"],
		[1,1,.25,"quick_cut"],
		[1,2,.64,"heavy_cut"],
		[1,3,.49,"pommel_strike"],
		[1,4,.48,"sweeping_edge"],
		[1,5,.43,"guarded_riposte"],
		[1,6,1.95,"blade_rhythm"],
	]
	var sheet := Image.create(1424,720,false,Image.FORMAT_RGBA8)
	sheet.fill(Color("111827"))
	var index := 0
	for sample in cases:
		builder.skills_panel._select_category(sample[0])
		builder.skills_panel._select_skill(sample[1])
		builder.avatar.play_skill_preview(builder.skills_panel.selected_id)
		await create_timer(sample[2]).timeout
		await RenderingServer.frame_post_draw
		var path := "res://artifacts/builder_skill_%s.png" % sample[3]
		var frame := root.get_texture().get_image()
		assert(frame.save_png(path) == OK)
		var tile := frame.get_region(Rect2i(440,178,712,450))
		tile.resize(356,225,Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(tile,Rect2i(0,0,356,225),Vector2i((index%4)*356,(index/4)*240))
		index += 1
		print("Captured "+path)
	assert(sheet.save_png("res://artifacts/builder_skills_showcase.png") == OK)
	quit()
