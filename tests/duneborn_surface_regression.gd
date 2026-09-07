extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var avatar := ModularCharacter.new()
	root.add_child(avatar)
	avatar.configure("duneborn", CharacterCatalog.reference_loadout("duneborn"))
	var appearance: DunebornAppearance = avatar.get_node("DunebornAppearance")
	assert(BaseAnatomyVisual.HEAD_TEXTURES.duneborn.resource_path == DunebornPaintedAtlas.BASE)
	assert(appearance.robe.visible and not avatar._gear.armor.visible)
	assert(avatar._profile.torso.x >= 90 and avatar._profile.limb_width >= 26)
	assert(not avatar._bones.torso.get_child(0).visible)
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
			assert(appearance.robe.back_view == appearance.body.back_view)
		avatar.play_motion(&"stand")
		for item in CharacterCatalog.items_for(&"armor"):
			avatar.equip(&"armor", item)
			assert(appearance.robe.visible == (item == "lamellar"))
			assert(avatar._gear.armor.visible == (item != "lamellar"))
		for item in CharacterCatalog.items_for(&"pants"):
			avatar.equip(&"pants", item)
			var expected := DunebornPaintedAtlas.texture("cloth_leg" if item == "cloth" else "leg")
			assert(appearance.limbs.left_leg.paint_texture == expected)
			for i in range(1, avatar._pants_parts.size()):
				assert(not avatar._pants_parts[i].visible)
		for item in CharacterCatalog.items_for(&"boots"):
			avatar.equip(&"boots", item)
			assert(avatar._left_foot_base.visible == (item == "none"))
		for head_item in CharacterCatalog.items_for(&"head"):
			avatar.equip(&"head", head_item)
			assert(avatar._head_base.visible == (head_item != "balaclava"))
			assert((avatar._gear.head.appearance_texture != null) == (head_item == "balaclava"))
		avatar.equip(&"head", "balaclava")
		avatar.play_motion(&"climb")
		assert(avatar._gear.head.appearance_texture == DunebornPaintedAtlas.texture("mask_back"))
		avatar.equip(&"head", "none")
		assert(avatar._head_base.visible and avatar._head_base.back_view)
		avatar.play_motion(&"stand")
		for gesture in 3:
			avatar.play_gesture(gesture)
			avatar._active_tween.custom_step(.3)
			avatar.play_motion(&"stand")
			assert(not appearance.robe.back_view)
	avatar.equip(&"weapon", "crossbow")
	assert(avatar.has_node("DunebornAppearance"))
	avatar.equip(&"weapon", "axe")
	assert(avatar.has_node("DunebornAppearance"))
	avatar.configure("duneborn", CharacterCatalog.reference_loadout("duneborn"))
	assert(not avatar._head_base.visible)
	avatar.equip(&"weapon", "crossbow")
	assert(not avatar._head_base.visible)
	avatar.equip(&"head", "none")
	assert(avatar._head_base.visible)
	avatar.free()
	print("PASS: Duneborn coordinated surfaces, both facings, all motions, clothing swaps and weapon rebuilds")
	quit()
