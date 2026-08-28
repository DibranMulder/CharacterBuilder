class_name ModularCharacter
extends Node2D

signal equipment_changed(slot: StringName, item_id: String)
signal gesture_started(name: String)
signal motion_changed(motion: StringName)
signal facing_changed(direction: StringName)

const Part := preload("res://src/part_visual.gd")
const Gear := preload("res://src/gear_visual.gd")
const BaseAnatomy := preload("res://src/base_anatomy_visual.gd")
const SlashTrail := preload("res://src/slash_trail_visual.gd")

const WEAPON_ATTACKS := [&"jab", &"forehand", &"backhand"]
const BOW_ATTACKS := [&"fire_bow"]
const MOTIONS := [&"idle", &"run", &"climb"]
const RUN_FRAME_DURATION := .085
const WEAPON_GRIP_ROTATIONS := {
	"sword": -90.0,
	"axe": -90.0,
	"spear": 180.0,
	"staff": 180.0,
	"bow": 90.0,
}
const BIPED_RUN_CYCLE := [
	# Contact, compression, passing, and recovery for the lead leg, followed
	# by the same four phases mirrored onto the opposite leg.
	{"y": -2.0, "rotations": {"torso": 9.0, "head": -2.0, "left_arm": -35.0, "left_forearm": -80.0, "right_arm": 30.0, "right_forearm": -95.0, "left_leg": -62.0, "left_shin": 5.0, "right_leg": 55.0, "right_shin": -5.0}},
	{"y": 3.0, "rotations": {"torso": 12.0, "head": -3.0, "left_arm": -30.0, "left_forearm": -85.0, "right_arm": 20.0, "right_forearm": -100.0, "left_leg": -32.0, "left_shin": 42.0, "right_leg": 28.0, "right_shin": 25.0}},
	{"y": 5.0, "rotations": {"torso": 14.0, "head": -4.0, "left_arm": -15.0, "left_forearm": -95.0, "right_arm": 5.0, "right_forearm": -90.0, "left_leg": 4.0, "left_shin": 72.0, "right_leg": 4.0, "right_shin": 12.0}},
	{"y": -4.0, "rotations": {"torso": 12.0, "head": -3.0, "left_arm": 15.0, "left_forearm": -105.0, "right_arm": -25.0, "right_forearm": -75.0, "left_leg": 45.0, "left_shin": -5.0, "right_leg": -55.0, "right_shin": 5.0}},
	{"y": -2.0, "rotations": {"torso": 9.0, "head": -2.0, "left_arm": 30.0, "left_forearm": -95.0, "right_arm": -35.0, "right_forearm": -80.0, "left_leg": 38.0, "left_shin": -8.0, "right_leg": -46.0, "right_shin": 10.0}},
	{"y": 3.0, "rotations": {"torso": 12.0, "head": -3.0, "left_arm": 20.0, "left_forearm": -100.0, "right_arm": -30.0, "right_forearm": -85.0, "left_leg": 28.0, "left_shin": 25.0, "right_leg": -32.0, "right_shin": 42.0}},
	{"y": 5.0, "rotations": {"torso": 14.0, "head": -4.0, "left_arm": 5.0, "left_forearm": -90.0, "right_arm": -15.0, "right_forearm": -95.0, "left_leg": 4.0, "left_shin": 12.0, "right_leg": 4.0, "right_shin": 72.0}},
	{"y": -4.0, "rotations": {"torso": 12.0, "head": -3.0, "left_arm": -25.0, "left_forearm": -75.0, "right_arm": 15.0, "right_forearm": -105.0, "left_leg": -55.0, "left_shin": 5.0, "right_leg": 45.0, "right_shin": -5.0}},
]
const ATTACK_CURVES := {
	"jab": [
		# Pull the elbow well behind the torso, then drive the shoulder, hand,
		# and horizontal blade through a long straight thrust.
		{"upper": 105.0, "forearm": -105.0, "torso": 13.0, "x": -24.0, "duration": 0.22},
		{"upper": -55.0, "forearm": 55.0, "torso": -15.0, "x": 36.0, "duration": 0.12},
	],
	"forehand": [
		# Open into a high reach-back, snap through a broad diagonal cutting
		# line, and carry the blade beyond the target into a visible follow-through.
		{"upper": -190.0, "forearm": -70.0, "torso": -13.0, "x": -16.0, "duration": 0.23},
		{"upper": -155.0, "forearm": 45.0, "torso": -17.0, "x": -20.0, "duration": 0.10},
		{"upper": -55.0, "forearm": 85.0, "torso": 18.0, "x": 24.0, "duration": 0.12},
		{"upper": 15.0, "forearm": 65.0, "torso": 12.0, "x": 18.0, "duration": 0.10},
	],
	"backhand": [
		{"upper": 45.0, "forearm": -15.0, "torso": 11.0, "x": 7.0, "duration": 0.18},
		{"upper": -120.0, "forearm": 30.0, "torso": -11.0, "x": -5.0, "duration": 0.17},
	],
}
const WEAPON_ATTACK_CURVES := {
	"spear": {
		"jab": [
			# Drop into a low, deep chamber while turning the upright spear flat.
			{"upper": 85.0, "forearm": -85.0, "torso": 11.0, "x": -30.0, "weapon_rotation": 259.0, "duration": 0.22},
			# Drive the point through a long, level thrust from below.
			{"upper": -60.0, "forearm": 60.0, "torso": -16.0, "x": 42.0, "weapon_rotation": 286.0, "duration": 0.13},
			# Withdraw and stand the spear upright before settling into idle.
			{"upper": 15.0, "forearm": -15.0, "torso": 0.0, "x": 0.0, "weapon_rotation": 180.0, "duration": 0.18},
		],
	},
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
var _left_hand_base: BaseAnatomyVisual
var _right_hand_base: BaseAnatomyVisual
var _horse_tail_base: BaseAnatomyVisual
var _horse_body_visual: PartVisual
var _horse_neck_visual: PartVisual
var _pants_parts: Array[GearVisual] = []
var _slash_trail: Node2D


func _ready() -> void:
	configure(race_id, loadout)


# This is the module's public seam. The builder/gameplay code never touches bones.
func configure(new_race_id: String, new_loadout: Dictionary = {}) -> void:
	race_id = new_race_id if CharacterCatalog.RACES.has(new_race_id) else "human"
	for slot in new_loadout:
		if loadout.has(slot): loadout[slot] = new_loadout[slot]
	if loadout.weapon == "bow":
		loadout.offhand = "none"
	_rebuild()


func equip(slot: StringName, item_id: String) -> bool:
	if not slot in CharacterCatalog.SLOT_ORDER or not item_id in CharacterCatalog.items_for(slot):
		return false
	if not supports_equipment_slot(slot):
		return false
	loadout[String(slot)] = item_id
	if slot == &"weapon" and item_id == "bow" and loadout.offhand != "none":
		loadout.offhand = "none"
		var offhand_visual: GearVisual = _gear.get("offhand")
		if offhand_visual:
			offhand_visual.setup("offhand","none",_profile.accent)
			_apply_gear_presentation("offhand","none",offhand_visual)
		equipment_changed.emit(&"offhand","none")
	if slot == &"pants":
		for pants_visual in _pants_parts:
			pants_visual.setup("pants",item_id,_profile.accent)
		equipment_changed.emit(slot,item_id)
		return true
	var visual: GearVisual = _gear.get(String(slot))
	if visual:
		visual.setup(String(slot), item_id, _profile.accent)
		_apply_gear_presentation(String(slot), item_id, visual)
	if slot == &"weapon":
		_apply_weapon_hand_parts()
	equipment_changed.emit(slot, item_id)
	return true


func supports_equipment_slot(slot: StringName) -> bool:
	if slot == &"pants" and _profile.topology == "centaur":
		return false
	if slot == &"offhand" and loadout.weapon == "bow":
		return false
	return true


func available_gestures() -> Array:
	return _profile.get("gestures", [])


func play_gesture(index: int) -> void:
	var gestures: Array = available_gestures()
	if index < 0 or index >= gestures.size(): return
	var gesture: Dictionary = gestures[index]
	_play_action(gesture.name, gesture.style)


func available_weapon_attacks() -> Array[StringName]:
	return BOW_ATTACKS.duplicate() if loadout.weapon == "bow" else WEAPON_ATTACKS.duplicate()


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
	_set_climbing_anatomy(motion == &"climb")
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
	_set_climbing_anatomy(false)
	_set_climbing_gear(false)
	motion_changed.emit(current_motion)


func play_weapon_attack(attack: StringName = &"forehand") -> void:
	if not attack in available_weapon_attacks():
		return
	_play_action("%s %s" % [String(loadout.weapon).capitalize(), String(attack).capitalize()], String(attack))


func _play_action(action_name: String, style: String) -> void:
	_stop_active_animation()
	_restore_pose()
	current_motion = &"idle"
	_gesturing = true
	_set_back_view(false)
	_set_climbing_anatomy(false)
	_set_climbing_gear(false)
	motion_changed.emit(current_motion)
	gesture_started.emit(action_name)
	_active_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	match style:
		"jab": _animate_weapon_curve("jab")
		"forehand": _animate_weapon_curve("forehand")
		"backhand": _animate_weapon_curve("backhand")
		"fire_bow": _animate_fire_bow()
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
	_horse_tail_base = null
	_horse_body_visual = null
	_horse_neck_visual = null
	_pants_parts.clear()
	_profile = CharacterCatalog.race(race_id)
	var rig := Node2D.new(); rig.name = "Rig"; add_child(rig); _bones.rig = rig
	_slash_trail = SlashTrail.new()
	_slash_trail.name = "SlashTrail"
	_slash_trail.z_index = 20
	rig.add_child(_slash_trail)
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
		_horse_body_visual = _part(hip, "horse_body", "horse", Vector2(128,62), skin.darkened(.16), Vector2(-12, 18), -1)
		_horse_neck_visual = _part(hip, "horse_neck", "horse_neck", Vector2(62,48), skin.darkened(.10), Vector2(28, -6), -1)
		var tail := Node2D.new()
		tail.name = "horse_tail"
		tail.position = Vector2(-72,12)
		tail.z_index = -4
		hip.add_child(tail)
		_bones.horse_tail = tail
		# The authored tail is rooted at its right edge and flows behind the rump.
		_horse_tail_base = _base_sprite(tail,"HorseTailSprite","horse_tail",Vector2(72,72),Vector2(-33,17),0)
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

	var torso_x := 30.0 if _profile.topology == "centaur" else 0.0
	# Rotate the torso from its waist seam so leaning never pulls the body away
	# from the hips. The painted torso and all upper-body sockets are offset back
	# to their original screen positions beneath this new pivot.
	var torso_visual := _part(hip, "torso", "torso", torso_size, skin.darkened(.04), Vector2(torso_x,0), 0)
	var torso: Node2D = torso_visual.get_parent()
	var torso_top_y := -torso_size.y
	torso_visual.position.y = torso_top_y
	var head_visual := _part(torso, "head", "head", head_size, skin, Vector2(0,torso_top_y-head_size.y*.25), 4)
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
	_part(torso, "left_arm", "limb", Vector2(16,upper_arm_length), skin.darkened(.07), Vector2(torso_size.x*.28,torso_top_y+8), -3)
	_part(_bones.left_arm, "left_forearm", "limb", Vector2(15,forearm_length), skin.darkened(.04), Vector2(0,upper_arm_length), -3)
	_part(torso, "right_arm", "limb", Vector2(16,upper_arm_length), skin, Vector2(-torso_size.x*.28,torso_top_y+8), 3)
	_part(_bones.right_arm, "right_forearm", "limb", Vector2(15,forearm_length), skin, Vector2(0,upper_arm_length), 3)
	_left_hand_base = _base_sprite(_bones.left_forearm,"LeftHandSprite","hand_open",Vector2(25,23),Vector2(0,forearm_length),7,90.0)
	_right_hand_base = _base_sprite(_bones.right_forearm,"RightHandSprite","hand_grip",Vector2(24,22),Vector2(0,forearm_length),7,90.0)
	# Idle shield guard: drop the far-side elbow beside the torso, then bend the
	# forearm across it. The wrist stays at the shield boss while the rear layer
	# lets the inner half of the shield disappear behind the body.
	_bones.left_arm.rotation_degrees = -10; _bones.left_forearm.rotation_degrees = -80
	# Cross the upper arm toward the body, then finish with a vertical forearm.
	# The +60-degree relative bend preserves the requested 120-degree interior
	# elbow while leaving the grip transform free to orient each weapon class.
	_bones.right_arm.rotation_degrees = 15; _bones.right_forearm.rotation_degrees = -15

	_attach_gear("back", torso, Vector2(0,torso_top_y+5), -6)
	_attach_gear("armor", torso, Vector2(0,torso_top_y), 1)
	_attach_pants(hip,torso_x)
	_attach_gear("head", head, Vector2.ZERO, 2)
	_attach_gear("accessory", head, Vector2(0,4), 3)
	_attach_gear("weapon", _bones.right_forearm, Vector2(0,forearm_length), 6)
	_attach_gear("offhand", _bones.left_forearm, Vector2(0,forearm_length), 5)
	if loadout.weapon == "bow":
		_place_gear_in_hand("weapon","bow",_gear.weapon)
	_apply_weapon_hand_parts()
	_capture_pose()
	_apply_facing()


func _attach_gear(slot: String, parent: Node2D, at: Vector2, z: int) -> void:
	var visual := Gear.new().setup(slot, loadout[slot], _profile.accent)
	visual.name = slot.capitalize(); visual.position = at; visual.z_index = z
	parent.add_child(visual); _gear[slot] = visual
	_apply_gear_presentation(slot, loadout[slot], visual)


func _attach_pants(hip: Node2D, torso_x: float) -> void:
	var waist := Gear.new().setup("pants",loadout.pants,_profile.accent)
	waist.name = "Pants"
	waist.position = Vector2(torso_x,2)
	waist.z_index = 2
	hip.add_child(waist)
	_gear.pants = waist
	_pants_parts.append(waist)
	if _profile.topology == "centaur":
		waist.visible = false
		return
	waist.set_pants_piece("waist")
	var thigh_length := float(_profile.leg)*.52
	var shin_length := float(_profile.leg)-thigh_length
	_attach_pants_piece(_bones.left_leg,"LeftPantsThigh","thigh",thigh_length,3)
	_attach_pants_piece(_bones.right_leg,"RightPantsThigh","thigh",thigh_length,3)
	_attach_pants_piece(_bones.left_shin,"LeftPantsShin","shin",shin_length,3)
	_attach_pants_piece(_bones.right_shin,"RightPantsShin","shin",shin_length,3)


func _attach_pants_piece(parent: Node2D, name_: String, piece: String, length: float, z: int) -> void:
	var visual := Gear.new().setup("pants",loadout.pants,_profile.accent)
	visual.name = name_
	visual.set_pants_piece(piece,length)
	visual.z_index = z
	parent.add_child(visual)
	_pants_parts.append(visual)


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
		visual.position = Vector2(18.0, -float(_profile.torso.y) * .28)
		visual.rotation_degrees = 135.0
		visual.z_index = 3
	else:
		visual.position = Vector2(0.0, -float(_profile.torso.y) * .42)
		visual.rotation = 0.0
		visual.z_index = 2


func _place_gear_in_hand(slot: String, item_id: String, visual: GearVisual) -> void:
	var forearm_length := float(_profile.arm) * .48
	visual.set_carried_on_back(false)
	visual.set_shield_exterior(slot == "offhand" and item_id == "shield" and facing == &"left")
	if slot == "weapon":
		var weapon_forearm: Node2D = _bones.left_forearm if item_id == "bow" else _weapon_forearm()
		if visual.get_parent() != weapon_forearm:
			visual.reparent(weapon_forearm, false)
		visual.position = Vector2(0.0, forearm_length)
		visual.rotation_degrees = WEAPON_GRIP_ROTATIONS.get(item_id,0.0)
		# The bow lives on the far-side arm, whose relative negative layers would
		# otherwise place the entire weapon behind the torso and armor.
		visual.z_index = 12 if item_id == "bow" else 6
		return
	visual.rotation = 0.0
	var offhand_forearm := _offhand_forearm()
	if visual.get_parent() != offhand_forearm:
		visual.reparent(offhand_forearm, false)
	if item_id == "shield":
		# Offset the visual origin by the inverse of its painted center so the
		# offhand wrist/grip lands exactly on the shield boss.
		visual.position = Vector2(0.0,forearm_length)-Gear.SHIELD_CENTER
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
	if current_motion == &"climb" and _profile.topology == "centaur" and _bones.has("torso"):
		_center_centaur_climb()
	if _rest.has("rig"):
		_rest.rig.scale = rig.scale


func _set_back_view(enabled: bool) -> void:
	if _head_visual:
		_head_visual.set_back_view(enabled)
	if _head_base:
		_head_base.set_back_view(enabled)
	if enabled:
		if _left_hand_base:
			_left_hand_base.set_part("hand_grip")
		if _right_hand_base:
			_right_hand_base.set_part("hand_grip")
	else:
		_apply_weapon_hand_parts()
	if _horse_tail_base:
		_horse_tail_base.set_back_view(enabled)
	if _horse_body_visual:
		_horse_body_visual.set_back_view(enabled)
	if _horse_neck_visual:
		_horse_neck_visual.set_back_view(enabled)


func _set_climbing_anatomy(enabled: bool) -> void:
	if _profile.topology != "centaur" or not _bones.has("horse_tail"):
		return
	for leg_index in 4:
		_bones["horse_leg_%d" % leg_index].visible = not enabled
	if enabled:
		_center_centaur_climb()
	else:
		_bones.rig.position.x = _rest.rig.position.x
	# The climbing silhouette looks down over the horse's back: recenter the
	# foreshortened barrel under the humanoid torso and root the tail at the
	# lower middle of its rump.
	_bones.horse_body.position = Vector2(_bones.torso.position.x,12) if enabled else _rest.horse_body.position
	_bones.horse_tail.position = Vector2(_bones.torso.position.x,58) if enabled else _rest.horse_tail.position
	_bones.horse_tail.rotation = 0.0 if enabled else _rest.horse_tail.rotation
	_bones.horse_tail.z_index = 1 if enabled else -4


func _center_centaur_climb() -> void:
	# The ladder is centered on the avatar origin. Counter the centaur torso's
	# side-view front offset after facing scale so its rear-view spine sits on it.
	_bones.rig.position.x = -_bones.rig.scale.x * _bones.torso.position.x


func _stop_active_animation() -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null
	if _slash_trail:
		_slash_trail.cancel()
	var weapon_visual: GearVisual = _gear.get("weapon")
	if weapon_visual and weapon_visual.item == "bow":
		weapon_visual.set_bow_draw(0.0)
	_set_bow_drawing_hand(false)


func _queue_motion_pose(rotations: Dictionary, rig_y: float, duration: float) -> void:
	_active_tween.tween_property(_bones.rig, "position:y", rig_y, duration)
	for bone_name in rotations:
		if _bones.has(bone_name):
			_active_tween.parallel().tween_property(_bones[bone_name], "rotation_degrees", rotations[bone_name], duration)
	if current_motion == &"run" and loadout.weapon in ["spear","staff"]:
		# Pole weapons stay upright in world space while their complete parent
		# chain (torso, upper arm, and forearm) continues through the run cycle.
		var parent_rotation: float = rotations.get("torso",0.0)+rotations.get("right_arm",0.0)+rotations.get("right_forearm",0.0)
		_active_tween.parallel().tween_property(_gear.weapon,"rotation_degrees",180.0-parent_rotation,duration)


func _build_run_loop() -> void:
	if _profile.topology == "centaur":
		var stride_a := {"torso": 10.0, "head": -2.0, "left_arm": -78.0, "left_forearm": -14.0, "right_arm": 13.0, "right_forearm": -66.0}
		var stride_b := {"torso": 10.0, "head": -2.0, "left_arm": -62.0, "left_forearm": -27.0, "right_arm": -3.0, "right_forearm": -53.0}
		stride_a.merge({"horse_tail": -12.0, "horse_leg_0": -31.0, "horse_shin_0": 60.0, "horse_leg_1": 28.0, "horse_shin_1": -20.0, "horse_leg_2": 28.0, "horse_shin_2": -20.0, "horse_leg_3": -31.0, "horse_shin_3": 60.0})
		stride_b.merge({"horse_tail": 10.0, "horse_leg_0": 28.0, "horse_shin_0": -20.0, "horse_leg_1": -31.0, "horse_shin_1": 60.0, "horse_leg_2": -31.0, "horse_shin_2": 60.0, "horse_leg_3": 28.0, "horse_shin_3": -20.0})
		_queue_motion_pose(stride_a, -5.0, .16)
		_queue_motion_pose(stride_b, 1.0, .16)
	else:
		for pose in BIPED_RUN_CYCLE:
			_queue_motion_pose(pose.rotations,pose.y,RUN_FRAME_DURATION)


func _build_climb_loop() -> void:
	# Rear-view mirrored reaches: each hand stays near its own ladder rail while
	# alternating which arm is extended to the higher rung.
	var reach_a := {
		"torso": -3.0,
		"left_arm": -145.0, "left_forearm": -20.0,
		"right_arm": 108.0, "right_forearm": 59.0,
	}
	var reach_b := {
		"torso": 3.0,
		"left_arm": -108.0, "left_forearm": -59.0,
		"right_arm": 145.0, "right_forearm": 20.0,
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
	var weapon_visual: GearVisual = _gear.get("weapon")
	var weapon_curves: Dictionary = WEAPON_ATTACK_CURVES.get(loadout.weapon,{})
	var curve: Array = weapon_curves.get(curve_id,ATTACK_CURVES[curve_id])
	var uses_slash_trail: bool = curve_id in ["jab","forehand","backhand"] and loadout.weapon in ["sword","axe","spear","staff"]
	var slash_start_index := 2 if curve_id == "forehand" else 1
	var slash_stop_index := 2 if curve_id == "jab" and curve.size() > 2 else curve.size()
	for pose_index in curve.size():
		var pose: Dictionary = curve[pose_index]
		if uses_slash_trail and pose_index == slash_stop_index:
			_active_tween.tween_callback(_slash_trail.stop)
		if uses_slash_trail and pose_index == slash_start_index:
			_active_tween.tween_callback(_start_slash_trail.bind(curve_id == "jab"))
		_active_tween.tween_property(weapon_arm, "rotation_degrees", pose.upper, pose.duration)
		_active_tween.parallel().tween_property(weapon_forearm, "rotation_degrees", pose.forearm, pose.duration)
		_active_tween.parallel().tween_property(_bones.torso, "rotation_degrees", pose.torso, pose.duration)
		_active_tween.parallel().tween_property(_bones.rig, "position:x", pose.x, pose.duration)
		if weapon_visual and pose.has("weapon_rotation"):
			_active_tween.parallel().tween_property(weapon_visual, "rotation_degrees", pose.weapon_rotation, pose.duration)
	if uses_slash_trail and slash_stop_index == curve.size():
		_active_tween.tween_callback(_slash_trail.stop)
	_active_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(weapon_arm, "rotation", _rest[weapon_arm.name].rotation, .24)
	_active_tween.parallel().tween_property(weapon_forearm, "rotation", _rest[weapon_forearm.name].rotation, .24)
	_active_tween.parallel().tween_property(_bones.torso, "rotation", _rest.torso.rotation, .24)
	_active_tween.parallel().tween_property(_bones.rig, "position:x", _rest.rig.position.x, .24)
	if weapon_visual:
		_active_tween.parallel().tween_property(weapon_visual, "rotation_degrees", WEAPON_GRIP_ROTATIONS.get(loadout.weapon,0.0), .24)


func _start_slash_trail(thrust_mode := false) -> void:
	var weapon_visual: GearVisual = _gear.get("weapon")
	if weapon_visual:
		_slash_trail.start(weapon_visual,Color("8edfff"),16.0 if loadout.weapon in ["spear","staff"] else 14.0,thrust_mode)


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


func _animate_fire_bow() -> void:
	var bow: GearVisual = _gear.get("weapon")
	if not bow or loadout.weapon != "bow":
		return
	bow.set_bow_draw(0.0)
	_set_bow_drawing_hand(true)
	# Present the centered grip and bring the free hand toward the string.
	_active_tween.tween_property(_bones.left_arm,"rotation_degrees",-90.0,.16)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation_degrees",0.0,.16)
	_active_tween.parallel().tween_property(bow,"rotation_degrees",90.0,.16)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",15.0,.16)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",-15.0,.16)
	# Pull the nock back toward the face while the bow hand stays locked.
	_active_tween.tween_method(bow.set_bow_draw,0.0,24.0,.24)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",-25.0,.24)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",-130.0,.24)
	_active_tween.tween_interval(.08)
	_active_tween.tween_callback(_fire_arrow)
	_active_tween.tween_method(bow.set_bow_draw,24.0,0.0,.05)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",45.0,.08)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation_degrees",-45.0,.08)
	_active_tween.tween_property(_bones.right_arm,"rotation",_rest.right_arm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.right_forearm,"rotation",_rest.right_forearm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.left_arm,"rotation",_rest.left_arm.rotation,.24)
	_active_tween.parallel().tween_property(_bones.left_forearm,"rotation",_rest.left_forearm.rotation,.24)
	_active_tween.parallel().tween_property(bow,"rotation_degrees",WEAPON_GRIP_ROTATIONS.bow,.24)
	_active_tween.tween_callback(_set_bow_drawing_hand.bind(false))


