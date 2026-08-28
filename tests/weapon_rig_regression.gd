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
	right_arm.force_update_transform(); left_arm.force_update_transform(); torso.force_update_transform()

	if weapon.global_position.x <= avatar.global_position.x:
		_fail("weapon must render on the screen-right hand")
	if shield.global_position.x <= avatar.global_position.x:
		_fail("cross-body shield must render on the same screen-right side as the weapon")
	var shield_center := shield.to_global(Vector2(0,-20))
	var maximum_shield_offset: float = profile.torso.x * profile.scale
	if absf(shield_center.x - torso.global_position.x) > maximum_shield_offset:
		_fail("shield face must overlap the torso silhouette instead of floating away from the body")
	if shield.z_index >= 0:
		_fail("shield must remain behind the far-side forearm and torso")
	if shoulder_position.distance_to(sword_tip) <= shoulder_position.distance_to(hand_position):
		_fail("sword tip must extend beyond the hand from the shoulder pivot")
	var rest_weapon_angle := rad_to_deg(rest_weapon_vector.angle())
	if absf(rest_weapon_angle - 35.0) > 1.0 or rest_weapon_vector.x <= 0 or rest_weapon_vector.y <= 0:
		_fail("resting sword must angle down toward screen-right alongside the body")
	var interior_elbow_angle := 180.0 - absf(right_forearm.rotation_degrees)
	if absf(interior_elbow_angle - 120.0) > 1.0:
		_fail("resting elbow must have an approximately 120-degree interior angle")

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
	var forehand_strike: Dictionary = forehand.back()
	right_arm.rotation_degrees = forehand_strike.upper
	right_forearm.rotation_degrees = forehand_strike.forearm
	weapon.force_update_transform()
	var strike_hand := weapon.global_position
	var strike_tip := weapon.to_global(weapon.reach_endpoint())
	if windup_tip.distance_to(strike_tip) <= windup_hand.distance_to(strike_hand) * 1.5:
		_fail("sword tip must sweep a substantially wider attack arc than the hand")

	if failed:
		quit(1)
		return
	print("PASS: handedness and outward weapon reach")
	quit()


func _fail(message: String) -> void:
	failed = true
	printerr("FAIL: ", message)
