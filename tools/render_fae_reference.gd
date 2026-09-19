extends "res://tools/render_centaur_views.gd"


func _render() -> void:
	RenderingServer.set_default_clear_color(Color("101a2b"))
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1400, 620)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Node2D.new()
	viewport.add_child(canvas)
	for index in 3:
		_add_rect(canvas, Rect2(15 + index * 460, 70, 450, 470), Color("192b43"), -90)
		var label := Label.new()
		label.position = Vector2(35 + index * 460, 90)
		label.text = ["LIGHT-LINEAGES REFERENCE", "REBUILT / SIDE", "REAR / CLIMB"][index]
		label.add_theme_font_size_override("font_size", 22)
		label.add_theme_color_override("font_color", Color("f2d181"))
		canvas.add_child(label)
	var atlas := AtlasTexture.new()
	atlas.atlas = load("res://designs/references/light-lineages.png")
	atlas.region = Rect2(965, 432, 366, 335)
	var reference := Sprite2D.new()
	reference.texture = atlas
	reference.position = Vector2(240, 327)
	canvas.add_child(reference)
	for index in 2:
		var avatar := Avatar.new()
		avatar.position = Vector2(705 + 460 * index, 475)
		avatar.scale = Vector2.ONE * 1.65
		canvas.add_child(avatar)
		avatar.configure("fae", CharacterCatalog.reference_loadout("fae"))
		if index == 1:
			avatar.play_motion(&"climb")
			avatar._active_tween.custom_step(.28)
	for frame in 6:
		await process_frame
	var result := viewport.get_texture().get_image().save_png("res://artifacts/fae_reference_comparison.png")
	if result != OK:
		quit(1)
		return
	print("PASS: rendered Aeralith reference, live side and rear views")
	quit()
