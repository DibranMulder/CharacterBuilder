extends RefCounted
## Atomic local journey checkpoints. SceneTree-driven tests never touch player saves.
const Districts = preload("res://prototypes/human_hometown/districts.gd")
const Model = preload("res://prototypes/human_hometown/town_encounter.gd")
const Route = preload("res://prototypes/training_clearing/tutorial.gd")
const Profiles = preload("res://src/discipline_profiles.gd")
const FIELDS := ["position","velocity","grounded","facing","health","mana","stamina","mana_delay","xp","adventure_level","potion_cooldown","skill_cooldown","lineage_cooldowns","death_time","ward","ward_time","invulnerable","enemies","loot","kills","blocks","elite_defeated","moved","jumped"]
static func path_for(lineage: String) -> String:
	return "user://wendmere_"+lineage+"_v1.save"
static func exists(lineage: String) -> bool:
	return FileAccess.file_exists(path_for(lineage))
static func snapshot(model) -> Dictionary:
	var result := {"id":model.map_id}
	for field in FIELDS: result[field] = model.get(field)
	return result.duplicate(true)
static func capture(tree: SceneTree, current, tutorial) -> Dictionary:
	var maps := {}
	for id in tree.get_meta("wendmere_districts",{}): maps["wendmere_"+id] = snapshot(tree.get_meta("wendmere_districts")[id])
	var route = tutorial if tutorial.started else (tree.get_meta("wendmere_training_route") if tree.has_meta("wendmere_training_route") else null)
	var route_data := {}
	if route != null:
		for index in route.visits: maps[Route.MAPS[index].id] = snapshot(route.visits[index])
		route_data = {"index":route.index,"actions":route.actions,"finished":route.finished,"active":route.active}
	maps[current.map_id] = snapshot(current)
	var inv = current.inventory
	return {"version":1,"saved_at":Time.get_unix_time_from_system(),"current":current.map_id,"quest":tree.get_meta("wendmere_quest",0),"maps":maps,"route":route_data,"hero":{"lineage":inv.lineage,"equipped":inv.equipped,"coins":inv.coins,"potions":inv.potions,"items":inv.items,"revision":inv.revision},"progress":current.progression.snapshot()}
static func write(tree: SceneTree, current, tutorial) -> Error:
	if tree.get_script() != null or not tree.get_meta("wendmere_journey",false): return OK
	var path := path_for(current.inventory.lineage)
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file == null: return FileAccess.get_open_error()
	file.store_var(capture(tree,current,tutorial))
	file.close()
	return DirAccess.rename_absolute(path+".tmp",path)
