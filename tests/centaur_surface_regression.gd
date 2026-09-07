extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _advance(avatar: ModularCharacter, seconds: float) -> void:
	for step in int(round(seconds * 240)):
		if avatar._active_tween:
			avatar._active_tween.custom_step(1.0 / 240.0)


func _run() -> void:
	var avatar := ModularCharacter.new()
	root.add_child(avatar)
	avatar.configure("centaur", CharacterCatalog.reference_loadout("centaur"))
	var head_sprite: Sprite2D = avatar._head_base.get_node("Sprite")
	assert(head_sprite.has_node("LongHair"), "Reference centaur must retain its waist-length hair")
	assert(head_sprite.get_node("LongHair").z_index < 0, "Profile hair must pass behind the chest")
	assert(CentaurPaintedAtlas.UPPER == BaseAnatomyVisual.HEAD_TEXTURES.centaur.resource_path,
		"Face, bare torso and arms must share the coordinated reference artwork")
	assert(avatar._profile.leg_width >= 38, "Reference legs must retain their sturdy silhouette")
	assert(avatar._gear.armor.scale.y == 1.25, "Harness must reach the centaur waist")
	for facing in [&"right", &"left"]:
		avatar.set_facing(facing)
		avatar.play_motion(&"stand")
		var lower: Node2D = avatar._bones.horse_shin_1
		var hoof := lower.to_global(Vector2(0, float(avatar._profile.leg) * .48))
		avatar.play_gesture(1)
		_advance(avatar, .41)
		if avatar._bones.hip.rotation_degrees > -20:
			push_error("Rearing Strike must pitch the horse body up, not hop vertically")
			quit(1)
			return
		if hoof.distance_to(lower.to_global(Vector2(0, float(avatar._profile.leg) * .48))) > .5:
			push_error("Rearing Strike must keep the supporting hind hoof planted")
			quit(1)
			return
		_advance(avatar, .5)
		assert(avatar._bones.hip.position.is_equal_approx(avatar._rest.hip.position))
		assert(is_zero_approx(avatar._bones.hip.rotation))
		for motion in ModularCharacter.MOTIONS:
			avatar.play_motion(motion)
			for sample in 60:
				_advance(avatar, 1.0 / 60.0)
				for root_name in ["left_arm", "right_arm"]:
					var surface: HumanLimbSurface = avatar._bones[root_name].get_node("CentaurLimbSurface")
					var points := surface.centerline()
					assert(surface.to_global(points[-1]).distance_to(surface.lower.to_global(Vector2(0, surface.length))) < .001)
					for point in points:
						assert(point.is_finite())
		avatar.play_motion(&"stand")
		for pair in [[0, 1], [2, 3]]:
			assert(avatar._bones["horse_leg_%d" % pair[0]].z_index < avatar._bones["horse_leg_%d" % pair[1]].z_index)
		assert(not avatar._horse_neck_visual.visible, "Old separate neck must not reappear")
		for action in ["jab", "forehand", "backhand", "fire_bow", "fire_crossbow", "cast_spell", "gesture0", "gesture1", "gesture2"]:
			avatar.equip(&"weapon", {"fire_bow":"bow", "fire_crossbow":"crossbow", "cast_spell":"staff"}.get(action, "sword"))
			if action.begins_with("gesture"):
				avatar.play_gesture(int(action.trim_prefix("gesture")))
			else:
				avatar.play_weapon_attack(StringName(action))
			_advance(avatar, .35)
			avatar._process(0.0)
			for bone_name in avatar._bones:
				assert(avatar._bones[bone_name].global_transform.is_finite(), "Action transforms must stay finite")
			avatar.play_motion(&"stand")
			assert(avatar._bones.hip.position.is_equal_approx(avatar._rest.hip.position), "Action interruption must restore the hip")
			assert(is_zero_approx(avatar._bones.hip.rotation), "Action interruption must clear rearing pitch")
			for i in 4:
				assert(avatar._bones["horse_leg_%d" % i].visible)
	avatar.free()
	print("PASS: centaur continuous surfaces, paired depth, grounded rear and all motion endpoints in both facings")
	quit()
