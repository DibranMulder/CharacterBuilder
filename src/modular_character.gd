class_name ModularCharacter
extends Node2D

signal equipment_changed(slot: StringName, item_id: String)
signal gesture_started(name: String)
signal motion_changed(motion: StringName)
signal facing_changed(direction: StringName)

const Part := preload("res://src/part_visual.gd")
const Gear := preload("res://src/gear_visual.gd")
const BaseAnatomy := preload("res://src/base_anatomy_visual.gd")

const WEAPON_ATTACKS := [&"jab", &"forehand", &"backhand"]
const MOTIONS := [&"idle", &"run", &"climb"]
const ATTACK_CURVES := {
	"jab": [
		# Retract with a deeply bent elbow while keeping the blade horizontal,
		# then extend the arm along that same line into the thrust.
		{"upper": 70.0, "forearm": -160.0, "torso": 7.0, "x": -13.0, "duration": 0.18},
		{"upper": -60.0, "forearm": -30.0, "torso": -8.0, "x": 22.0, "duration": 0.13},
	],
	"forehand": [
		# Carry a consistently bent elbow behind the head, reach a vertical
		# overhead weapon pose, then smash diagonally down and forward.
		{"upper": -165.0, "forearm": -60.0, "torso": -8.0, "x": -7.0, "duration": 0.20},
		{"upper": -120.0, "forearm": -60.0, "torso": -13.0, "x": -13.0, "duration": 0.15},
		{"upper": -20.0, "forearm": -25.0, "torso": 11.0, "x": 12.0, "duration": 0.18},
	],
	"backhand": [
		{"upper": 45.0, "forearm": -15.0, "torso": 11.0, "x": 7.0, "duration": 0.18},
		{"upper": -120.0, "forearm": 30.0, "torso": -11.0, "x": -5.0, "duration": 0.17},
	],
}

var race_id := "human"
var loadout := {
	"weapon": "sword", "offhand": "shield", "armor": "leather",
	"pants": "cloth", "head": "none", "back": "cape", "accessory": "none",
}
var _profile: Dictionary
var _bones := {}
var _gear := {}
var _active_tween: Tween
var _rest := {}
var _elapsed := 0.0
var _gesturing := false
var current_motion: StringName = &"idle"
var facing: StringName = &"right"
var _head_visual: PartVisual
var _head_base: BaseAnatomyVisual


func _ready() -> void:
	configure(race_id, loadout)


# This is the module's public seam. The builder/gameplay code never touches bones.
func configure(new_race_id: String, new_loadout: Dictionary = {}) -> void:
	race_id = new_race_id if CharacterCatalog.RACES.has(new_race_id) else "human"
	for slot in new_loadout:
		if loadout.has(slot): loadout[slot] = new_loadout[slot]
	_rebuild()


func equip(slot: StringName, item_id: String) -> bool:
	if not slot in CharacterCatalog.SLOT_ORDER or not item_id in CharacterCatalog.items_for(slot):
		return false
	loadout[String(slot)] = item_id
	var visual: GearVisual = _gear.get(String(slot))
	if visual:
		visual.setup(String(slot), item_id, _profile.accent)
		_apply_gear_presentation(String(slot), item_id, visual)
	equipment_changed.emit(slot, item_id)
	return true


func available_gestures() -> Array:
	return _profile.get("gestures", [])


func play_gesture(index: int) -> void:
	var gestures: Array = available_gestures()
	if index < 0 or index >= gestures.size(): return
	var gesture: Dictionary = gestures[index]
	_play_action(gesture.name, gesture.style)


func available_weapon_attacks() -> Array[StringName]:
	return WEAPON_ATTACKS.duplicate()


func available_motions() -> Array[StringName]:
	return MOTIONS.duplicate()


func set_facing(direction: StringName) -> void:
	if direction not in [&"left", &"right"]:
		return
	facing = direction
	_apply_facing()
	if not _gear.is_empty():
		for slot in ["weapon", "offhand"]:
			var visual: GearVisual = _gear.get(slot)
			if visual:
				_apply_gear_presentation(slot, loadout[slot], visual)
	facing_changed.emit(facing)


