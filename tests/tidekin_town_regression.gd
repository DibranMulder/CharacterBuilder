extends SceneTree
const Region = preload("res://prototypes/tidekin_sea/region.gd")
const Residents = preload("res://prototypes/tidekin_sea/residents.gd")
var failed := false
var scene
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func enter(id: String) -> void: scene.enter_map(Region.index_of("tidekin_sea_"+id),false)
func talk(id: String) -> void:
	for npc in scene.residents:
		if npc.id == id:
			scene.model.position = Vector2(npc.x,480)
			scene.interact()
			check(is_instance_valid(scene.dialogue),"dialogue opens for "+id)
			scene._close_rowan()
			return
	check(false,"missing resident "+id)
func work_all() -> void:
	for i in 3:
		scene.model.position = scene.model.fixture_point(i)
		scene.interact()
func run() -> void:
	scene = load("res://prototypes/tidekin_sea/tidekin_sea.tscn").instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	var names := {}
	var trainers := 0
	for map in Region.maps():
		check(map.width >= 3600,"expanded map "+map.id)
		for npc in Residents.for_map(map.id,map.width):
			names[npc.id] = true
			if "Trainer" in npc.role: trainers += 1
	for id in ["tavi","sera","neri","brineweft","ossa","pel","vela","pell","nacre","iri","sen","mero","amaya","coru","speaker","lume","toma"]:
		check(names.has(id),"authored and template resident "+id)
	check(trainers == 6,"six distinct class trainers")
	work_all()
	check(not scene.repaired.has("wells"),"generic landing work cannot unlock shrine")
	enter("ph")
	talk("amaya")
	check(not scene.repaired.has("wells"),"Amaya requires evidence")
	enter("lag")
	talk("sera")
	check(scene.investigation.has("samples_started"),"Sera starts investigation")
	enter("path_001")
	work_all()
	check(scene.investigation.has("sample"),"three runnels produce sample")
	enter("cw")
	talk("mero")
	enter("dv")
	talk("coru")
	enter("ph")
	talk("amaya")
	check(scene.repaired.has("wells"),"diagram and rubbing authorize shrine")
	check(not Region.allowed("tidekin_sea_sc","orc",true).is_empty(),"quest does not bypass allegiance")
	enter("fn")
	work_all()
	enter("cr")
	scene.model.position = scene.model.fixture_point(1)
	scene.interact()
	check(scene.conduit_step == 0 and not scene.investigation.has("lens"),"wrong symbol resets puzzle without lens")
	work_all()
	check(scene.investigation.get("lens",false),"correct sequence releases lens")
	enter("ps")
	scene.model.position = scene.model.fixture_point(0)
	scene.interact()
	check(scene.investigation.has("restored") and not scene.investigation.lens,"install consumes lens and restores regulator")
	enter("lag")
	talk("sera")
	var coins: int = scene.model.inventory.coins
	talk("sera")
	check(scene.model.inventory.coins == coins,"report reward cannot duplicate")
	enter("dy")
	for npc in scene.residents: talk(npc.id)
	enter("cm")
	for npc in scene.residents: talk(npc.id)
	scene.model.position = Vector2(scene.residents[0].x,480)
	scene.interact()
	scene._open_shop()
	check(is_instance_valid(scene.shop),"Neri opens a working shop")
	scene.model.inventory.coins = 100
	var purchase: Dictionary = scene.model.buy_from_rowan(0,scene.model.inventory.revision)
	check(purchase.ok and scene.model.inventory.coins == 76,"NPC stock uses the real purchase transaction")
	scene._close_rowan()
	enter("dy")
	scene.model.position = Vector2(scene.residents[0].x,480)
	scene.interact()
	scene.dialogue.service_requested.emit("skills")
	check(is_instance_valid(scene.skill_overview),"trainer opens shared skills overview")
	scene._toggle_skills()
	enter("inn")
	scene.model.position = Vector2(scene.residents[0].x,480)
	scene.interact()
	scene.dialogue.service_requested.emit("hero")
	check(is_instance_valid(scene.inventory_panel),"innkeeper opens hero overview")
	scene._toggle_inventory()
	scene.queue_free()
	await process_frame
	if not failed: print("PASS: expanded maps, hometown roster, NPC dialogue, ordered investigation, lens and one-time reward")
	quit(1 if failed else 0)
