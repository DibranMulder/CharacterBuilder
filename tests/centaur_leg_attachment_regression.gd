extends SceneTree


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var avatar := ModularCharacter.new()
	root.add_child(avatar)
	avatar.configure("centaur", CharacterCatalog.reference_loadout("centaur"))
	var surface: CentaurEquineSurface = avatar._bones.hip.get_node("CentaurEquineSurface")
	assert(surface.near_layer.texture == surface.far_layer.texture)
	assert(surface.near_layer.z_index > surface.far_layer.z_index)
	assert(surface.near_mesh.get_surface_count() == 1, "Body and near legs must be one mesh surface")
	assert(not avatar._horse_body_visual.visible)
	for i in 4:
		var upper: Node2D = avatar._bones["horse_leg_%d" % i]
		var lower: Node2D = avatar._bones["horse_shin_%d" % i]
		assert(not upper.has_node("CentaurLimbSurface"), "Separate horse leg paintings must be removed")
		assert(not upper.get_child(0).visible and not lower.get_child(0).visible)
		assert(not lower.get_node("HoofSprite%d" % i).visible, "Hooves belong to the continuous texture")
	# The indexed grid reuses vertices across every row, including leg roots.
	var referenced := {}
	for index in surface.near_indices:
		referenced[index] = true
	assert(referenced.size() == surface.rest_vertices.size())
	assert(surface.near_indices.size() == CentaurEquineSurface.ROWS * CentaurEquineSurface.COLUMNS * 6)
	for point in surface.rest_vertices:
		assert(surface.deform_point(point).distance_to(point) < .001, "Rest mesh must reproduce the painting without distortion")
	for facing in [&"right", &"left"]:
		avatar.set_facing(facing)
		for action in [&"stand", &"run", &"stairs", &"jump", &"rear"]:
			avatar.play_motion(&"stand")
			if action == &"rear":
				avatar.play_gesture(1)
			else:
				avatar.play_motion(action)
			for sample in 24:
				_check_surface(avatar, surface)
				if avatar._active_tween:
					avatar._active_tween.custom_step(1.0 / 24.0)
		avatar.play_motion(&"climb")
		assert(not surface.visible and avatar._horse_body_visual.visible)
		avatar.play_motion(&"stand")
		assert(surface.visible and not avatar._horse_body_visual.visible)
	avatar.free()
	print("PASS: continuous equine mesh, shared topology, four skinned hooves, both facings and rear switching")
	quit()


func _check_surface(avatar: ModularCharacter, surface: CentaurEquineSurface) -> void:
	for far_side in [false, true]:
		for vertex in surface.deformed_vertices(far_side):
			assert(vertex.is_finite())
		for near_index in [1, 3]:
			var index: int = near_index - 1 if far_side else near_index
			var bind_root := CentaurEquineSurface.leg_root(near_index)
			var bind_ankle := bind_root + Vector2(0, avatar._profile.leg)
			var actual := surface.to_global(surface.deform_point(bind_ankle, far_side))
			var lower: Node2D = avatar._bones["horse_shin_%d" % index]
			assert(actual.distance_to(lower.to_global(Vector2(0, avatar._profile.leg * .48))) < .001,
				"Painted hooves must track their animation bones")
	assert(surface.deform_point(Vector2.ZERO).is_equal_approx(Vector2.ZERO), "Upper barrel must remain hip-bound")