func _set_bow_drawing_hand(enabled: bool) -> void:
	if not _right_hand_base:
		return
	_right_hand_base.set_part("hand_grip" if enabled or loadout.weapon != "bow" else "hand_open")
	_right_hand_base.z_index = 20 if enabled else 7


func _apply_weapon_hand_parts() -> void:
	if _left_hand_base:
		_left_hand_base.set_part("hand_grip" if loadout.weapon == "bow" else "hand_open")
		_left_hand_base.z_index = 14 if loadout.weapon == "bow" else 7
	if _right_hand_base:
		_right_hand_base.set_part("hand_open" if loadout.weapon == "bow" else "hand_grip")


func _fire_arrow() -> void:
	var bow: GearVisual = _gear.get("weapon")
	if not bow:
		return
	var arrow := Node2D.new()
	arrow.name = "FiredArrow"
	arrow.position = _bones.rig.to_local(bow.to_global(Vector2(20,0)))
	arrow.z_index = 22
	_bones.rig.add_child(arrow)
	var shaft := Line2D.new()
	shaft.width = 3.0
	shaft.default_color = Color("d7c39b")
	shaft.points = PackedVector2Array([Vector2(-20,0),Vector2(27,0)])
	arrow.add_child(shaft)
	var head := Polygon2D.new()
	head.polygon = PackedVector2Array([Vector2(35,0),Vector2(25,-6),Vector2(25,6)])
	head.color = Color("cbd4d8")
	arrow.add_child(head)
	var flight := arrow.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	flight.tween_property(arrow,"position:x",arrow.position.x+300.0,.28)
	flight.parallel().tween_property(arrow,"modulate:a",0.0,.28).set_delay(.18)
	flight.tween_callback(arrow.queue_free)
func _animate_leap() -> void:
	_active_tween.tween_property(_bones.rig,"position:y",12.0,.1)
	_active_tween.tween_property(_bones.rig,"position:y",-62.0,.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.parallel().tween_property(_weapon_arm(),"rotation_degrees",-130,.22)
	_active_tween.tween_property(_bones.rig,"position:y",0.0,.28).set_ease(Tween.EASE_IN)
