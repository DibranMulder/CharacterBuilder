extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const Cloth := preload("res://src/cloth_surface.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	for part in ["torso", "torso_back", "arm", "leg", "hand_open", "hand_grip", "hand_grip_back", "foot"]:
		var paint := HumanPaintedAtlas.texture(part)
		assert(paint.atlas != null, "Every human body part needs painted artwork")
		assert(Rect2(Vector2.ZERO, paint.atlas.get_size()).encloses(paint.region), "Painted crops must remain inside the source atlas")
		assert(paint == HumanPaintedAtlas.texture(part), "Painted crops should be shared between characters")
	for bend in [-.35, 0.0, .35]:
		var clasp := Vector2(-20, 5)
		var hem := Vector2(-70, 130)
		assert(Cloth.deform(clasp, Vector2(.5, .1), bend).rotated(bend).is_equal_approx(clasp), "Cloth clasp must remain pinned as the free end sways")
		assert(Cloth.deform(hem, Vector2(.5, 1), bend).rotated(bend).is_equal_approx(hem.rotated(bend)), "Cloth hem must follow the animated bend")
	var avatar := Avatar.new()
	root.add_child(avatar)
	avatar.configure("human", CharacterCatalog.reference_loadout("human"))
	assert(avatar._right_hand_base.has_node("HumanExtremity"))
	assert(avatar._left_foot_base.has_node("HumanExtremity"))
	for part in ["hand_open", "hand_grip", "hand_grip_back"]:
		avatar._right_hand_base.set_part(part)
		assert(avatar._right_hand_base.get_node("HumanExtremity").part == part)
		assert(avatar._right_hand_base.has_sprite())
	assert(avatar._bones.torso.has_node("HumanTorsoSurface"))
	assert(avatar._bones.torso.get_node("HumanTorsoSurface").material == HumanPaintedAtlas.paint_material())
	assert(avatar._right_hand_base.get_node("HumanExtremity").material == HumanPaintedAtlas.paint_material())
	assert(avatar._gear.pants.z_index < avatar._gear.armor.z_index, "Outer garment must cover the trouser waist")
	var garment = avatar._gear.armor.garment_surface
	var opening := Vector2(34, 20)
	var chest := Vector2(0, 20)
	var resting_opening: Vector2 = garment.deform(opening, Vector2(82,90))
	var resting_chest: Vector2 = garment.deform(chest, Vector2(82,90))
	var arm_rotation: float = avatar._bones.left_arm.rotation
	avatar._bones.left_arm.rotation += .6
	assert(garment.deform(opening, Vector2(82,90)).distance_to(resting_opening) > 2.0, "Armhole must respond to shoulder rotation")
	assert(garment.deform(chest, Vector2(82,90)).is_equal_approx(resting_chest), "Shoulder deformation must leave the central chest fixed")
	avatar._bones.left_arm.rotation = arm_rotation
	avatar._set_back_view(true)
	assert(avatar._bones.torso.get_node("HumanTorsoSurface").back_view)
	assert(avatar._gear.back.z_index > avatar._gear.armor.z_index, "Rear cape must cover the torso")
	assert(avatar._gear.pants.back_view, "Rear trousers must omit the front buckle")
	avatar._set_back_view(false)
	assert(not avatar._bones.torso.get_node("HumanTorsoSurface").back_view)
	assert(avatar._gear.back.z_index < avatar._gear.armor.z_index, "Front cape must sit behind the torso")
	for facing in [&"left", &"right"]:
		avatar.set_facing(facing)
		for bend in [-140.0, -90.0, 0.0, 90.0, 140.0]:
			for limb in ["arm", "leg"]:
				for side in ["left", "right"]:
					var upper: Node2D = avatar._bones[side + "_" + limb]
					var lower: Node2D = avatar._bones[side + ("_forearm" if limb == "arm" else "_shin")]
					lower.rotation_degrees = bend
					var surface = upper.get_node("HumanLimbSurface")
					var points: PackedVector2Array = surface.centerline()
					var end: Vector2 = surface.to_global(points[points.size() - 1])
					assert(end.is_equal_approx(lower.to_global(Vector2(0, surface.length))), "Continuous limb must terminate at the original hand/foot socket")
					for point in points:
						assert(point.is_finite(), "Extreme bends must produce finite geometry")
	avatar.equip(&"armor", "none")
	assert(avatar._bones.right_arm.get_node("HumanLimbSurface").armor == "none")
	avatar.equip(&"armor", "plate")
	assert(avatar._bones.left_arm.get_node("HumanLimbSurface").armor == "plate")
	for pants in CharacterCatalog.items_for(&"pants"):
		avatar.equip(&"pants", pants)
		for side in ["left", "right"]:
			assert(avatar._bones[side + "_leg"].get_node("HumanLimbSurface").pants == pants)
		assert(avatar._gear.pants.item == pants, "Waist and continuous trouser legs must swap together")
		assert(avatar._gear.pants.fitted_waist and avatar._gear.pants.material == null, "Human waist must share the leg palette without a second dye pass")
	avatar.equip(&"offhand", "shield")
	assert(avatar._left_hand_base.z_index < avatar._gear.offhand.z_index, "Shield must occlude the gripping palm")
	avatar.play_motion(&"climb")
	assert(avatar._left_hand_base.z_index == 7, "Stowing the shield must release a visible climbing hand")
	assert(avatar._gear.offhand.z_index > avatar._gear.back.z_index, "Stowed shield must remain visible over the rear cape")
	avatar.play_motion(&"stand")
	assert(avatar._left_hand_base.z_index < avatar._gear.offhand.z_index)
	avatar.configure("fae")
	assert(not avatar._bones.right_arm.has_node("HumanLimbSurface"), "Human surfaces must not change other lineages")
	print("PASS: continuous human limb endpoints, bends, facing, armor swaps and lineage isolation")
	quit()
