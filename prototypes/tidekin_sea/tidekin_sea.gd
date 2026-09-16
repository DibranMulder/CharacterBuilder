extends "res://prototypes/training_clearing/training_clearing.gd"
## Connected Tidekin prototype, with regional art and persistent session populations.
const Region = preload("res://prototypes/tidekin_sea/region.gd")
const RegionEncounter = preload("res://prototypes/tidekin_sea/region_encounter.gd")
var MAPS: Array = Region.maps()
const FLOOR_RATIOS := {"landing":.635,"shallows":.705,"pools":.745,"citadel":.635,"shrine":.635,"mangrove":.635,"storm":.635,"confluence":.66}
var art_cache := {}
var sprite_cache := {}
var route_markers: Array[Node2D] = []
var work_markers: Array[Node2D] = []
var message := ""
var message_time := 0.0
var residents: Array[Dictionary] = []
var resident_nodes: Array[Node2D] = []
var resident_markers: Array[Node2D] = []
var active_resident := -1
var investigation := {}
var conduit_step := 0

func _init() -> void:
	model = RegionEncounter.new()
	model.configure_region(MAPS[0])

var map_index := 0
var visits := {}
var tide_time := 0.0
var repaired := {}
var aid_label: Node2D
var boss_marker: Node2D

func _ready() -> void:
	show_tutorial_entry = false
	merchant_visual_enabled = false
	get_tree().set_meta("start_clearing_tutorial",false)
	# Preview sessions have their own character and never restore a town transfer.
	for key in ["clearing_departure", "wendmere_resume_training"]:
		if get_tree().has_meta(key): get_tree().remove_meta(key)
	model.configure_region(MAPS[0])
	super._ready()
	location_title = MAPS[0].name + " · Peaceful"
	visits[0] = model
	aid_label = preload("res://src/ui/world_interaction_marker.gd").new()
	add_child(aid_label)
	boss_marker = preload("res://src/ui/world_interaction_marker.gd").new()
	add_child(boss_marker)
	if preload("res://prototypes/tidekin_sea/region_save.gd").read(self):
		camera_x = clampf(model.position.x-430,0,model.world_width-1152)
		location_title = MAPS[map_index].name + (" · Peaceful" if MAPS[map_index].species.is_empty() else " · Lv " + MAPS[map_index].levels)
		_equipment_changed()
	_build_markers()
	_update_view(0)

func _save_progress() -> void:
	var error := preload("res://prototypes/tidekin_sea/region_save.gd").write(self)
	if error != OK:
		message = "Could not save your journey. Please check available disk space."
		message_time = 5

func _start_tutorial() -> void:
	pass

func _toggle_tutorial_hints() -> void:
	pass

func _travel_map() -> void:
	pass # Portal travel is activated explicitly with Up.

func portal_point(index: int) -> Vector2:
	var xs := [80.0,model.world_width-80,400.0,model.world_width-400,model.world_width*.5]
	return Vector2(xs[index],480)

func travel_to(destination: String) -> bool:
	if destination not in MAPS[map_index].neighbors or paused or model.health <= 0: return false
	var reason := Region.allowed(destination,model.inventory.lineage,repaired.has("wells"))
	if not reason.is_empty():
		message = reason
		message_time = 5
		return false
	enter_map(Region.index_of(destination),false)
	return true

func enter_map(index: int, from_east: bool) -> void:
	if index < 0 or index >= MAPS.size(): return
	if not visits.has(index):
		var next = RegionEncounter.new()
		next.configure_region(MAPS[index])
		visits[index] = next
	var next = visits[index]
	if next != model: next.carry_player_from(model)
	model = next
	map_index = index
	model.recovery_anchor = Vector2(model.world_width-180 if from_east else 180,480)
	model.position = model.recovery_anchor
	model.velocity = Vector2.ZERO
	model.grounded = true
	model.projectiles.clear()
	model.attack_time = 0
	model.invulnerable = 1
	camera_x = clampf(model.position.x-430,0,model.world_width-1152)
	camera_y = 0
	location_title = MAPS[index].name + (" · Peaceful" if MAPS[index].species.is_empty() else " · Lv " + MAPS[index].levels)
	_build_markers()
	_update_view(0)
	_save_progress()

