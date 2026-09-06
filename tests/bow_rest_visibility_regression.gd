extends SceneTree

const Avatar := preload("res://src/modular_character.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	for race_id in ["goblin","centaur"]:
		var avatar := Avatar.new()
		root.add_child(avatar)
		avatar.configure(race_id,{"weapon":"bow","offhand":"none"})
		await process_frame
		var bow: GearVisual = avatar._gear.weapon
		bow.force_update_transform()
		var torso: Node2D = avatar._bones.torso
		var torso_center_x := torso.to_global(Vector2(0,-float(avatar._profile.torso.y)*.5)).x
		var torso_half_width := float(avatar._profile.torso.x)*absf(avatar._bones.rig.scale.x)*.5
		var torso_left := torso_center_x-torso_half_width
		var torso_right := torso_center_x+torso_half_width
		var bow_image := GearVisual.STORYBOOK_BOW.get_image()
		var painted_pixels := 0
		var clear_pixels := 0
		for y in bow_image.get_height():
			for x in bow_image.get_width():
				if bow_image.get_pixel(x,y).a <= .1:
					continue
				painted_pixels += 1
				var world_pixel := bow.to_global(Vector2(-40+x+.5,-44+y+.5))
				if world_pixel.x < torso_left-2.0 or world_pixel.x > torso_right+2.0:
					clear_pixels += 1
		var visible_fraction := float(clear_pixels)/float(painted_pixels)
		if visible_fraction < .42:
			failures.append("%s equipped bow is hidden across the torso at rest: only %d/%d painted pixels (%.1f%%) clear it" % [race_id,clear_pixels,painted_pixels,visible_fraction*100.0])
		avatar.free()
	if not failures.is_empty():
		push_error("; ".join(failures))
		quit(1)
		return
	print("PASS: compact and centaur bows visibly clear the torso at rest")
	quit()