func play_motion(motion: StringName) -> void:
	if not motion in MOTIONS:
		return
	if motion == &"idle":
		stop_motion()
		return
	_stop_active_animation()
	_restore_pose()
	current_motion = motion
	_gesturing = true
	_set_back_view(motion == &"climb")
	_set_climbing_gear(motion == &"climb")
	_active_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	if motion == &"run":
		_build_run_loop()
	else:
		_build_climb_loop()
	motion_changed.emit(current_motion)


func stop_motion() -> void:
	_stop_active_animation()
	_restore_pose()
	current_motion = &"idle"
	_gesturing = false
	_set_back_view(false)
	_set_climbing_gear(false)
	motion_changed.emit(current_motion)


func play_weapon_attack(attack: StringName = &"forehand") -> void:
	if not attack in WEAPON_ATTACKS:
		return
	_play_action("%s %s" % [String(loadout.weapon).capitalize(), String(attack).capitalize()], String(attack))


func _play_action(action_name: String, style: String) -> void:
	_stop_active_animation()
	_restore_pose()
	current_motion = &"idle"
	_gesturing = true
	_set_back_view(false)
	_set_climbing_gear(false)
	motion_changed.emit(current_motion)
	gesture_started.emit(action_name)
	_active_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	match style:
		"jab": _animate_weapon_curve("jab")
		"forehand": _animate_weapon_curve("forehand")
		"backhand": _animate_weapon_curve("backhand")
		"slash": _animate_slash()
		"thrust": _animate_thrust()
		"cast": _animate_cast()
		"smash": _animate_smash()
		"shoot": _animate_shoot()
		_: _animate_leap()
	_active_tween.tween_callback(_finish_gesture)


func _process(delta: float) -> void:
	_elapsed += delta
	if not _gesturing and _bones.has("rig"):
		_bones.rig.position.y = sin(_elapsed * 3.0) * 2.2


func _part(parent: Node, name_: String, kind: String, size: Vector2, color: Color, position_: Vector2, z := 0) -> PartVisual:
	var pivot := Node2D.new()
	pivot.name = name_
	pivot.position = position_
	pivot.z_index = z
	parent.add_child(pivot)
	var visual := Part.new().setup(kind, size, color, _profile.accent)
	visual.set_style(_profile.get("visual", {}))
	pivot.add_child(visual)
	_bones[name_] = pivot
	return visual


func _base_sprite(parent: Node2D, name_: String, part: String, size: Vector2, position_: Vector2, z: int, rotation_degrees_ := 0.0) -> BaseAnatomyVisual:
	var visual := BaseAnatomy.new().setup(race_id,part,size)
	visual.name = name_
	visual.position = position_
	visual.z_index = z
	visual.rotation_degrees = rotation_degrees_
	parent.add_child(visual)
	return visual