static func restore(tree: SceneTree, data: Dictionary) -> Dictionary:
	if data.get("version",0) != 1 or not data.has("hero") or not data.get("maps") is Dictionary or not data.maps.has(data.get("current","")):
		return {"ok":false,"error":"This journey checkpoint cannot be loaded."}
	if not data.hero is Dictionary or not data.maps is Dictionary or not data.get("route",{}) is Dictionary:
		return {"ok":false,"error":"Journey checkpoint is unreadable."}
	for key in ["lineage","equipped","coins","potions","items","revision"]:
		if not data.hero.has(key): return {"ok":false,"error":"Hero checkpoint is incomplete."}
	if not data.hero.lineage in CharacterCatalog.RACES or not data.get("progress") is Dictionary or not data.has("saved_at"):
		return {"ok":false,"error":"Hero checkpoint is unavailable."}
	var current_district: String = data.current.trim_prefix("wendmere_")
	if current_district in Districts.NAMES and not Districts.allowed(current_district,data.hero.lineage,int(data.get("quest",0))).is_empty():
		return {"ok":false,"error":"Saved map access does not match this hero."}
	if not data.get("route",{}).is_empty():
		var index := int(data.route.get("index",-1))
		if index < 0 or index >= Route.MAPS.size() or not data.maps.has(Route.MAPS[index].id):
			return {"ok":false,"error":"Saved training map unavailable."}
	var models := {}
	var inventory = preload("res://prototypes/training_clearing/inventory.gd").new()
	inventory.configure(data.hero.lineage,data.hero.equipped)
	inventory.coins = data.hero.coins
	inventory.potions = data.hero.potions.duplicate()
	inventory.items.assign(data.hero.items)
	inventory.revision = data.hero.revision
	var progress = Profiles.get_profile(tree,inventory.lineage)
	progress.restore(data.progress)
	var elapsed := maxf(0,Time.get_unix_time_from_system()-float(data.saved_at))
	for map_id in data.maps:
		var spec := {}
		var district_id: String = map_id.trim_prefix("wendmere_")
		if Districts.NAMES.has(district_id): spec = Districts.spec(district_id)
		else:
			for entry in Route.MAPS:
				if entry.id == map_id: spec = entry
		if spec.is_empty(): return {"ok":false,"error":"Saved map unavailable: "+map_id}
		var model = Model.new()
		model.configure_map(spec)
		model.inventory = inventory
		model.configure_equipment(inventory.equipped)
		model.progression = progress
		model.recovery_anchor = Vector2(350 if district_id in Districts.NAMES else 160,480)
		for field in FIELDS:
			if data.maps[map_id].has(field): model.set(field,data.maps[map_id][field])
		model.ward_time = maxf(0,model.ward_time-elapsed)
		model.invulnerable = maxf(0,model.invulnerable-elapsed)
		if model.ward_time == 0: model.ward = 0
		var minimum_y := 280.0
		for platform in model.platforms: minimum_y = minf(minimum_y,platform.position.y-200)
		if not model.position.is_finite() or model.position.x < 40 or model.position.x > model.world_width-40 or model.position.y > 480 or model.position.y < minimum_y:
			model.position = model.recovery_anchor
			model.velocity = Vector2.ZERO
		models[map_id] = model
	var visits := {}
	for map_id in models:
		if map_id.begins_with("wendmere_"): visits[map_id.trim_prefix("wendmere_")] = models[map_id]
	tree.set_meta("wendmere_districts",visits)
	if visits.has("square"): tree.set_meta("wendmere_model",visits.square)
	tree.set_meta("wendmere_quest",clampi(data.get("quest",0),0,5))
	tree.set_meta("wendmere_journey",true)
	var current = models[data.current]
	tree.set_meta("training_character",{"lineage":inventory.lineage,"loadout":inventory.equipped,"facing":&"left" if current.facing < 0 else &"right"})
	if not data.route.is_empty():
		var route = Route.new()
		route.started = true
		route.index = data.route.index
		route.actions = data.route.actions
		route.finished = data.route.finished
		route.active = data.route.active
		for index in Route.MAPS.size():
			if models.has(Route.MAPS[index].id): route.visits[index] = models[Route.MAPS[index].id]
		if not route.visits.has(route.index): return {"ok":false,"error":"Saved training map unavailable."}
		route.model = route.visits[route.index]
		tree.set_meta("wendmere_training_route",route)
	if data.current.begins_with("wendmere_"):
		tree.set_meta("wendmere_destination",data.current.trim_prefix("wendmere_"))
		return {"ok":true,"scene":"res://prototypes/human_hometown/human_hometown.tscn"}
	tree.set_meta("wendmere_resume_training",current)
	tree.set_meta("start_clearing_tutorial",false)
	return {"ok":true,"scene":"res://prototypes/training_clearing/training_clearing.tscn"}
static func read(tree: SceneTree, lineage: String) -> Dictionary:
	var file := FileAccess.open(path_for(lineage),FileAccess.READ)
	if file == null: return {"ok":false,"error":"Journey temporarily unavailable. Please try again."}
	var data = file.get_var(false)
	if not data is Dictionary: return {"ok":false,"error":"Journey checkpoint is unreadable."}
	return restore(tree,data)
