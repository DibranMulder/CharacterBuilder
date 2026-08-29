extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
var failed := false


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var avatar := Avatar.new()
	root.add_child(avatar)
	avatar.configure("bogkin", {
		"weapon": "sword",
		"offhand": "shield",
	})
	await process_frame
	var profile := CharacterCatalog.race("bogkin")

	var right_arm: Node2D = avatar.get_node("Rig/Hip/torso/right_arm")
	var right_forearm: Node2D = right_arm.get_node("right_forearm")
	var left_arm: Node2D = avatar.get_node("Rig/Hip/torso/left_arm")
	var left_forearm: Node2D = left_arm.get_node("left_forearm")
	var torso: Node2D = avatar.get_node("Rig/Hip/torso")
	var weapon: GearVisual = right_forearm.get_node("Weapon")
	var shield: GearVisual = left_forearm.get_node("Offhand")
	var hand_position := weapon.global_position
	var sword_tip := weapon.to_global(weapon.reach_endpoint())
	var shoulder_position := right_arm.global_position
	var rest_weapon_vector := sword_tip - hand_position
	var forearm_vector := hand_position-right_forearm.global_position

	if right_arm.global_position.x >= torso.global_position.x:
		_fail("right-facing anatomical right shoulder must be drawn on screen-left")
	if left_arm.global_position.x <= torso.global_position.x:
		_fail("right-facing anatomical left shoulder must be drawn on screen-right")
	avatar.set_facing(&"left")
	right_arm.force_update_transform(); left_arm.force_update_transform(); torso.force_update_transform()
	if right_arm.global_position.x <= torso.global_position.x:
		_fail("left-facing anatomical right shoulder must be drawn on screen-right")
	if left_arm.global_position.x >= torso.global_position.x:
		_fail("left-facing anatomical left shoulder must be drawn on screen-left")
	avatar.set_facing(&"right")
	right_arm.force_update_transform(); right_forearm.force_update_transform()
	left_arm.force_update_transform(); torso.force_update_transform()

	if right_forearm.global_position.x >= right_arm.global_position.x:
		_fail("idle weapon elbow must project outward from the anatomical right shoulder")

	if sword_tip.x <= avatar.global_position.x:
		_fail("resting weapon must extend toward screen-right")
	if shield.global_position.x <= avatar.global_position.x:
		_fail("cross-body shield must render on the same screen-right side as the weapon")
	var shield_center := shield.to_global(Vector2(0,-20))
	var offhand_socket := left_forearm.to_global(Vector2(0,float(profile.arm)*.48))
	if shield_center.distance_to(offhand_socket) > .5:
		_fail("idle shield grip must sit at the center of the shield")
	var torso_part: PartVisual = torso.get_child(0)
	var minimum_idle_shield_y: float = torso_part.to_global(Vector2(0,float(profile.torso.y)*.38)).y
	if shield_center.y < minimum_idle_shield_y:
		_fail("idle shield guard must sit lower on the torso")
	var maximum_shield_offset: float = profile.torso.x * profile.scale
	if absf(shield_center.x - torso.global_position.x) > maximum_shield_offset:
		_fail("shield face must overlap the torso silhouette instead of floating away from the body")
	if shield.z_index >= 0:
		_fail("shield must remain behind the far-side forearm and torso")
	if shoulder_position.distance_to(sword_tip) <= shoulder_position.distance_to(hand_position):
		_fail("sword tip must extend beyond the hand from the shoulder pivot")
	var rest_weapon_angle := rad_to_deg(rest_weapon_vector.angle())
	if absf(rest_weapon_angle) > 1.0 or rest_weapon_vector.x <= 0:
		_fail("resting sword must be horizontal and point toward screen-right")
	if absf(forearm_vector.normalized().dot(rest_weapon_vector.normalized())) > .02:
		_fail("resting sword must be perpendicular to the forearm at the grip")
	var interior_elbow_angle := 180.0 - absf(right_forearm.rotation_degrees)
	if absf(right_arm.rotation_degrees - 15.0) > 1.0:
		_fail("resting upper weapon arm must hang almost vertically")
	if absf(interior_elbow_angle - 165.0) > 1.0:
		_fail("resting elbow must retain a slight outward bend")
	for weapon_id in ["axe","spear","staff"]:
		avatar.equip(&"weapon",weapon_id)
		weapon.force_update_transform()
		var weapon_axis := weapon.to_global(Vector2(0,80))-weapon.global_position
		var alignment := absf(forearm_vector.normalized().dot(weapon_axis.normalized()))
		if weapon_id == "axe" and (absf(weapon_axis.y) > 1.0 or alignment > .02):
			_fail("resting axe must be horizontal and perpendicular to the forearm")
		if weapon_id in ["spear","staff"] and (absf(weapon_axis.x) > 1.0 or alignment < .98):
			_fail("resting %s must be vertical" % weapon_id)
		if weapon_id in ["spear","staff"]:
			var pole_butt := weapon.to_global(GearVisual.POLE_BUTT)
			var left_knee_y: float = avatar._bones.left_shin.global_position.y
			var right_knee_y: float = avatar._bones.right_shin.global_position.y
			if pole_butt.y <= maxf(left_knee_y,right_knee_y):
				_fail("resting %s shaft must extend below both knees" % weapon_id)
	avatar.equip(&"weapon","bow")
	weapon.force_update_transform()
	if weapon.get_parent() != left_forearm:
		_fail("bow must be wielded by the anatomical left hand")
	var bow_effective_z: int = weapon.z_index+left_forearm.z_index+left_arm.z_index
	var armor_effective_z: int = avatar._gear.armor.z_index+torso.z_index
	if bow_effective_z <= armor_effective_z:
		_fail("wielded bow must render in front of the character armor")
	var bow_hand_effective_z: int = avatar._left_hand_base.z_index+left_forearm.z_index+left_arm.z_index
	if bow_hand_effective_z <= bow_effective_z:
		_fail("bow gripping hand must remain visible in front of the bow")
	var bow_top := weapon.to_global(GearVisual.BOW_TOP)
	var bow_bottom := weapon.to_global(GearVisual.BOW_BOTTOM)
	var right_string_center := (bow_top+bow_bottom)*.5
	if right_string_center.distance_to(weapon.global_position) < 30.0:
		_fail("bow hand must grip the wooden curve rather than the string midpoint")
	if right_string_center.x >= weapon.global_position.x:
		_fail("right-facing bowstring must sit behind the wooden grip toward the archer")
	avatar.set_facing(&"left")
	weapon.force_update_transform()
	var left_string_center := (weapon.to_global(GearVisual.BOW_TOP)+weapon.to_global(GearVisual.BOW_BOTTOM))*.5
	if left_string_center.x <= weapon.global_position.x:
		_fail("left-facing bowstring must mirror behind the wooden grip toward the archer")
	avatar.set_facing(&"right")
	avatar.equip(&"weapon","sword")
	avatar.equip(&"offhand","shield")
	avatar.equip(&"weapon","bow")
	if avatar.loadout.offhand != "none" or shield.visible:
		_fail("equipping a bow must remove an equipped shield")
	if avatar.equip(&"offhand","shield"):
		_fail("shield must be rejected while a bow is equipped")
	avatar.equip(&"weapon","sword")

	# Sample the same windup/strike angles used by the sword attack. A properly
	# gripped weapon tip must describe a larger arc than the hand carrying it.
	var forehand: Array = Avatar.ATTACK_CURVES.forehand
	right_arm.rotation_degrees = forehand[0].upper
	right_forearm.rotation_degrees = forehand[0].forearm
	weapon.force_update_transform()
	var windup_hand := weapon.global_position
	var windup_tip := weapon.to_global(weapon.reach_endpoint())
	var head: Node2D = avatar.get_node("Rig/Hip/torso/head")
	var face_left_x: float = head.global_position.x - profile.head.x * 0.5 * profile.scale
	if windup_tip.x >= face_left_x:
		_fail("forehand reach-back must carry the weapon beyond the screen-left side of the face")
	var hand_path := 0.0
	var tip_path := 0.0
	var previous_hand := windup_hand
	var previous_tip := windup_tip
	for pose in forehand.slice(1):
		right_arm.rotation_degrees = pose.upper
		right_forearm.rotation_degrees = pose.forearm
		weapon.force_update_transform()
		var next_hand := weapon.global_position
		var next_tip := weapon.to_global(weapon.reach_endpoint())
		hand_path += previous_hand.distance_to(next_hand)
		tip_path += previous_tip.distance_to(next_tip)
		previous_hand = next_hand
		previous_tip = next_tip
	if tip_path <= hand_path * 1.35:
		_fail("sword tip must sweep a substantially wider full slash arc than the hand")

	var troll := Avatar.new()
	root.add_child(troll)
	troll.configure("frost_troll",{"weapon":"axe","offhand":"shield"})
	await process_frame
	if troll.loadout.offhand != "none" or troll.supports_equipment_slot(&"offhand"):
		_fail("Frost Troll's two-handed axe must occupy the offhand slot")
	var troll_axe: GearVisual = troll._gear.weapon
	if not troll_axe.two_handed:
		_fail("Frost Troll axe did not switch to its long double-headed presentation")
	if troll_axe.reach_endpoint().length() < 165.0:
		_fail("Frost Troll's two-handed axe must retain its oversized great-axe silhouette")
	if troll._left_hand_base.part_id != "hand_grip":
		_fail("Frost Troll's second axe hand must use the gripping sprite")
	troll.call("_update_two_handed_axe_grip")
	_assert_weapon_elbow_outward(troll,&"right")
	_assert_two_handed_elbow(troll,"idle")
	var second_hand_socket: Vector2 = troll._bones.left_forearm.to_global(Vector2(0,float(troll._profile.arm)*.48))
	var second_grip: Vector2 = troll_axe.to_global(GearVisual.TWO_HANDED_AXE_SECOND_GRIP)
	if second_hand_socket.distance_to(second_grip) > 1.0:
		_fail("Frost Troll's second hand does not meet the axe shaft at idle")
	troll.set_facing(&"left")
	troll.call("_update_two_handed_axe_grip")
	_assert_weapon_elbow_outward(troll,&"left")
	troll.set_facing(&"right")
	troll.call("_update_two_handed_axe_grip")
	troll.play_motion(&"run")
	troll._active_tween.custom_step(.18)
	troll.call("_update_two_handed_axe_grip")
	_assert_two_handed_elbow(troll,"run")
	second_hand_socket = troll._bones.left_forearm.to_global(Vector2(0,float(troll._profile.arm)*.48))
	second_grip = troll_axe.to_global(GearVisual.TWO_HANDED_AXE_SECOND_GRIP)
	if second_hand_socket.distance_to(second_grip) > 1.0:
		_fail("Frost Troll's second hand detached from the axe while running")
	troll.stop_motion()
	troll.play_weapon_attack(&"forehand")
	troll._active_tween.custom_step(.27)
	troll.call("_update_two_handed_axe_grip")
	_assert_two_handed_elbow(troll,"forehand")
	second_hand_socket = troll._bones.left_forearm.to_global(Vector2(0,float(troll._profile.arm)*.48))
	second_grip = troll_axe.to_global(GearVisual.TWO_HANDED_AXE_SECOND_GRIP)
	if second_hand_socket.distance_to(second_grip) > 1.0:
		_fail("Frost Troll's second hand detached during an axe attack")

	if failed:
		quit(1)
		return
	print("PASS: handedness and outward weapon reach")
	quit()


func _fail(message: String) -> void:
	failed = true
	printerr("FAIL: ", message)


func _assert_two_handed_elbow(troll: ModularCharacter, phase: String) -> void:
	var bend: float = troll._bones.left_forearm.rotation_degrees
	if bend >= -10.0:
		_fail("Frost Troll support elbow must use the outward bend branch during %s (was %.1f degrees)" % [phase,bend])
	if bend < -165.0:
		_fail("Frost Troll support elbow must not overfold during %s (was %.1f degrees)" % [phase,bend])


func _assert_weapon_elbow_outward(troll: ModularCharacter, direction: StringName) -> void:
	var shoulder_x: float = troll._bones.right_arm.global_position.x
	var elbow_x: float = troll._bones.right_forearm.global_position.x
	var points_outward := elbow_x < shoulder_x if direction == &"right" else elbow_x > shoulder_x
	if not points_outward:
		_fail("Frost Troll anatomical-right elbow must project outward while facing %s (shoulder %.1f, elbow %.1f)" % [direction,shoulder_x,elbow_x])
