extends "res://tools/render_human_ranger_showcase.gd"


func _render() -> void:
	var armors := CharacterCatalog.items_for(&"armor").duplicate()
	armors.erase("none")
	var rows := ceili(float(armors.size()) / 3.0)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1200, rows * 380)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Node2D.new()
	viewport.add_child(canvas)
	_add_rect(canvas, Rect2(Vector2.ZERO, Vector2(viewport.size)), Color("101a2b"), -100)
	var rear := "--rear" in OS.get_cmdline_user_args()
	for index in armors.size():
		var armor: String = armors[index]
		var pants := armor if armor in ["cloth", "leather", "plate"] else "ranger"
		_add_sample(canvas, Vector2(index % 3, index / 3) * TILE_SIZE,
			{"title":armor.to_upper(), "mode":&"climb" if rear else &"run", "time":.28 if rear else .36,
			"loadout":{"armor":armor, "pants":pants, "back":"none", "accessory":"none"}}, index)
	for frame in 6:
		await process_frame
	var output := "res://artifacts/human_armor_fit%s.png" % ("_rear" if rear else "")
	if viewport.get_texture().get_image().save_png(output) != OK:
		quit(1)
		return
	print("PASS: rendered all human armor fits to " + output)
	quit()
