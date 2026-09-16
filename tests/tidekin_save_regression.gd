extends SceneTree
const Save = preload("res://prototypes/tidekin_sea/region_save.gd")
const Region = preload("res://prototypes/tidekin_sea/region.gd")
var failed := false
func _initialize() -> void: run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failed = true
		printerr("FAIL: "+message)
func run() -> void:
	var scene = load("res://prototypes/tidekin_sea/tidekin_sea.tscn").instantiate()
	root.add_child(scene)
	scene.set_physics_process(false)
	scene.enter_map(1,false)
	scene.model.position = Vector2(1500,480)
	scene.model.health = 53
	scene.model._damage_enemy(scene.model.enemies[0],false,99999)
	scene.investigation = {"samples_started":true,"sample":true,"diagram":true,"rubbing":true,"nave":true,"lens":true}
	scene.repaired.wells = true
	scene.enter_map(Region.index_of("tidekin_sea_cr"),false)
	scene.model.fixtures = [true,true,false]
	scene.conduit_step = 2
	var data := Save.capture(scene)
	var file := FileAccess.open("/tmp/tidekin-checkpoint-test.save",FileAccess.WRITE)
	file.store_var(data)
	file.close()
	file = FileAccess.open("/tmp/tidekin-checkpoint-test.save",FileAccess.READ)
	var loaded: Dictionary = file.get_var(false)
	file.close()
	scene.investigation.clear()
	scene.model.fixtures[0] = false
	check(Save.restore(scene,loaded),"serialized checkpoint restores")
	check(scene.model.map_id == "tidekin_sea_cr","current map restored")
	check(scene.model.health == 53,"map changes and reload do not refill health")
	check(scene.model.fixtures == [true,true,false] and scene.conduit_step == 2,"individual repair bits and conduit sequence restored")
	check(scene.investigation.lens,"unique lens ownership restored")
	check(scene.visits[1].enemies[0].hp == 0 and scene.visits[1].loot.size() == 1,"spent encounter reward and dropped loot retained")
	var damaged := loaded.duplicate(true)
	damaged.maps[damaged.current].position = Vector2(INF,INF)
	check(Save.restore(scene,damaged) and scene.model.position == scene.model.recovery_anchor,"invalid position recovers in same map")
	scene.investigation.lens = false
	scene.investigation.restored = true
	scene.investigation.rewarded = true
	data = Save.capture(scene)
	check(Save.restore(scene,data) and not scene.investigation.lens and scene.investigation.rewarded,"consumed lens and paid quest stay consumed and paid")
	data.current = "missing_map"
	check(not Save.restore(scene,data),"unknown checkpoint map is rejected")
	scene.queue_free()
	await process_frame
	if not failed: print("PASS: Tidekin serialized maps, repairs, lens ownership/consumption, rewards and same-map recovery")
	quit(1 if failed else 0)
