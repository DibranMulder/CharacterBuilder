extends SceneTree
## Visual audit of the compact HUD across all eight character designs.
func _initialize() -> void:
	_capture.call_deferred()

func _capture() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280,330)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var background := ColorRect.new()
	background.size = Vector2(1280,330)
	background.color = Color("101b2c")
	viewport.add_child(background)
	var index := 0
	for lineage in CharacterCatalog.race_ids():
		var hud = load("res://prototypes/training_clearing/resource_hud.gd").new()
		hud.model = load("res://prototypes/training_clearing/encounter.gd").new()
		hud.model.health = 72
		hud.model.mana = 55
		hud.model.xp = 40
		hud.player_name = CharacterCatalog.race(lineage).name
		hud.position = Vector2(index%4*320,index/4*165)
		viewport.add_child(hud)
		hud.set_character(lineage,CharacterCatalog.reference_loadout(lineage))
		index += 1
	for frame in 6:
		await process_frame
	var result := viewport.get_texture().get_image().save_png("res://artifacts/hero_hud_lineages.png")
	quit(0 if result == OK else 1)
