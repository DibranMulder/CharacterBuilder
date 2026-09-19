extends "res://tools/render_centaur_views.gd"


func _render() -> void:
	RenderingServer.set_default_clear_color(Color("101a2b"))
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1400, 650)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Node2D.new()
	viewport.add_child(canvas)
	for index in 3:
		_add_rect(canvas, Rect2(15 + index * 460, 70, 450, 540), Color("192b43"), -90)
		var label := Label.new()
		label.position = Vector2(35 + index * 460, 90)
		label.text = ["DARK-LINEAGES REFERENCE", "REBUILT / SIDE", "REAR / CLIMB"][index]
		label.add_theme_font_size_override("font_size", 22)
		canvas.add_child(label)
	var atlas := AtlasTexture.new()
	atlas.atlas = load("res://designs/references/dark-lineages.png")
	atlas.region = Rect2(599, 486, 225, 238)
	var reference := Sprite2D.new()
	reference.texture = atlas
	reference.scale = Vector2.ONE * 1.5
	reference.position = Vector2(240, 365)
	canvas.add_child(reference)
	for index in 2:
		var avatar := Avatar.new()
		avatar.position = Vector2(705 + 460 * index, 530)
		avatar.scale = Vector2.ONE * 2.5
		canvas.add_child(avatar)
		avatar.configure("goblin", CharacterCatalog.reference_loadout("goblin"))
		if index == 1:
			avatar.play_motion(&"climb")
			avatar._active_tween.custom_step(.28)
	for frame in 6:
		await process_frame
	var result := viewport.get_texture().get_image().save_png("res://artifacts/goblin_reference_comparison.png")
	quit(0 if result == OK else 1)