func _build_markers() -> void:
	for node in resident_nodes+resident_markers: node.queue_free()
	resident_nodes.clear()
	resident_markers.clear()
	residents = preload("res://prototypes/tidekin_sea/residents.gd").for_map(model.map_id,model.world_width)
	active_resident = -1
	model.rowan_enabled = not residents.is_empty()
	for resident in residents:
		var visual := preload("res://prototypes/tidekin_sea/resident_visual.gd").new()
		visual.resident = resident
		add_child(visual)
		resident_nodes.append(visual)
		var hint := preload("res://src/ui/world_interaction_marker.gd").new()
		add_child(hint)
		resident_markers.append(hint)
	for marker in route_markers+work_markers: marker.queue_free()
	route_markers.clear()
	work_markers.clear()
	for i in MAPS[map_index].neighbors.size():
		var marker = preload("res://src/ui/world_interaction_marker.gd").new()
		add_child(marker)
		route_markers.append(marker)
	for i in 3:
		var marker = preload("res://src/ui/world_interaction_marker.gd").new()
		add_child(marker)
		work_markers.append(marker)

func _restart() -> void:
	if is_instance_valid(map_panel) or is_instance_valid(inventory_panel) or is_instance_valid(skill_overview): return
	model.health = 100
	model.mana = 100
	model.death_time = 0
	model.position = model.recovery_anchor
	model.velocity = Vector2.ZERO
	paused = false
	avatar.process_mode = Node.PROCESS_MODE_INHERIT

func _physics_process(delta: float) -> void:
	if not paused:
		if active_resident >= 0:
			model.rowan.position = Vector2(residents[active_resident].x,480)
			model.rowan.conversing = true
		tide_time = fmod(tide_time+delta,60)
		message_time = maxf(0,message_time-delta)
		for index in visits:
			if index != map_index: visits[index].advance_population(delta,false)
	super._physics_process(delta)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E and not paused:
		interact()
		return
	super._unhandled_key_input(event)

func interact() -> void:
	if model.health <= 0 or model.attack_time > 0: return
	for i in residents.size():
		if model.position.distance_to(Vector2(residents[i].x,480)) < 110:
			active_resident = i
			model.select_merchant(residents[i])
			model.merchant_group = "Tidewharf Artisans"
			_talk_to_rowan()
			return
	if model.start_boss():
		message = "The Undertow Regent stirs. Watch the marked ground!"
		message_time = 5
		return
	for i in 3:
		if not _work_available(i): continue
		if model.map_id == "tidekin_sea_cr" and model.position.distance_to(model.fixture_point(i)) < 85:
			if i != conduit_step:
				conduit_step = 0
				model.fixtures = [false,false,false]
				message = "The conduits settle. Coru's rubbing reads: Shell, Wave, Pearl."
				message_time = 5
				_save_progress()
				return
			conduit_step += 1
		if model.work(i):
			message = "Water-care task %d / 3" % model.fixtures.count(true)
			if model.fixtures.all(func(value): return value):
				repaired[model.map_id] = true
				if model.map_id == "tidekin_sea_path_001" and investigation.has("samples_started"):
					investigation.sample = true
					message = "Freshwater sample collected · take it to Engineer Mero"
				elif model.map_id == "tidekin_sea_fn":
					investigation.nave = true
					message = "All three sluices repaired · follow Coru's sequence in the Reliquary"
				elif model.map_id == "tidekin_sea_cr":
					investigation.lens = true
					message = "Pearl lens recovered · install it in the Pearl Sanctum"
				elif map_index == 2: repaired.ripplefin = true
			message_time = 5
			_save_progress()
			return
	if model.map_id == "tidekin_sea_ps" and model.position.distance_to(model.fixture_point(0)) < 85 and investigation.get("lens",false):
		investigation.lens = false
		investigation.restored = true
		message = "Freshwater regulator restored · report to Sera in the Tidal Lagoon"
		message_time = 7
		_save_progress()

func _work_available(_index: int) -> bool:
	if model.map_id == "tidekin_sea_fn": return not investigation.has("nave")
	if model.map_id == "tidekin_sea_cr": return investigation.has("nave") and not investigation.has("lens") and not investigation.has("restored")
	if MAPS[map_index].group in ["village","stronghold","story"]: return false
	return true