func _rebuild() -> void:
	_stop_active_animation()
	current_motion = &"idle"
	_gesturing = false
	# Detach immediately so rebuilt sockets keep stable names in the same frame.
	# queue_free() alone leaves the old nodes present until frame end.
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_bones.clear(); _gear.clear(); _rest.clear()
	_profile = CharacterCatalog.race(race_id)
	var rig := Node2D.new(); rig.name = "Rig"; add_child(rig); _bones.rig = rig
	var shadow := Part.new().setup("shadow", Vector2(118,24), Color.WHITE, Color.TRANSPARENT)
	shadow.position = Vector2(0, 8); shadow.z_index = -20; add_child(shadow)
	var scale_factor: float = _profile.scale
	rig.scale = Vector2.ONE * scale_factor
	var torso_size: Vector2 = _profile.torso
	var head_size: Vector2 = _profile.head
	var skin: Color = _profile.skin
	var hip_y := -float(_profile.leg)
	var hip := Node2D.new(); hip.name = "Hip"; hip.position = Vector2(0, hip_y); rig.add_child(hip); _bones.hip = hip

	if _profile.topology == "centaur":
		_part(hip, "horse_body", "horse", Vector2(128,62), skin.darkened(.16), Vector2(-12, 18), -1)
		var horse_upper_length := float(_profile.leg) * .52
		var horse_lower_length := float(_profile.leg) - horse_upper_length
		for i in 4:
			var x := -52.0 + i * 34.0
			var upper_name := "horse_leg_%d" % i
			_part(hip, upper_name, "limb", Vector2(15,horse_upper_length), skin.darkened(.12), Vector2(x,38), -2 if i < 2 else 1)
			_part(_bones[upper_name], "horse_shin_%d" % i, "shin", Vector2(14,horse_lower_length), skin.darkened(.08), Vector2(0,horse_upper_length), 0)
			_base_sprite(_bones["horse_shin_%d" % i],"HoofSprite%d" % i,"hoof",Vector2(28,24),Vector2(0,horse_lower_length),3)
	else:
		var thigh_length := float(_profile.leg) * .52
		var shin_length := float(_profile.leg) - thigh_length
		_part(hip, "left_leg", "limb", Vector2(18,thigh_length), skin.darkened(.08), Vector2(-torso_size.x*.23, 8), -2)
		_part(_bones.left_leg, "left_shin", "shin", Vector2(17,shin_length), skin.darkened(.05), Vector2(0,thigh_length), 0)
		_part(hip, "right_leg", "limb", Vector2(18,thigh_length), skin, Vector2(torso_size.x*.23, 8), 1)
		_part(_bones.right_leg, "right_shin", "shin", Vector2(17,shin_length), skin, Vector2(0,thigh_length), 0)
		_base_sprite(_bones.left_shin,"LeftFootSprite","foot",Vector2(28,20),Vector2(0,shin_length),4)
		_base_sprite(_bones.right_shin,"RightFootSprite","foot",Vector2(28,20),Vector2(0,shin_length),4)
		_bones.left_shin.rotation_degrees = 4.0
		_bones.right_shin.rotation_degrees = -4.0

	var torso_visual := _part(hip, "torso", "torso", torso_size, skin.darkened(.04), Vector2(0,-torso_size.y), 0)
	var torso: Node2D = torso_visual.get_parent()
	var head_visual := _part(torso, "head", "head", head_size, skin, Vector2(0,-head_size.y*.25), 4)
	_head_visual = head_visual
	var head: Node2D = head_visual.get_parent()
	_head_base = _base_sprite(head,"HeadSprite","head",head_size*1.45,Vector2(0,3),1)
	_head_visual.visible = not _head_base.has_sprite()
	var ear_scale := 1.0 if race_id in ["goblin", "frost_troll"] else .55
	if not _head_base.has_sprite() and race_id in ["goblin", "frost_troll", "fae"]:
		var ear_l := Part.new().setup("ear", Vector2(28,30)*ear_scale, skin, _profile.accent); ear_l.position=Vector2(-head_size.x*.42,-head_size.y*.42); ear_l.z_index=-1; head.add_child(ear_l)
		var ear_r := Part.new().setup("ear", Vector2(-28,30)*ear_scale, skin, _profile.accent); ear_r.position=Vector2(head_size.x*.42,-head_size.y*.42); ear_r.z_index=-1; head.add_child(ear_r)
	if _profile.topology == "winged":
		var wl := Part.new().setup("wing",Vector2(-65,72),Color("a8e8de"),_profile.accent); wl.position=Vector2(-16,20); wl.z_index=-5; torso.add_child(wl)
		var wr := Part.new().setup("wing",Vector2(65,72),Color("a8e8de"),_profile.accent); wr.position=Vector2(16,20); wr.z_index=-5; torso.add_child(wr)

	var upper_arm_length := float(_profile.arm) * 0.52
	var forearm_length := float(_profile.arm) - upper_arm_length
	# Three-quarter staging: anatomical right appears on screen-left while facing
	# right. The full-rig mirror naturally reverses this when facing left. Keep
	# the roots nearer the torso center so the bent weapon hand can still cross
	# into its established screen-right resting guard.
	_part(torso, "left_arm", "limb", Vector2(16,upper_arm_length), skin.darkened(.07), Vector2(torso_size.x*.28,8), -3)
	_part(_bones.left_arm, "left_forearm", "limb", Vector2(15,forearm_length), skin.darkened(.04), Vector2(0,upper_arm_length), -3)
	_part(torso, "right_arm", "limb", Vector2(16,upper_arm_length), skin, Vector2(-torso_size.x*.28,8), 3)
	_part(_bones.right_arm, "right_forearm", "limb", Vector2(15,forearm_length), skin, Vector2(0,upper_arm_length), 3)
	_base_sprite(_bones.left_forearm,"LeftHandSprite","hand_open",Vector2(25,23),Vector2(0,forearm_length),7,90.0)
	_base_sprite(_bones.right_forearm,"RightHandSprite","hand_grip",Vector2(24,22),Vector2(0,forearm_length),7,90.0)
	# The far-side offhand crosses behind the torso so the shield appears on the
	# same screen-right side as the weapon while its inside remains visible.
	_bones.left_arm.rotation_degrees = -70; _bones.left_forearm.rotation_degrees = -20
	# Relative forearm rotation of -60 degrees produces an approximately
	# 120-degree interior elbow angle. The slight inward upper-arm rotation
	# keeps the weapon in a relaxed diagonal guard alongside the body instead
	# of projecting it horizontally forward.
	_bones.right_arm.rotation_degrees = 5; _bones.right_forearm.rotation_degrees = -60

	_attach_gear("back", torso, Vector2(0,5), -6)
	_attach_gear("armor", torso, Vector2.ZERO, 1)
	_attach_gear("pants", hip, Vector2(0,2), 2)
	_attach_gear("head", head, Vector2.ZERO, 2)
	_attach_gear("accessory", head, Vector2(0,4), 3)
	_attach_gear("weapon", _bones.right_forearm, Vector2(0,forearm_length), 6)
	_attach_gear("offhand", _bones.left_forearm, Vector2(0,forearm_length), 5)
	_capture_pose()
	_apply_facing()


