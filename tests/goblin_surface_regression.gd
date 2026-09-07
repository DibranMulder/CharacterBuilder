extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var avatar := ModularCharacter.new()
	root.add_child(avatar)
	avatar.configure("goblin", CharacterCatalog.reference_loadout("goblin"))
	var appearance: GoblinAppearance = avatar.get_node("GoblinAppearance")
	assert(BaseAnatomyVisual.HEAD_TEXTURES.goblin.resource_path == GoblinPaintedAtlas.BASE)
	assert(appearance.vest.visible and not avatar._gear.armor.visible)
	assert(avatar._profile.torso.x >= 70 and avatar._profile.limb_width >= 24)
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
			assert(appearance.vest.back_view == appearance.body.back_view)
		avatar.play_motion(&"stand")
		for item in CharacterCatalog.items_for(&"armor"):
			avatar.equip(&"armor", item)
			assert(appearance.vest.visible == (item == "leather"))
			assert(avatar._gear.armor.visible == (item != "leather"))
		for item in CharacterCatalog.items_for(&"pants"):
			avatar.equip(&"pants", item)
			var expected := GoblinPaintedAtlas.texture("leather_leg" if item == "leather" else "leg")
			assert(appearance.limbs.left_leg.paint_texture == expected)
			for i in range(1, avatar._pants_parts.size()):
				assert(not avatar._pants_parts[i].visible)
		for item in CharacterCatalog.items_for(&"boots"):
			avatar.equip(&"boots", item)
			assert(avatar._left_foot_base.visible == (item == "none"))
			assert((avatar._boot_parts[0].appearance_texture != null) == (item == "leather"))
		for slot in [&"accessory", &"back"]:
			for item in CharacterCatalog.items_for(slot):
				avatar.equip(slot, item)
				assert((avatar._gear[slot].appearance_texture != null) == (item in ["goggles", "pack"]))
		for gesture in 3:
			avatar.play_gesture(gesture)
			avatar._active_tween.custom_step(.3)
			avatar.play_motion(&"stand")
			assert(not appearance.vest.back_view)
	avatar.equip(&"weapon", "sword")
	assert(avatar.has_node("GoblinAppearance"))
	avatar.equip(&"weapon", "crossbow")
	assert(avatar.has_node("GoblinAppearance"))
	avatar.free()
	print("PASS: Goblin coordinated surfaces, both facings, all motions, clothing swaps and weapon rebuilds")
	quit()