func _talk_to_rowan() -> void:
	if paused: return
	active_resident = -1
	for i in residents.size():
		if model.position.distance_to(Vector2(residents[i].x,480)) < 110:
			active_resident = i
			model.select_merchant(residents[i])
			model.merchant_group = "Tidewharf Artisans"
			model.rowan.position = Vector2(residents[i].x,480)
			model.rowan.conversing = true
			break
	if active_resident >= 0: super._talk_to_rowan()

func _investigation_dialogue(entry: Dictionary) -> void:
	match entry.id:
		"sera":
			if investigation.has("restored"):
				entry.greeting = "Fresh water flows again. Thank you for bringing our wells back to life."
				if not investigation.has("rewarded"):
					investigation.rewarded = true
					model.award_xp(180)
					model.inventory.grant({"coins":18})
			elif not investigation.has("samples_started"):
				investigation.samples_started = true
				# A new sample contract needs three fresh, spatially separate samples.
				var index := Region.index_of("tidekin_sea_path_001")
				if visits.has(index): visits[index].fixtures = [false,false,false]
			if not Region.allowed("tidekin_sea_gs",model.inventory.lineage,true).is_empty() and not investigation.has("restored"):
				entry.greeting = "Help us clear the three runnels in Siltbank Shallows. Public water-care pays for your work. Pearl Citadel and its shrine admit Light allegiance, but the shore roads and public contracts welcome you."
		"mero":
			if investigation.has("sample"):
				investigation.diagram = true
				entry.greeting = "Your sample confirms the damaged intake. Take this diagram to Coru in Deepvault; the old conduit sequence will show us how to repair it."
		"coru":
			if investigation.has("diagram"):
				investigation.rubbing = true
				entry.greeting = "Here is the original rubbing: Shell, Wave, Pearl. Present it and Mero's diagram to Amaya in Pearl Hall."
		"amaya":
			if investigation.has("diagram") and investigation.has("rubbing"):
				repaired.wells = true
				entry.greeting = "Your investigation is authorized. Repair the three sluices in the Flooded Nave, then match Shell, Wave, Pearl in the Reliquary and restore the regulator."

func _update_view(delta: float) -> void:
	super._update_view(delta)
	map_label.position = Vector2(410,77)
	builder_button.position = Vector2(872,114)
	restart_button.position = Vector2(1010,150)
	if is_instance_valid(aid_label):
		aid_label.refresh(Vector2(560,560),message if message_time > 0 else "Controls\nA/D move · Space jump · J attack · ↑ portals · E interact · M map",false,not paused,"hint")
	if is_instance_valid(boss_marker):
		boss_marker.refresh(Vector2(model.world_width*.81-camera_x,270-camera_y),"The Undertow Regent · Lv 120\nE · Awaken",false,not paused and MAPS[map_index].id == "tidekin_sea_return_116" and not model.boss_active and not model.boss_completed,"quest_active")
	var camera := Vector2(camera_x,camera_y)
	for i in residents.size():
		var at := Vector2(residents[i].x,472)-camera
		resident_nodes[i].position = at
		resident_nodes[i].visible = at.x > -180 and at.x < 1332 and at.y > -100 and at.y < 900
		resident_markers[i].refresh(at+Vector2(0,-215),residents[i].name+" · "+residents[i].role+"\nE · Talk",model.position.distance_to(Vector2(residents[i].x,480))<110,not paused and resident_nodes[i].visible,"talk")
	for i in route_markers.size():
		var destination: String = MAPS[map_index].neighbors[i]
		var at := portal_point(i)
		var reason := Region.allowed(destination,model.inventory.lineage,repaired.has("wells"))
		var target := Region.spec(destination)
		var danger: String = " · Lv "+target.levels if target.level > 0 else ""
		route_markers[i].refresh(at-camera+Vector2(0,-205),target.name+danger+"\n"+("↑ · Travel" if reason.is_empty() else "Sealed"),reason.is_empty() and model.position.distance_to(at)<70,not paused,"east")
	for i in work_markers.size():
		var at: Vector2 = model.fixture_point(i)
		var label := "Water-care %d / 3\nE · Tend channel" % (i+1)
		var available: bool = _work_available(i) and not model.fixtures[i]
		if model.map_id == "tidekin_sea_cr": label = ["Shell","Wave","Pearl"][i]+" conduit\nE · Align"
		if model.map_id == "tidekin_sea_ps":
			available = i == 0 and investigation.get("lens",false)
			label = "Freshwater regulator\nE · Install pearl lens"
		work_markers[i].refresh(at-camera+Vector2(0,-240),label,model.position.distance_to(at)<85,not paused and available,"quest_active")

