extends SceneTree

func _initialize() -> void:
	_render.call_deferred()

func _render() -> void:
	for view in ["bare","scarf","left","rear","run"]:
		var viewport := SubViewport.new()
		viewport.size = Vector2i(1600,640)
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(viewport)
		var tiles: Array[SubViewport] = []
		for index in 8:
			var tile := SubViewport.new()
			tile.size = Vector2i(400,320)
			tile.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			root.add_child(tile)
			tiles.append(tile)
			var bg := ColorRect.new()
			bg.color = Color("273d4c")
			bg.z_index = -100
			bg.size = Vector2(400,320)
			tile.add_child(bg)
			var race: String = CharacterCatalog.race_ids()[index]
			var outfit := CharacterCatalog.reference_loadout(race)
			outfit.head = "none"
			outfit.accessory = "none" if view == "bare" or race == "frost_troll" else "scarf"
			outfit.weapon = "none"
			outfit.offhand = "none"
			var avatar := preload("res://src/modular_character.gd").new()
			tile.add_child(avatar)
			avatar.configure(race,outfit)
			avatar.play_motion(&"stand")
			if view == "left": avatar.set_facing(&"left")
			if view == "run":
				avatar.play_motion(&"run")
				avatar._active_tween.custom_step(.17)
				avatar._active_tween.pause()
			if view == "rear": avatar._set_back_view(true)
			avatar.scale = Vector2.ONE*1.6
			avatar.position += Vector2(200,170)-avatar._bones.head.global_position
			avatar.set_process(false)
			var title := Label.new()
			title.text = CharacterCatalog.race(race).name
			title.position = Vector2(10,8)
			tile.add_child(title)
			var output := TextureRect.new()
			output.texture = tile.get_texture()
			output.position = Vector2(index%4,index/4)*Vector2(400,320)
			viewport.add_child(output)
		for frame in 20: await process_frame
		RenderingServer.force_draw(false)
		RenderingServer.force_draw(false)
		assert(viewport.get_texture().get_image().save_png("res://artifacts/neck_fit_%s.png"%view) == OK)
		viewport.free()
		for tile in tiles: tile.free()
		print("Rendered neck fit: ",view)
	quit()
