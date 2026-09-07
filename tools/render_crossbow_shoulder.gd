extends "res://tools/render_centaur_views.gd"


func _render() -> void:
	RenderingServer.set_default_clear_color(Color("101a2b"))
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1600, 1520)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Node2D.new()
	viewport.add_child(canvas)
	var index := 0
	for race in CharacterCatalog.RACES:
		for facing in [&"right", &"left"]:
			var origin := Vector2(index % 4 * 400, index / 4 * 380)
			_add_rect(canvas, Rect2(origin + Vector2(8, 8), Vector2(384, 364)), Color("192b43"), -90)
			var label := Label.new()
			label.position = origin + Vector2(20, 20)
			label.text = "%s / %s" % [race.to_upper(), facing.to_upper()]
			canvas.add_child(label)
			var avatar := Avatar.new()
			avatar.position = origin + Vector2(200, 335)
			canvas.add_child(avatar)
			var equipment := CharacterCatalog.reference_loadout(race)
			equipment.weapon = "crossbow"
			equipment.offhand = "none"
			avatar.configure(race, equipment)
			avatar.set_facing(facing)
			avatar.play_weapon_attack(&"fire_crossbow")
			for sample in 42:
				avatar._active_tween.custom_step(1.0 / 120.0)
			avatar._active_tween.pause()
			avatar._process(0.0)
			index += 1
	for frame in 6:
		await process_frame
	var result := viewport.get_texture().get_image().save_png("res://artifacts/crossbow_shoulder_all_lineages.png")
	quit(0 if result == OK else 1)