func _toggle_world_map() -> void:
	if is_instance_valid(map_panel):
		super._toggle_world_map()
		return
	if is_instance_valid(inventory_panel) or is_instance_valid(skill_overview) or is_instance_valid(dialogue) or is_instance_valid(shop) or is_instance_valid(bindings_panel): return
	paused_before_map = paused
	if not paused: _toggle_pause()
	map_panel = preload("res://src/ui/world_map.gd").new()
	map_panel.current = model.map_id
	map_panel.lineage = model.inventory.lineage
	for index in visits: map_panel.explored.append(MAPS[index].id)
	map_panel.closed.connect(_toggle_world_map)
	map_panel.test_teleport_requested.connect(_teleport_from_map)
	add_child(map_panel)
	_update_view(0)

func _make_dialogue() -> Control:
	var panel := preload("res://prototypes/tidekin_sea/resident_dialogue.gd").new()
	panel.resident = residents[active_resident].duplicate(true)
	_investigation_dialogue(panel.resident)
	_save_progress()
	panel.service_requested.connect(func(action: String):
		_close_rowan()
		if action == "skills": _toggle_skills()
		else: _toggle_inventory())
	return panel

func _texture(kit: String) -> Texture2D:
	if not art_cache.has(kit): art_cache[kit] = load("res://assets/maps/tidekin/"+kit+".png")
	return art_cache[kit]

func _draw() -> void:
	var kit: String = MAPS[map_index].art
	var texture := _texture(kit)
	var ratio: float = FLOOR_RATIOS[kit]
	# Keep scenery at a human scale as maps grow. The distant coast moves more
	# slowly than the walkable platforms; mirrored tiles avoid a hard seam.
	var factor := 430.0/(texture.get_height()*ratio)
	var art_size := texture.get_size()*factor
	draw_rect(Rect2(0,0,1152,648),Color("789fa4"))
	var offset := fmod(camera_x*.3,art_size.x*2)
	var tile := floori(camera_x*.3/(art_size.x*2))*2
	for i in range(-1,4):
		var x := i*art_size.x-offset
		if x+art_size.x < 0 or x > 1152: continue
		var flipped := (tile+i)%2 != 0
		draw_set_transform(Vector2(x+art_size.x if flipped else x,480-art_size.y*ratio-camera_y),0,Vector2(-1 if flipped else 1,1))
		draw_texture_rect(texture,Rect2(Vector2.ZERO,art_size),false,Color(.78,.89,.91))
	draw_set_transform(Vector2.ZERO)
	var mist := Color("789fa4")
	var clear_mist := mist
	clear_mist.a = .12
	var sky_end := maxf(0,480-art_size.y*ratio-camera_y)
	draw_rect(Rect2(0,0,1152,sky_end),mist)
	draw_polygon(PackedVector2Array([Vector2(0,sky_end),Vector2(1152,sky_end),Vector2(1152,420),Vector2(0,420)]),PackedColorArray([mist,mist,clear_mist,clear_mist]))
	draw_set_transform(Vector2(-camera_x,-camera_y))
	for platform in model.platforms:
		var source := Rect2(texture.get_width()*.35,texture.get_height()*(ratio-.015),texture.get_width()*.16,texture.get_height()*.075)
		draw_texture_rect_region(texture,Rect2(platform.position,Vector2(platform.size.x,42)),source)
	for i in MAPS[map_index].neighbors.size():
		var at := portal_point(i)
		if at.x >= camera_x-110 and at.x <= camera_x+1262:
			preload("res://prototypes/human_hometown/portal_visual.gd").paint(self,at,false,tide_time)
	for enemy in model.enemies:
		if enemy.hp > 0: _draw_enemy(enemy)
		elif enemy.spawn_warning > 0:
			draw_arc(Vector2(enemy.home,470),35,PI,TAU,24,Color("f4d599"),3,true)
			_caption(Vector2(enemy.home-70,400),"Returning…",14)
	for i in model.wildlife.size():
		var creature: Dictionary = model.wildlife[i]
		var at: Vector2 = model.fixture_point(i%3)+Vector2(0,-65+sin(tide_time*2+i)*5)
		_draw_creature(creature.species,at,100,1,Color.WHITE)
	for projectile in model.projectiles: draw_circle(projectile.position,6,Color("e8e0b5"))
	for drop in model.loot:
		if not drop.collected: draw_circle(drop.position+Vector2(0,-12),9,Color("e9c778"))
	draw_set_transform(Vector2.ZERO)
	if paused: draw_rect(Rect2(0,0,1152,648),Color(0,.03,.05,.35))

