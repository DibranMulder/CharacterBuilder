extends "res://tools/render_centaur_views.gd"


func _render() -> void:
	RenderingServer.set_default_clear_color(Color("101a2b"))
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1600, 650)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Node2D.new()
	viewport.add_child(canvas)
	for index in 4:
		_add_rect(canvas, Rect2(10 + index * 400, 60, 380, 550), Color("192b43"), -90)
		var label := Label.new()
		label.position = Vector2(25 + index * 400, 80)
		label.text = ["REFERENCE", "BALACLAVA EQUIPPED", "HEADGEAR REMOVED", "REAR / CLIMB"][index]
		label.add_theme_font_size_override("font_size", 21)
		canvas.add_child(label)
	var atlas := AtlasTexture.new()
	atlas.atlas = load("res://designs/references/dark-lineages.png")
	atlas.region = Rect2(815, 345, 252, 382)
	var reference := Sprite2D.new()
	reference.texture = atlas
	reference.position = Vector2(200, 355)
	canvas.add_child(reference)
	for index in 3:
		var avatar := Avatar.new()
		avatar.position = Vector2(600 + 400 * index, 540)
		avatar.scale = Vector2.ONE * 1.65
		canvas.add_child(avatar)
		avatar.configure("duneborn", CharacterCatalog.reference_loadout("duneborn"))
		if index == 1:
			avatar.equip(&"head", "none")
		if index == 2:
			avatar.play_motion(&"climb")
			avatar._active_tween.custom_step(.28)
	for frame in 6:
		await process_frame
	var result := viewport.get_texture().get_image().save_png("res://artifacts/duneborn_reference_comparison.png")
	quit(0 if result == OK else 1)