func _attach_gear(slot: String, parent: Node2D, at: Vector2, z: int) -> void:
	var visual := Gear.new().setup(slot, loadout[slot], _profile.accent)
	visual.name = slot.capitalize(); visual.position = at; visual.z_index = z
	parent.add_child(visual); _gear[slot] = visual
	_apply_gear_presentation(slot, loadout[slot], visual)


func _apply_gear_presentation(slot: String, item_id: String, visual: GearVisual) -> void:
	if slot not in ["weapon", "offhand"]:
		return
	var should_carry := current_motion == &"climb" and item_id != "none" and (slot == "weapon" or item_id == "shield")
	if should_carry:
		_place_gear_on_back(slot, visual)
		return
	_place_gear_in_hand(slot, item_id, visual)


func _place_gear_on_back(slot: String, visual: GearVisual) -> void:
	if visual.get_parent() != _bones.torso:
		visual.reparent(_bones.torso, false)
	visual.set_carried_on_back(true)
	visual.set_shield_exterior(slot == "offhand")
	if slot == "weapon":
		visual.position = Vector2(18.0, float(_profile.torso.y) * .72)
		visual.rotation_degrees = 135.0
		visual.z_index = 3
	else:
		visual.position = Vector2(0.0, float(_profile.torso.y) * .58)
		visual.rotation = 0.0
		visual.z_index = 2


func _place_gear_in_hand(slot: String, item_id: String, visual: GearVisual) -> void:
	var forearm_length := float(_profile.arm) * .48
	visual.set_carried_on_back(false)
	visual.set_shield_exterior(slot == "offhand" and item_id == "shield" and facing == &"left")
	visual.rotation = 0.0
	if slot == "weapon":
		var weapon_forearm := _weapon_forearm()
		if visual.get_parent() != weapon_forearm:
			visual.reparent(weapon_forearm, false)
		visual.position = Vector2(0.0, forearm_length)
		visual.z_index = 6
		return
	var offhand_forearm := _offhand_forearm()
	if visual.get_parent() != offhand_forearm:
		visual.reparent(offhand_forearm, false)
	if item_id == "shield":
		# Advance along the crossed forearm just enough to expose the inside face
		# beyond the torso's screen-right edge.
		# Negative local X moves the shield downward in this crossed-arm pose.
		visual.position.x = -10.0
		visual.position.y = forearm_length + 20.0
		visual.z_index = -1
	else:
		visual.position.x = 0.0
		visual.position.y = forearm_length
		visual.z_index = 5


func _set_climbing_gear(enabled: bool) -> void:
	if _gear.is_empty():
		return
	# `_apply_gear_presentation` uses current_motion as the source of truth;
	# `enabled` documents the transition at each call site.
	var expected_motion := &"climb" if enabled else &"idle"
	if enabled != (current_motion == &"climb"):
		current_motion = expected_motion
	for slot in ["weapon", "offhand"]:
		var visual: GearVisual = _gear.get(slot)
		if visual:
			_apply_gear_presentation(slot, loadout[slot], visual)


