extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var avatar := ModularCharacter.new()
	root.add_child(avatar)
	avatar.configure("fae", CharacterCatalog.reference_loadout("fae"))
	var appearance: FaeAppearance = avatar.get_node("FaeAppearance")
	assert(avatar._head_base.get_node("Sprite").has_node("Ponytail"))
	assert(BaseAnatomyVisual.HEAD_TEXTURES.fae.resource_path == FaePaintedAtlas.BASE)
	assert(appearance.tunic.visible and not avatar._gear.armor.visible)
	assert(avatar._bones.left_leg.z_index > avatar._bones.right_leg.z_index)
	for side in ["left", "right"]:
		assert(avatar._bones[side + "_wing"].has_node("ReferenceWing"))
	for facing in [&"right", &"left"]:
		avatar.set_facing(facing)
		for motion in ModularCharacter.MOTIONS:
			avatar.play_motion(motion)
			for sample in 24:
				for key in appearance.limbs:
					var limb: HumanLimbSurface = appearance.limbs[key]
					var points := limb.centerline()
					assert(limb.to_global(points[-1]).distance_to(limb.lower.to_global(Vector2(0, limb.length))) < .001)
					for point in points:
						assert(point.is_finite())
				if avatar._active_tween:
					avatar._active_tween.custom_step(1.0 / 24.0)
			assert(appearance.body.back_view == (motion == &"climb"))
			assert(appearance.tunic.back_view == appearance.body.back_view)
		avatar.play_motion(&"stand")
		for item in CharacterCatalog.items_for(&"armor"):
			avatar.equip(&"armor", item)
			assert(appearance.tunic.visible == (item == "fae_tunic"))
			assert(avatar._gear.armor.visible == (item != "fae_tunic"))
		for item in CharacterCatalog.items_for(&"pants"):
			avatar.equip(&"pants", item)
			var expected := FaePaintedAtlas.texture("baggy_leg" if item == "baggy" else "leg")
			assert(appearance.limbs.left_leg.paint_texture == expected)
			assert(appearance.limbs.right_leg.paint_texture == expected)
			for i in range(1, avatar._pants_parts.size()):
				assert(not avatar._pants_parts[i].visible, "Detached pants segments must stay hidden")
		for item in CharacterCatalog.items_for(&"boots"):
			avatar.equip(&"boots", item)
			assert(avatar._left_foot_base.visible == (item in ["none", "wraps"]))
			assert(avatar._right_foot_base.part_id == ("foot_wraps" if item == "wraps" else "foot"))
		for gesture in 3:
			avatar.play_gesture(gesture)
			avatar._active_tween.custom_step(.3)
			avatar.play_motion(&"stand")
			assert(not appearance.tunic.back_view)
	# Crossbow changes rebuild the rig: the appearance adapter must be fresh.
	avatar.equip(&"weapon", "crossbow")
	assert(avatar.has_node("FaeAppearance"))
	avatar.equip(&"weapon", "branch_staff")
	assert(avatar.has_node("FaeAppearance"))
	avatar.free()
	print("PASS: Fae coordinated artwork, continuous limbs, both facings, rear view, all clothing swaps and rebuilds")
	quit()
