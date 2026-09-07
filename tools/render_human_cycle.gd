extends "res://tools/render_human_ranger_showcase.gd"


func _render() -> void:
	var motion := "run"
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--motion="):
			motion = argument.trim_prefix("--motion=")
	if motion not in ["idle", "stand", "run", "stairs", "climb", "jump", "jab", "forehand", "backhand", "fire_bow", "fire_crossbow", "cast_spell", "vault", "gesture0", "gesture1", "gesture2"]:
		push_error("Unsupported cycle: " + motion)
		quit(1)
		return
	var duration: float = {"run":.68, "stairs":.88, "climb":.56, "jump":1.0, "cast_spell":2.0}.get(motion, 1.4)
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1600, 1140)
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Node2D.new()
	viewport.add_child(canvas)
	_add_rect(canvas, Rect2(0,0,1600,1140), Color("101a2b"), -100)
	for index in 12:
		var time := duration * float(index) / 11.0
		var sample := {"title":"%s / %.2fs" % [motion.to_upper(), time], "mode":StringName(motion), "time":time}
		var weapon: String = {"fire_bow":"bow", "fire_crossbow":"crossbow", "cast_spell":"staff"}.get(motion, "sword")
		sample.loadout = {"weapon":weapon}
		if "--shield" in OS.get_cmdline_user_args():
			sample.loadout.offhand = "shield"
		if motion == "vault":
			sample.gesture = 2
		if motion.begins_with("gesture"):
			sample.gesture = int(motion.trim_prefix("gesture"))
			sample.loadout.weapon = "bow"
		_add_sample(canvas, Vector2(index % 4,index / 4) * TILE_SIZE, sample, index)
	for frame in 6:
		await process_frame
	var suffix := "_bare" if "--bare" in OS.get_cmdline_user_args() else ""
	if "--left" in OS.get_cmdline_user_args():
		suffix += "_left"
	if "--shield" in OS.get_cmdline_user_args():
		suffix += "_shield"
	var lineage := "centaur" if "--centaur" in OS.get_cmdline_user_args() else "human"
	var output := "res://artifacts/%s_%s_cycle%s.png" % [lineage,motion,suffix]
	if viewport.get_texture().get_image().save_png(output) != OK:
		quit(1)
		return
	print("PASS: rendered full %s %s cycle to %s" % [lineage,motion,output])
	quit()
