extends SceneTree
const Districts = preload("res://prototypes/human_hometown/districts.gd")
const TownScene = preload("res://prototypes/human_hometown/human_hometown.tscn")
var failed := false
func _initialize() -> void: _run.call_deferred()
func check(value: bool, message: String) -> void:
	if not value:
		failed = true
		printerr("FAIL: "+message)
func _run() -> void:
	check(Districts.NAMES.size() == 15,"all fifteen named districts exist")
	var count := 0
	for id in Districts.NAMES:
		var spec := Districts.spec(id)
		check(not spec.portals.is_empty(),id+" has a way out")
		count += Districts.residents(id).size()
		for portal in spec.portals:
			var reverse := false
			for back in Districts.portals(portal.to):
				if back.to == id: reverse = true
			check(reverse,id+" has reciprocal portal to "+portal.to)
			if portal.y < 480:
				var supported := false
				for platform in spec.platforms:
					if platform.position.y == portal.y and portal.x >= platform.position.x and portal.x <= platform.end.x: supported = true
				check(supported,id+" elevated portal has a landing")
	check(count >= 30,"town has a substantial quest and service cast")
	for lineage in CharacterCatalog.RACES:
		check(Districts.allowed("square",lineage,0).is_empty(),"village welcomes "+lineage)
		check(Districts.allowed("gatehouse",lineage,0).is_empty() == (lineage in Districts.LIGHT),"keep respects "+lineage+" allegiance")
	check(not Districts.allowed("tower","human",2).is_empty(),"tower requires key")
	check(Districts.allowed("tower","human",3).is_empty(),"key opens tower")
	for id in Districts.NAMES:
		set_meta("wendmere_destination",id)
		var scene = TownScene.instantiate()
		root.add_child(scene)
		scene.set_physics_process(false)
		check(scene.model.map_id == "wendmere_"+id,"loads "+id)
		check(scene.merchants.size() == Districts.residents(id).size(),"renders residents in "+id)
		check(scene.model.enemies.is_empty(),id+" services are safe")
		scene.model.health = 0
		scene.model.death_time = .01
		scene.model.step(.02,0,false)
		check(scene.model.position == scene.model.recovery_anchor,"death recovers locally in "+id)
		scene.queue_free()
		await process_frame
	remove_meta("wendmere_districts")
	var scene = TownScene.instantiate()
	root.add_child(scene)
	current_scene = scene
	scene.set_physics_process(false)
	for entry in [["square","elowen"],["archive","meriel"],["barracks","aldren"],["solar","lyra"],["square","elowen"]]:
		scene.district_id = entry[0]
		scene.residents = Districts.residents(entry[0])
		for i in scene.residents.size():
			if scene.residents[i].id == entry[1]: scene.active_merchant = i
		var dialogue = scene._make_dialogue()
		dialogue.free()
	check(scene.quest_stage == 5,"story can be completed in order")
	if not failed: print("PASS: fifteen maps, reciprocal portals, supported landings, residents, allegiance, local recovery and story")
	quit(1 if failed else 0)