func _weapon_arm() -> Node2D:
	return _bones.right_arm


func _weapon_forearm() -> Node2D:
	return _bones.right_forearm


func _offhand_forearm() -> Node2D:
	return _bones.left_forearm


func _capture_pose() -> void:
	for key in _bones:
		var node: Node2D = _bones[key]
		_rest[key] = {"position": node.position, "rotation": node.rotation, "scale": node.scale}


func _restore_pose() -> void:
	for key in _rest:
		var node: Node2D = _bones.get(key)
		if node:
			node.position = _rest[key].position; node.rotation = _rest[key].rotation; node.scale = _rest[key].scale
	_apply_facing()


func _finish_gesture() -> void:
	_restore_pose(); _gesturing = false; current_motion = &"idle"; motion_changed.emit(current_motion)


func _apply_facing() -> void:
	if not _bones.has("rig"):
		return
	var rig: Node2D = _bones.rig
	var magnitude := absf(rig.scale.x)
	if magnitude == 0.0:
		magnitude = float(_profile.get("scale", 1.0))
	rig.scale.x = -magnitude if facing == &"left" else magnitude
	if _rest.has("rig"):
		_rest.rig.scale = rig.scale


func _set_back_view(enabled: bool) -> void:
	if _head_visual:
		_head_visual.set_back_view(enabled)
	if _head_base:
		_head_base.set_back_view(enabled)


func _stop_active_animation() -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null


func _queue_motion_pose(rotations: Dictionary, rig_y: float, duration: float) -> void:
	_active_tween.tween_property(_bones.rig, "position:y", rig_y, duration)
	for bone_name in rotations:
		if _bones.has(bone_name):
			_active_tween.parallel().tween_property(_bones[bone_name], "rotation_degrees", rotations[bone_name], duration)


func _build_run_loop() -> void:
	var stride_a := {
		"torso": -7.0,
		"left_arm": -78.0, "left_forearm": -14.0,
		"right_arm": 13.0, "right_forearm": -66.0,
	}
	var stride_b := {
		"torso": -7.0,
		"left_arm": -62.0, "left_forearm": -27.0,
		"right_arm": -3.0, "right_forearm": -53.0,
	}
	if _profile.topology == "centaur":
		stride_a.merge({"horse_leg_0": -26.0, "horse_shin_0": 38.0, "horse_leg_1": 24.0, "horse_shin_1": -16.0, "horse_leg_2": 24.0, "horse_shin_2": -16.0, "horse_leg_3": -26.0, "horse_shin_3": 38.0})
		stride_b.merge({"horse_leg_0": 24.0, "horse_shin_0": -16.0, "horse_leg_1": -26.0, "horse_shin_1": 38.0, "horse_leg_2": -26.0, "horse_shin_2": 38.0, "horse_leg_3": 24.0, "horse_shin_3": -16.0})
	else:
		stride_a.merge({"left_leg": -30.0, "left_shin": 44.0, "right_leg": 26.0, "right_shin": -12.0})
		stride_b.merge({"left_leg": 26.0, "left_shin": -12.0, "right_leg": -30.0, "right_shin": 44.0})
	_queue_motion_pose(stride_a, -5.0, .16)
	_queue_motion_pose(stride_b, 1.0, .16)


func _build_climb_loop() -> void:
	# Rear-view mirrored reaches: each hand stays near its own ladder rail while
	# alternating which arm is extended to the higher rung.
	var reach_a := {
		"torso": -3.0,
		"left_arm": 170.0, "left_forearm": 10.0,
		"right_arm": -145.0, "right_forearm": -25.0,
	}
	var reach_b := {
		"torso": 3.0,
		"left_arm": 145.0, "left_forearm": 25.0,
		"right_arm": -170.0, "right_forearm": -10.0,
	}
	if _profile.topology == "centaur":
		reach_a.merge({"horse_leg_0": -18.0, "horse_shin_0": 34.0, "horse_leg_1": 18.0, "horse_shin_1": -8.0, "horse_leg_2": 12.0, "horse_shin_2": -8.0, "horse_leg_3": -12.0, "horse_shin_3": 34.0})
		reach_b.merge({"horse_leg_0": 18.0, "horse_shin_0": -8.0, "horse_leg_1": -18.0, "horse_shin_1": 34.0, "horse_leg_2": -12.0, "horse_shin_2": 34.0, "horse_leg_3": 12.0, "horse_shin_3": -8.0})
	else:
		reach_a.merge({"left_leg": -24.0, "left_shin": 48.0, "right_leg": 18.0, "right_shin": -8.0})
		reach_b.merge({"left_leg": 18.0, "left_shin": -8.0, "right_leg": -24.0, "right_shin": 48.0})
	_queue_motion_pose(reach_a, -6.0, .28)
	_queue_motion_pose(reach_b, 4.0, .28)


