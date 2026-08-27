class_name ModularCharacter
extends Node2D

signal equipment_changed(slot: StringName, item_id: String)
signal gesture_started(name: String)

const Part := preload("res://src/part_visual.gd")
const Gear := preload("res://src/gear_visual.gd")

var race_id := "human"
var loadout := {
	"weapon": "sword", "offhand": "shield", "armor": "leather",
	"head": "none", "back": "cape", "accessory": "none",
}
var _profile: Dictionary
var _bones := {}
var _gear := {}
var _active_tween: Tween
var _rest := {}
var _elapsed := 0.0
var _gesturing := false


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
	if visual: visual.setup(String(slot), item_id, _profile.accent)
	equipment_changed.emit(slot, item_id)
	return true


func available_gestures() -> Array:
	return _profile.get("gestures", [])


func play_gesture(index: int) -> void:
	var gestures: Array = available_gestures()
	if index < 0 or index >= gestures.size(): return
	if _active_tween and _active_tween.is_valid(): _active_tween.kill()
	_restore_pose()
	_gesturing = true
	var gesture: Dictionary = gestures[index]
	gesture_started.emit(gesture.name)
	_active_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	match gesture.style:
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
	pivot.add_child(visual)
	_bones[name_] = pivot
	return visual


func _rebuild() -> void:
	for child in get_children(): child.queue_free()
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
		for i in 4:
			var x := -52.0 + i * 34.0
			_part(hip, "horse_leg_%d" % i, "limb", Vector2(15,64), skin.darkened(.12), Vector2(x,38), -2 if i < 2 else 1)
	else:
		_part(hip, "left_leg", "limb", Vector2(18,float(_profile.leg)), skin.darkened(.08), Vector2(-torso_size.x*.23, 8), -2)
		_part(hip, "right_leg", "limb", Vector2(18,float(_profile.leg)), skin, Vector2(torso_size.x*.23, 8), 1)

	var torso_visual := _part(hip, "torso", "torso", torso_size, skin.darkened(.04), Vector2(0,-torso_size.y), 0)
	var torso: Node2D = torso_visual.get_parent()
	var head_visual := _part(torso, "head", "head", head_size, skin, Vector2(0,-head_size.y*.25), 4)
	var head: Node2D = head_visual.get_parent()
	var ear_scale := 1.0 if race_id in ["goblin", "frost_troll"] else .55
	if race_id in ["goblin", "frost_troll", "fae"]:
		var ear_l := Part.new().setup("ear", Vector2(28,30)*ear_scale, skin, _profile.accent); ear_l.position=Vector2(-head_size.x*.42,-head_size.y*.42); ear_l.z_index=-1; head.add_child(ear_l)
		var ear_r := Part.new().setup("ear", Vector2(-28,30)*ear_scale, skin, _profile.accent); ear_r.position=Vector2(head_size.x*.42,-head_size.y*.42); ear_r.z_index=-1; head.add_child(ear_r)
	if _profile.topology == "winged":
		var wl := Part.new().setup("wing",Vector2(-65,72),Color("a8e8de"),_profile.accent); wl.position=Vector2(-16,20); wl.z_index=-5; torso.add_child(wl)
		var wr := Part.new().setup("wing",Vector2(65,72),Color("a8e8de"),_profile.accent); wr.position=Vector2(16,20); wr.z_index=-5; torso.add_child(wr)

	_part(torso, "left_arm", "limb", Vector2(16,float(_profile.arm)), skin.darkened(.07), Vector2(-torso_size.x*.48,8), -3)
	_part(torso, "right_arm", "limb", Vector2(16,float(_profile.arm)), skin, Vector2(torso_size.x*.48,8), 3)
	_bones.left_arm.rotation_degrees = 9; _bones.right_arm.rotation_degrees = -9

	_attach_gear("back", torso, Vector2(0,5), -6)
	_attach_gear("armor", torso, Vector2.ZERO, 1)
	_attach_gear("head", head, Vector2.ZERO, 2)
	_attach_gear("accessory", head, Vector2(0,4), 3)
	_attach_gear("weapon", _bones.right_arm, Vector2(0,float(_profile.arm)), 6)
	_attach_gear("offhand", _bones.left_arm, Vector2(0,float(_profile.arm)), 5)
	_capture_pose()


func _attach_gear(slot: String, parent: Node2D, at: Vector2, z: int) -> void:
	var visual := Gear.new().setup(slot, loadout[slot], _profile.accent)
	visual.name = slot.capitalize(); visual.position = at; visual.z_index = z
	parent.add_child(visual); _gear[slot] = visual


func _capture_pose() -> void:
	for key in _bones:
		var node: Node2D = _bones[key]
		_rest[key] = {"position": node.position, "rotation": node.rotation, "scale": node.scale}


func _restore_pose() -> void:
	for key in _rest:
		var node: Node2D = _bones.get(key)
		if node:
			node.position = _rest[key].position; node.rotation = _rest[key].rotation; node.scale = _rest[key].scale


func _finish_gesture() -> void:
	_restore_pose(); _gesturing = false


func _swing(node: Node2D, windup: float, strike: float) -> void:
	_active_tween.tween_property(node,"rotation_degrees",windup,.13)
	_active_tween.tween_property(node,"rotation_degrees",strike,.18).set_trans(Tween.TRANS_BACK)
	_active_tween.tween_property(node,"rotation_degrees",rad_to_deg(_rest[node.name].rotation),.24)


func _animate_slash() -> void: _swing(_bones.right_arm, -105, 72)
func _animate_thrust() -> void:
	_active_tween.tween_property(_bones.torso,"rotation_degrees",-12,.12)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",-88,.12)
	_active_tween.tween_property(_bones.rig,"position:x",24.0,.12)
	_active_tween.tween_property(_bones.rig,"position:x",0.0,.22)
func _animate_cast() -> void:
	_active_tween.tween_property(_bones.left_arm,"rotation_degrees",-145,.22)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",145,.22)
	_active_tween.tween_property(_bones.torso,"scale",Vector2(1.08,.94),.16)
	_active_tween.tween_interval(.14)
func _animate_smash() -> void:
	_active_tween.tween_property(_bones.right_arm,"rotation_degrees",-175,.25)
	_active_tween.tween_property(_bones.right_arm,"rotation_degrees",12,.12).set_trans(Tween.TRANS_EXPO)
	_active_tween.parallel().tween_property(_bones.rig,"position:y",7.0,.12)
	_active_tween.tween_interval(.12)
func _animate_shoot() -> void:
	_active_tween.tween_property(_bones.left_arm,"rotation_degrees",-88,.18)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",-78,.18)
	_active_tween.tween_interval(.2)
	_active_tween.tween_property(_bones.right_arm,"rotation_degrees",-25,.08)
func _animate_leap() -> void:
	_active_tween.tween_property(_bones.rig,"position:y",12.0,.1)
	_active_tween.tween_property(_bones.rig,"position:y",-62.0,.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_active_tween.parallel().tween_property(_bones.right_arm,"rotation_degrees",-130,.22)
	_active_tween.tween_property(_bones.rig,"position:y",0.0,.28).set_ease(Tween.EASE_IN)