func _caption(at: Vector2, text: String, font_size: int) -> void:
	draw_string_outline(ThemeDB.fallback_font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,4,Color("142b39"))
	draw_string(ThemeDB.fallback_font,at,text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,CREAM)

func _draw_creature(species: String, at: Vector2, size: float, facing: float, tint: Color, enemy: Dictionary = {}) -> void:
	if at.x < camera_x-size*2 or at.x > camera_x+1152+size*2: return
	if not sprite_cache.has(species): sprite_cache[species] = load("res://assets/monsters/tidekin/"+species+".png")
	var texture: Texture2D = sprite_cache[species]
	var dimensions := texture.get_size()*size/texture.get_height()
	var info := Region.creature(species)
	var pose := preload("res://prototypes/tidekin_sea/creature_motion.gd").pose(model.active_time,at.x*.07,info.pivot[1] < 1,enemy.get("moving",false),enemy.get("state","idle"),enemy.get("timer",0.0),info)
	var facing_transform := Transform2D(0,Vector2(facing,1),0,at-Vector2(camera_x,camera_y))
	draw_set_transform_matrix(facing_transform*pose)
	draw_texture_rect(texture,Rect2(Vector2(-dimensions.x*.5,-dimensions.y),dimensions),false,tint)
	draw_set_transform(Vector2(-camera_x,-camera_y))

func _draw_enemy(enemy: Dictionary) -> void:
	if enemy.x < camera_x-340 or enemy.x > camera_x+1492: return
	var at := Vector2(enemy.x,480)
	var info := Region.creature(enemy.species)
	_draw_creature(enemy.species,at,170 if enemy.boss else 94,enemy.facing,Color(1.6,1.4,1.2) if enemy.flash>0 else Color.WHITE,enemy)
	if enemy.state in ["windup","strike"]:
		_draw_attack(enemy,info)
	_caption(at+Vector2(-80,-130 if not enemy.boss else -210),"%s · Lv %d" % [info.name,enemy.level],14)
	draw_rect(Rect2(at+Vector2(-30,-110),Vector2(60,4)),Color("254953"))
	draw_rect(Rect2(at+Vector2(-30,-110),Vector2(60*enemy.hp/enemy.max_hp,4)),Color("d7c58d"))

func _draw_attack(enemy: Dictionary, info: Dictionary) -> void:
	var zone: Rect2 = model.attack_zone(enemy)
	var active: bool = enemy.state == "strike"
	var color := Color("91e2ed") if info.attack in ["pulse","beam","pull","regent","steam"] else Color("e79f91")
	color.a = .9 if active else .55
	# Ground brackets show the committed reach without painting a solid hitbox
	# across the creature. Body anticipation carries the melee windup.
	var left := Vector2(zone.position.x,478)
	var right := Vector2(zone.end.x,478)
	draw_polyline(PackedVector2Array([left+Vector2(0,-9),left,right,right+Vector2(0,-9)]),color,2,true)
	if not active: return
	if info.attack in ["pulse","pull","regent"]:
		draw_arc(Vector2(zone.get_center().x,471),zone.size.x*.5,PI,TAU,16,color,3,true)
	elif info.attack in ["beam","shard","steam"]:
		draw_line(Vector2(zone.position.x,442),Vector2(zone.end.x,442),color,4,true)
	else:
		draw_arc(Vector2(enemy.x+enemy.facing*45,437),38,-PI*.65,PI*.4,12,color,3,true)

func _activate_portal() -> bool:
	if paused or not model.grounded: return false
	for i in MAPS[map_index].neighbors.size():
		if absf(model.position.x-portal_point(i).x) < 70 and absf(model.position.y-portal_point(i).y) < 12:
			travel_to(MAPS[map_index].neighbors[i])
			return true
	return false

func _apply_test_destination(target: Dictionary, player) -> void:
	model.carry_player_from(player)
	enter_map(target.index,false)
