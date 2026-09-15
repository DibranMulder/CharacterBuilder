extends SceneTree
const Scene = preload("res://prototypes/human_hometown/human_hometown.tscn")
const Districts = preload("res://prototypes/human_hometown/districts.gd")
const Art = preload("res://prototypes/human_hometown/resident_art.gd")
var failed := false
func _initialize() -> void: _run.call_deferred()
func check(value: bool, message: String) -> void:
	if not value:
		failed = true
		printerr("FAIL: "+message)
func _run() -> void:
	var identities := {}
	for id in Districts.NAMES:
		for resident in Districts.residents(id):
			if resident.id == "guardian": continue
			var art := Art.texture(resident.id)
			check(art != null,"painted identity exists for "+resident.id)
			var identity: String = art.atlas.resource_path+str(art.region)
			check(not identities.has(identity),"resident artwork is unique: "+resident.id)
			identities[identity] = true
	check(identities.size() == 32,"all 32 human residents have distinct art")
	set_meta("wendmere_destination","hall")
	var hall = Scene.instantiate()
	root.add_child(hall)
	current_scene = hall
	hall.set_physics_process(false)
	var tower_index := -1
	for i in hall.district.portals.size():
		if hall.district.portals[i].to == "tower": tower_index = i
	var portal: Dictionary = hall.district.portals[tower_index]
	hall.model.position = Vector2(portal.x,portal.y)
	hall.model.grounded = true
	hall._update_view(0)
	check(hall.portal_visuals[tower_index].locked,"tower doorway visibly locked before key")
	check(hall.portal_visuals[tower_index].position == Vector2(portal.x-hall.camera_x,portal.y-hall.camera_y),"glowing doorway matches actual tower trigger")
	hall._check_district_exit()
	check(not hall.leaving and hall.gate_notice_time > 0,"sealed portal explains refusal")
	hall.quest_stage = 3
	set_meta("wendmere_quest",3)
	hall.travel_grace = 0
	hall.model.position = Vector2(portal.x,480)
	hall._update_view(0)
	check(not hall.portal_visuals[tower_index].locked,"key unlocks visible tower doorway")
	hall._check_district_exit()
	check(not hall.leaving,"ground underneath raised tower entrance does not trigger travel")
	hall.model.position = Vector2(portal.x-85,portal.y)
	hall.model.velocity = Vector2.ZERO
	for frame in 50:
		hall.model.step(1.0/60,1,false)
		hall._check_district_exit()
		if hall.leaving: break
	check(hall.leaving,"walking across raised eastern landing enters unlocked tower")
	await process_frame
	await process_frame
	current_scene.set_physics_process(false)
	check(current_scene.district_id == "tower","Great Hall portal loads Tower Base")
	current_scene.model.position = Vector2(725,480)
	current_scene._talk_to_rowan()
	check(is_instance_valid(current_scene.dialogue),"painted resident dialogue opens")
	for child in current_scene.dialogue.get_children():
		if child is TextureRect:
			check(child.size == Vector2(115,180),"portrait fits its dialogue column")
			check(child.texture == Art.texture("keeper"),"portrait shares the resident identity")
	current_scene._close_rowan()
	for merchant in current_scene.merchants:
		check(merchant.get_script() == preload("res://prototypes/human_hometown/resident_visual.gd"),"residents use painted art instead of player rig")
	if not failed: print("PASS: 32 unique residents, visible sealed doorways, actual Hall-to-Tower movement")
	quit(1 if failed else 0)
