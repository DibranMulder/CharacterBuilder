extends RefCounted
## Tidekin checkpoints are separate from Wendmere saves. Save game data only,
## and atomically replace the previous checkpoint after the write completes.
const Region = preload("res://prototypes/tidekin_sea/region.gd")
const Model = preload("res://prototypes/tidekin_sea/region_encounter.gd")
const Journey = preload("res://prototypes/human_hometown/town_save.gd")
const EXTRA := ["fixtures","job_cooldown","boss_active","boss_completed","active_time","recovery_anchor"]
static func path_for(lineage: String) -> String:
	return "user://tidekin_"+lineage+"_v1.save"
static func capture(scene) -> Dictionary:
	var maps := {}
	for index in scene.visits:
		var model = scene.visits[index]
		var state := Journey.snapshot(model)
		for field in EXTRA: state[field] = model.get(field)
		maps[model.map_id] = state.duplicate(true)
	var inventory = scene.model.inventory
	return {"version":1,"current":scene.model.map_id,"saved_at":Time.get_unix_time_from_system(),"maps":maps,"investigation":scene.investigation.duplicate(true),"repaired":scene.repaired.duplicate(true),"conduit_step":scene.conduit_step,"tide_time":scene.tide_time,"hero":{"lineage":inventory.lineage,"equipped":inventory.equipped.duplicate(true),"coins":inventory.coins,"potions":inventory.potions.duplicate(true),"items":inventory.items.duplicate(true),"revision":inventory.revision},"progress":scene.model.progression.snapshot()}
static func write(scene) -> Error:
	if scene.get_tree().get_script() != null or scene.model.progression == null: return OK
	var path := path_for(scene.model.inventory.lineage)
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	file.store_var(capture(scene))
	file.close()
	return DirAccess.rename_absolute(path+".tmp",path)
static func read(scene) -> bool:
	if scene.get_tree().get_script() != null: return false
	var path := path_for(scene.model.inventory.lineage)
	if not FileAccess.file_exists(path): return false
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null: return false
	var data = file.get_var(false)
	return restore(scene,data) if data is Dictionary else false
static func restore(scene, data: Dictionary) -> bool:
	if data.get("version",0) != 1: return false
	for key in ["maps","hero","progress","investigation","repaired"]:
		if not data.get(key) is Dictionary: return false
	if not data.maps.has(data.get("current","")): return false
	for key in ["lineage","equipped","coins","potions","items","revision"]:
		if not data.hero.has(key): return false
	if data.hero.lineage != scene.model.inventory.lineage: return false
	if not Region.allowed(data.current,data.hero.lineage,data.repaired.get("wells",false)).is_empty(): return false
	for id in data.maps:
		if Region.spec(id).is_empty() or not data.maps[id] is Dictionary: return false
		for field in Journey.FIELDS+EXTRA:
			if not data.maps[id].has(field): return false
	var inventory = preload("res://prototypes/training_clearing/inventory.gd").new()
	inventory.configure(data.hero.lineage,data.hero.equipped)
	inventory.coins = data.hero.coins
	inventory.potions = data.hero.potions.duplicate(true)
	inventory.items.assign(data.hero.items)
	inventory.revision = data.hero.revision
	var progress = scene.model.progression
	progress.restore(data.progress)
	var visits := {}
	var elapsed := maxf(0,Time.get_unix_time_from_system()-float(data.get("saved_at",Time.get_unix_time_from_system())))
	for id in data.maps:
		var model = Model.new()
		model.configure_region(Region.spec(id))
		model.inventory = inventory
		model.configure_equipment(inventory.equipped)
		model.progression = progress
		for field in Journey.FIELDS+EXTRA: model.set(field,data.maps[id][field])
		model.projectiles.clear()
		model.attack_time = 0
		model.ward_time = maxf(0,model.ward_time-elapsed)
		if model.ward_time == 0: model.ward = 0
		model.job_cooldown = maxf(0,model.job_cooldown-elapsed)
		model.advance_population(elapsed,id == data.current)
		var highest := 280.0
		for platform in model.platforms: highest = minf(highest,platform.position.y-200)
		if not model.position.is_finite() or model.position.x < 40 or model.position.x > model.world_width-40 or model.position.y > 480 or model.position.y < highest:
			model.position = model.recovery_anchor
			model.velocity = Vector2.ZERO
		visits[Region.index_of(id)] = model
	scene.visits = visits
	scene.map_index = Region.index_of(data.current)
	scene.model = visits[scene.map_index]
	scene.investigation = data.investigation.duplicate(true)
	scene.repaired = data.repaired.duplicate(true)
	scene.conduit_step = clampi(data.get("conduit_step",0),0,3)
	scene.tide_time = fmod(float(data.get("tide_time",0))+elapsed,60)
	return true
