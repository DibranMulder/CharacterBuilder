extends SceneTree

func _initialize() -> void: _run.call_deferred()

func _run() -> void:
	root.size=Vector2i(1152,648)
	var preview = load("res://prototypes/monster_effects.tscn").instantiate()
	root.add_child(preview)
	await process_frame
	var sheet := Image.create(1728,972,false,Image.FORMAT_RGBA8)
	for index in preview.CASES.size():
		preview._select(index)
		preview.tier=2
		preview.intensity.select(2)
		preview.play()
		await create_timer(preview.release+.24).timeout
		await RenderingServer.frame_post_draw
		var frame := root.get_texture().get_image()
		assert(frame.save_png("res://artifacts/monster_effect_%d.png"%index)==OK)
		frame.resize(576,324,Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(frame,Rect2i(0,0,576,324),Vector2i((index%3)*576,(index/3)*324))
	# Third row: the same Pursuing Hew pose at each milestone.
	for tier in 3:
		preview._select(2)
		preview.tier=tier
		preview.intensity.select(tier)
		preview.play()
		await create_timer(preview.release+.24).timeout
		await RenderingServer.frame_post_draw
		var frame := root.get_texture().get_image()
		frame.resize(576,324,Image.INTERPOLATE_LANCZOS)
		sheet.blit_rect(frame,Rect2i(0,0,576,324),Vector2i(tier*576,648))
	assert(sheet.save_png("res://artifacts/monster_effects_showcase.png")==OK)
	preview.mirrored=true
	preview._select(3)
	preview.play()
	await create_timer(preview.release+.24).timeout
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://artifacts/monster_effect_mirrored.png")==OK)
	preview.impacts.reduced_effects=true
	preview.play()
	await create_timer(preview.release+.1).timeout
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://artifacts/monster_effect_reduced.png")==OK)
	print("Captured six target effects, three earth tiers, mirrored volley and reduced effects")
	quit()