func _swing(node: Node2D, windup: float, strike: float) -> void:
	_active_tween.tween_property(node,"rotation_degrees",windup,.13)
	_active_tween.tween_property(node,"rotation_degrees",strike,.18).set_trans(Tween.TRANS_BACK)
	_active_tween.tween_property(node,"rotation_degrees",rad_to_deg(_rest[node.name].rotation),.24)


func _animate_weapon_curve(curve_id: String) -> void:
	var weapon_arm := _weapon_arm()
	var weapon_forearm := _weapon_forearm()
	for pose in ATTACK_CURVES[curve_id]:
		_active_tween.tween_property(weapon_arm, "rotation_degrees", pose.upper, pose.duration)
		_active_tween.parallel().tween_property(weapon_forearm, "rotation_degrees", pose.forearm, pose.duration)
		_active_tween.parallel().tween_property(_bones.torso, "rotation_degrees", pose.torso, pose.duration)
		_active_tween.parallel().tween_property(_bones.rig, "position:x", pose.x, pose.duration)
	_active_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(weapon_arm, "rotation", _rest[weapon_arm.name].rotation, .24)
	_active_tween.parallel().tween_property(weapon_forearm, "rotation", _rest[weapon_forearm.name].rotation, .24)
	_active_tween.parallel().tween_property(_bones.torso, "rotation", _rest.torso.rotation, .24)
	_active_tween.parallel().tween_property(_bones.rig, "position:x", _rest.rig.position.x, .24)


func _animate_slash() -> void: _animate_weapon_curve("forehand")
func _animate_thrust() -> void:
	_active_tween.tween_property(_bones.torso,"rotation_degrees",-12,.12)
	_active_tween.parallel().tween_property(_weapon_arm(),"rotation_degrees",-88,.12)
	_active_tween.parallel().tween_property(_weapon_forearm(),"rotation_degrees",-4,.12)
	_active_tween.tween_property(_bones.rig,"position:x",24.0,.12)
	_active_tween.tween_property(_bones.rig,"position:x",0.0,.22)
func _animate_cast() -> void:
	_active_tween.tween_property(_bones.left_arm,"rotation_degrees",-145,.22)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",145,.22)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation_degrees",18,.22)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",-18,.22)
	_active_tween.tween_property(_bones.torso,"scale",Vector2(1.08,.94),.16)
	_active_tween.tween_interval(.14)
func _animate_smash() -> void:
	_active_tween.tween_property(_weapon_arm(),"rotation_degrees",-175,.25)
	_active_tween.parallel().tween_property(_weapon_forearm(),"rotation_degrees",15,.25)
	_active_tween.tween_property(_weapon_arm(),"rotation_degrees",12,.12).set_trans(Tween.TRANS_EXPO)
	_active_tween.parallel().tween_property(_bones.rig,"position:y",7.0,.12)
	_active_tween.tween_interval(.12)
func _animate_shoot() -> void:
	_active_tween.tween_property(_bones.left_arm,"rotation_degrees",-88,.18)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",-78,.18)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation_degrees",-8,.18)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",-12,.18)
	_active_tween.tween_interval(.2)
	_active_tween.tween_property(_bones.right_arm,"rotation_degrees",-25,.08)
func _animate_leap() -> void:
	_active_tween.tween_property(_bones.rig,"position:y",12.0,.1)
	_active_tween.tween_property(_bones.rig,"position:y",-62.0,.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.parallel().tween_property(_weapon_arm(),"rotation_degrees",-130,.22)
	_active_tween.tween_property(_bones.rig,"position:y",0.0,.28).set_ease(Tween.EASE_IN)
