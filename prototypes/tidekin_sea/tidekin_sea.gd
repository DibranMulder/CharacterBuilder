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
	_build_markers()
	_update_view(0)

func _save_progress() -> void:
	pass

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

func _build_markers() -> void:
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
	if model.start_boss():
		message = "The Undertow Regent stirs. Watch the marked ground!"
		message_time = 5
		return
	for i in 3:
		if model.work(i):
			message = "Water-care task %d / 3" % model.fixtures.count(true)
			if model.fixtures.all(func(value): return value):
				repaired[model.map_id] = true
				if map_index == 0:
					repaired.wells = true
					message = "Samples collected · the Citadel shrine investigation is open"
				elif map_index == 2: repaired.ripplefin = true
			message_time = 5
			return

func _update_view(delta: float) -> void:
	super._update_view(delta)
	map_label.position = Vector2(410,77)
	builder_button.position = Vector2(872,114)
	restart_button.position = Vector2(1010,150)
	if is_instance_valid(aid_label):
		aid_label.refresh(Vector2(560,560),message if message_time > 0 else "Controls\nA/D move · Space jump · J attack · ↑ portals · E interact · M map",false,not paused,"hint")
	if is_instance_valid(boss_marker):
		boss_marker.refresh(Vector2(2590-camera_x,270-camera_y),"The Undertow Regent · Lv 120\nE · Awaken",false,not paused and MAPS[map_index].id == "tidekin_sea_return_116" and not model.boss_active and not model.boss_completed,"quest_active")
	var camera := Vector2(camera_x,camera_y)
	for i in route_markers.size():
		var destination: String = MAPS[map_index].neighbors[i]
		var at := portal_point(i)
		var reason := Region.allowed(destination,model.inventory.lineage,repaired.has("wells"))
		route_markers[i].refresh(at-camera+Vector2(0,-205),Region.spec(destination).name+"\n"+("↑ · Travel" if reason.is_empty() else "Sealed"),reason.is_empty() and model.position.distance_to(at)<70,not paused,"east")
	for i in work_markers.size():
		var at: Vector2 = model.fixture_point(i)
		work_markers[i].refresh(at-camera+Vector2(0,-240),"Water-care %d / 3\nE · Tend channel" % (i+1),model.position.distance_to(at)<85,not paused and not model.fixtures[i],"quest_active")

func _toggle_world_map() -> void:
	if is_instance_valid(map_panel):
		super._toggle_world_map()
		return
	if is_instance_valid(inventory_panel) or is_instance_valid(skill_overview): return
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

func _texture(kit: String) -> Texture2D:
	if not art_cache.has(kit): art_cache[kit] = load("res://assets/maps/tidekin/"+kit+".png")
	return art_cache[kit]

func _draw() -> void:
	var kit: String = MAPS[map_index].art
	var texture := _texture(kit)
	var ratio: float = FLOOR_RATIOS[kit]
	var ceiling := -170.0
	for platform in model.platforms: ceiling = minf(ceiling,platform.position.y-500)
	var factor := maxf(model.world_width/texture.get_width(),maxf((480-ceiling)/(texture.get_height()*ratio),190.0/(texture.get_height()*(1.0-ratio))))
	var art_size := texture.get_size()*factor
	var art_position := Vector2((model.world_width-art_size.x)*.5,480-art_size.y*ratio)
	draw_set_transform(Vector2(-camera_x,-camera_y))
	draw_texture_rect(texture,Rect2(art_position,art_size),false)
	for platform in model.platforms:
		var source := Rect2(texture.get_width()*.35,texture.get_height()*(ratio-.015),texture.get_width()*.16,texture.get_height()*.075)
		draw_texture_rect_region(texture,Rect2(platform.position,Vector2(platform.size.x,42)),source)
	for i in MAPS[map_index].neighbors.size():
		var at := portal_point(i)
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

func _draw_creature(species: String, at: Vector2, size: float, facing: float, tint: Color) -> void:
	if not sprite_cache.has(species): sprite_cache[species] = load("res://assets/monsters/tidekin/"+species+".png")
	var texture: Texture2D = sprite_cache[species]
	var dimensions := texture.get_size()*size/texture.get_height()
	draw_set_transform(at-Vector2(camera_x,camera_y),0,Vector2(facing,1))
	draw_texture_rect(texture,Rect2(Vector2(-dimensions.x*.5,-dimensions.y),dimensions),false,tint)
	draw_set_transform(Vector2(-camera_x,-camera_y))

func _draw_enemy(enemy: Dictionary) -> void:
	var at := Vector2(enemy.x,480)
	var info := Region.creature(enemy.species)
	_draw_creature(enemy.species,at,170 if enemy.boss else 94,enemy.facing,Color(1.6,1.4,1.2) if enemy.flash>0 else Color.WHITE)
	if enemy.state in ["windup","strike"]:
		draw_rect(model.attack_zone(enemy),Color(1,.7,.25,.28 if enemy.state == "windup" else .65))
	_caption(at+Vector2(-80,-130 if not enemy.boss else -210),"%s · Lv %d" % [info.name,enemy.level],14)
	draw_rect(Rect2(at+Vector2(-30,-110),Vector2(60,4)),Color("254953"))
	draw_rect(Rect2(at+Vector2(-30,-110),Vector2(60*enemy.hp/enemy.max_hp,4)),Color("d7c58d"))

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
