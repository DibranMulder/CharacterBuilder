extends "res://prototypes/training_clearing/training_clearing.gd"
## Fifteen connected Human hometown districts, local services and the sealed tower quest.
const Town = preload("res://prototypes/human_hometown/town.gd")
const TownEncounter = preload("res://prototypes/human_hometown/town_encounter.gd")
const Districts = preload("res://prototypes/human_hometown/districts.gd")
var wildlife: Array[Node2D] = []
var residents: Array = []
var travel_grace := 0.0
var quest_stage := 0
var gate_notice := ""
var gate_notice_time := 0.0
const Market = preload("res://prototypes/human_hometown/market.gd")
@export var district_id := "square"
var district: Dictionary = Town.SPEC
var merchants: Array[Node2D] = []
var merchant_markers: Array[Node2D] = []
var exit_markers: Array[Node2D] = []
var portal_visuals: Array[Node2D] = []
var route_signs: Array[Node2D] = []
var active_merchant := -1
var environment: Node2D
var town_caption: Label
var local_hint: Node2D
var sentries: Array[Node2D] = []
var leaving := false

func _init() -> void:
	model = TownEncounter.new()
	show_play_controls = true
	show_tutorial_entry = false
	location_title = "WENDMERE CROSSROADS"
	model.configure_map(Town.SPEC)
	model.position = Vector2(350,Encounter.FLOOR_Y)
	model.recovery_anchor = Vector2(350,Encounter.FLOOR_Y)

func _ready() -> void:
	district_id = get_tree().get_meta("wendmere_destination",district_id)
	get_tree().remove_meta("wendmere_destination") if get_tree().has_meta("wendmere_destination") else null
	district = Districts.spec(district_id)
	residents = Districts.residents(district_id)
	quest_stage = get_tree().get_meta("wendmere_quest",0)
	model.configure_map(district)
	get_tree().set_meta("wendmere_journey",true)
	merchant_visual_enabled = district_id == "square"
	location_title = "WENDMERE · "+district.name.to_upper()
	super._ready()
	var visits: Dictionary = get_tree().get_meta("wendmere_districts",{})
	var saved = visits.get(district_id)
	if district_id == "square" and get_tree().has_meta("wendmere_model"): saved = get_tree().get_meta("wendmere_model")
	if saved != null:
		_adopt_map(saved)
		_equipment_changed()
	visits[district_id] = model
	get_tree().set_meta("wendmere_districts",visits)
	environment = preload("res://prototypes/human_hometown/town_visual.gd").new()
	environment.spec = district
	environment.z_index = -100
	add_child(environment)
	rowan.scale = Vector2.ONE*.85
	for i in district.sentries.size():
		var sentry := preload("res://prototypes/human_hometown/guard_visual.gd").new()
		sentry.variant = 1 if district_id == "market" else i%2
		sentry.position = Vector2(district.sentries[i],Encounter.FLOOR_Y)
		sentry.z_index = 90
		add_child(sentry)
		sentries.append(sentry)
	_build_merchants()
	if district_id in ["square","apothecary","approach"]:
		for i in 2:
			var creature := preload("res://prototypes/human_hometown/painted_resident.gd").new()
			creature.kind = "puffkin" if i == 0 else "otter"
			creature.home = 820+i*750
			add_child(creature)
			wildlife.append(creature)
	if district_id == "approach":
		var gargoyle := preload("res://prototypes/human_hometown/painted_resident.gd").new()
		gargoyle.kind = "gargoyle"
		gargoyle.home = 1820
		gargoyle.home_y = 210
		add_child(gargoyle)
		gargoyle.z_index = -90
		wildlife.append(gargoyle)
	for i in district.portals.size() + (1 if district_id == "square" else 0):
		var marker := preload("res://src/ui/world_interaction_marker.gd").new()
		add_child(marker)
		exit_markers.append(marker)
		var doorway := preload("res://prototypes/human_hometown/portal_visual.gd").new()
		doorway.z_index = 40
		add_child(doorway)
		portal_visuals.append(doorway)
		var sign := preload("res://src/ui/world_interaction_marker.gd").new()
		add_child(sign)
		route_signs.append(sign)
	town_caption = _label("",Vector2(460,103),15)
	local_hint = preload("res://src/ui/world_interaction_marker.gd").new()
	add_child(local_hint)
	_update_view(0)
	_save_progress()

func _physics_process(delta: float) -> void:
	_select_nearby_merchant()
	travel_grace = maxf(0,travel_grace-delta)
	gate_notice_time = maxf(0,gate_notice_time-delta)
	model.climb_axis = float(Input.is_physical_key_pressed(KEY_DOWN))-float(Input.is_physical_key_pressed(KEY_UP))
	super._physics_process(delta)

func _check_district_exit() -> void:
	if not _can_leave() or travel_grace > 0: return
	for portal in district.portals:
		if absf(model.position.x-portal.x) < 32 and absf(model.position.y-portal.y) < 12:
			var refusal := Districts.allowed(portal.to,model.inventory.lineage,quest_stage)
			if not refusal.is_empty():
				gate_notice = refusal
				gate_notice_time = 5
				model.position.x += -65 if model.velocity.x >= 0 else 65
				model.velocity.x = 0
				travel_grace = 1
				return
			leaving = true
			_enter_district.call_deferred(portal.to,portal.x < 120)
			return
	if district_id == "square" and model.position.x >= model.world_width-85: _start_tutorial()

func _can_leave() -> bool:
	return not paused and not is_instance_valid(map_panel) and not leaving and model.health > 0 and model.grounded and model.attack_time <= 0 and model.projectiles.is_empty()

func _enter_district(destination: String, from_east: bool) -> void:
	if not Districts.allowed(destination,model.inventory.lineage,quest_stage).is_empty():
		leaving = false
		return
	var visits: Dictionary = get_tree().get_meta("wendmere_districts",{})
	visits[district_id] = model
	if not visits.has(destination):
		var next = TownEncounter.new()
		next.configure_map(Districts.spec(destination))
		next.recovery_anchor = Vector2(350,Encounter.FLOOR_Y)
		visits[destination] = next
	var next = visits[destination]
	next.carry_player_from(model)
	next.position = Vector2(350,Encounter.FLOOR_Y)
	for portal in Districts.portals(destination):
		if portal.to == district_id:
			next.position = Vector2(portal.x+110 if portal.x < 120 else portal.x-(85 if portal.y < 480 else 110),portal.y)
	next.velocity = Vector2.ZERO
	next.grounded = true
	next.facing = -1 if from_east else 1
	next.attack_time = 0
	next.projectiles.clear()
	next.guarding = false
	next.ward = 0
	next.ward_time = 0
	get_tree().set_meta("wendmere_districts",visits)
	if destination == "square": get_tree().set_meta("wendmere_model",next)
	get_tree().set_meta("training_character",{"lineage":model.inventory.lineage,"loadout":model.inventory.equipped.duplicate(),"facing":&"left" if from_east else &"right"})
	Journey.write(get_tree(),next,tutorial)
	get_tree().set_meta("wendmere_transfer",true)
	get_tree().set_meta("wendmere_destination",destination)
	get_tree().change_scene_to_file("res://prototypes/human_hometown/human_hometown.tscn")

func _update_view(delta: float) -> void:
	_select_nearby_merchant()
	merchant_visual_enabled = district_id == "square" and active_merchant < 0
	super._update_view(delta)
	if not is_instance_valid(environment): return
	environment.position = Vector2(-camera_x,-camera_y)
	for i in sentries.size():
		sentries[i].position = Vector2(district.sentries[i]-camera_x,Encounter.FLOOR_Y-camera_y)
	var in_menu := is_instance_valid(bindings_panel) or is_instance_valid(inventory_panel) or is_instance_valid(skill_overview) or is_instance_valid(dialogue) or is_instance_valid(shop) or is_instance_valid(map_panel)
	for creature in wildlife: creature.present(Vector2(camera_x,camera_y),0 if paused else delta)
	for i in merchants.size():
		var entry: Dictionary = residents[i]
		merchants[i].position = Vector2(entry.x-camera_x,Encounter.FLOOR_Y-8-camera_y)
		merchant_markers[i].refresh(Vector2(entry.x-camera_x,210-camera_y),entry.name+"\n"+_resident_marker_caption(entry),i == active_merchant and model.can_talk_to_rowan(),not in_menu and not paused,_resident_marker_kind(entry))
	rowan.visible = district_id == "square" and active_merchant < 0
	service_marker.visible = rowan.visible and not in_menu and not paused
	talk_button.text = "E · Talk" if active_merchant >= 0 and residents[active_merchant].stock.is_empty() else "E · Trade"
	for i in exit_markers.size():
		var portal: Dictionary = district.portals[i] if i < district.portals.size() else {"x":2330.0,"y":480.0,"to":"trail"}
		var destination: String = Districts.NAMES.get(portal.to,"Willow Trail")
		var west: bool = portal.x < 120
		var sealed := not Districts.allowed(portal.to,model.inventory.lineage,quest_stage).is_empty() if portal.to != "trail" else false
		var at := Vector2(portal.x-camera_x,portal.y-camera_y)
		portal_visuals[i].present(at,sealed,0 if paused else delta)
		var instruction := "Sealed · Warden key" if sealed and portal.to in ["tower","stair","solar"] else ("Light allegiance only" if sealed else "↑ · Travel")
		var sign_at := Vector2(clampf(at.x,105,1047),at.y-238)
		if sign_at.y < 145:
			sign_at = Vector2(clampf(at.x+(155 if at.x < 900 else -155),105,1047),145)
		exit_markers[i].refresh(sign_at,destination+"\n"+instruction,not sealed and absf(model.position.x-portal.x)<160 and absf(model.position.y-portal.y)<30 and _can_leave(),not in_menu and not paused and at.x >= 40 and at.x <= 1112,"west" if west else "east")
		route_signs[i].refresh(Vector2(portal.x-300-camera_x,430-camera_y),destination+"\nJump up the ledges",false,portal.y < 480 and 430-camera_y < 490 and not in_menu and not paused,"up")

	town_caption.text = "Open Lands · "+district.name+" · M: town map"
	town_caption.visible = not in_menu
	local_hint.refresh(Vector2(550,500),gate_notice if gate_notice_time > 0 else Districts.QUEST[quest_stage],false,not in_menu and not paused,"quest_active")

func _start_tutorial() -> void:
	if district_id != "square" or not _can_leave() or model.position.x < model.world_width-85: return
	leaving = true
	get_tree().set_meta("wendmere_model",model)
	get_tree().set_meta("clearing_departure",model)
	get_tree().set_meta("start_clearing_tutorial",true)
	get_tree().set_meta("wendmere_transfer",true)
	get_tree().set_meta("training_character",{"lineage":model.inventory.lineage,"loadout":model.inventory.equipped.duplicate(),"facing":&"right"})
	get_tree().change_scene_to_file("res://prototypes/training_clearing/training_clearing.tscn")

func _build_merchants() -> void:
	for i in residents.size():
		var npc: Node2D
		if residents[i].id == "guardian":
			npc = preload("res://prototypes/human_hometown/painted_resident.gd").new()
		else:
			npc = preload("res://prototypes/human_hometown/resident_visual.gd").new()
			npc.resident_id = residents[i].id
		npc.z_index = 90
		add_child(npc)
		merchants.append(npc)
		var marker := preload("res://src/ui/world_interaction_marker.gd").new()
		add_child(marker)
		merchant_markers.append(marker)
	_select_nearby_merchant()

func _resident_loadout(index: int) -> Dictionary:
	var outfit := CharacterCatalog.reference_loadout("human")
	outfit.merge({"back":"none","accessory":"none","pants":"cloth"},true)
	outfit.merge(residents[index].gear,true)
	var role: String = residents[index].role
	if "Warden" in role or "Captain" in role or "Vanguard" in role:
		outfit.merge({"armor":"plate","head":"helm","back":"cape","offhand":"shield"},true)
	if "Arcanist" in role or "Archivist" in role or "Lorekeeper" in role:
		outfit.merge({"head":"hood","back":"long_cape","offhand":"spellbook"},true)
	if "Ranger" in role: outfit.merge({"armor":"leather","back":"quiver"},true)
	if "Ravager" in role: outfit.merge({"armor":"leather","pants":"leather"},true)
	if residents[index].id == "lyra": outfit.merge({"head":"none","armor":"cloth","back":"long_cape","offhand":"lantern"},true)
	if residents[index].id == "king": outfit.merge({"head":"crown","back":"long_cape","offhand":"shield"},true)
	return outfit

func _select_nearby_merchant() -> void:
	if paused or residents.is_empty(): return
	active_merchant = -1
	var distance := 170.0 if district_id == "square" else INF
	for i in residents.size():
		if absf(residents[i].x-model.position.x) < distance:
			distance = absf(residents[i].x-model.position.x)
			active_merchant = i
	if active_merchant < 0:
		if model.merchant_id != "rowan": model.rowan.conversing = false
		model.select_merchant({"id":"rowan","name":"Rowan","x":1600.0,"stock":Encounter.Trader.STOCK})
		return
	model.select_merchant(residents[active_merchant])
	model.rowan.conversing = true

func _talk_to_rowan() -> void:
	_select_nearby_merchant()
	super._talk_to_rowan()

func _make_dialogue() -> Control:
	if active_merchant < 0: return super._make_dialogue()
	var entry: Dictionary = residents[active_merchant].duplicate(true)
	var speaker: String = entry.id
	var expected := ["elowen","meriel","aldren","lyra","elowen"]
	if quest_stage < expected.size() and speaker == expected[quest_stage]:
		quest_stage += 1
		get_tree().set_meta("wendmere_quest",quest_stage)
		if quest_stage == 5: entry.greeting = "Lyra is safe, and so are the roads of Wendmere.\nYou have the gratitude of everyone who calls this town home."
	elif speaker == "elowen" and quest_stage >= 5:
		entry.greeting = "Lyra is safe, and so are the roads of Wendmere.\nYou have the gratitude of everyone who calls this town home."
	elif speaker == "aldren" and quest_stage < 2:
		entry.greeting = "The tower remains sealed. Speak to Elowen and Archivist Meriel first."
	elif speaker == "meriel" and quest_stage == 0:
		entry.greeting = "Elowen in the square is investigating the tower. Start with her."
	var panel := preload("res://prototypes/human_hometown/market_dialogue.gd").new()
	panel.merchant = entry
	panel.outfit = _resident_loadout(active_merchant)
	panel.service_requested.connect(func(action: String):
		_close_rowan()
		if action == "skills": _toggle_skills()
		else: _toggle_inventory())
	return panel

func _toggle_town_map() -> void:
	_toggle_world_map()

func _restart() -> void:
	# Restart the walk without resetting purchases, supplies or hero progression.
	model.position = model.recovery_anchor
	model.velocity = Vector2.ZERO
	model.attack_time = 0
	model.projectiles.clear()
	model.grounded = true
	paused = false
	avatar.process_mode = Node.PROCESS_MODE_INHERIT
	_adopt_map(model)

func _draw() -> void:
	# Scenery is retained by its Sprite2D rather than rebuilt in the frame loop.
	draw_set_transform(Vector2(-camera_x,-camera_y))
	for drop in model.loot:
		if drop.collected: continue
		var at: Vector2 = drop.position+Vector2(0,-22)
		draw_circle(at,15,Color("584c37"))
		draw_arc(at,12,0,TAU,24,Color("e9cf8d"),2,true)
		draw_colored_polygon(PackedVector2Array([at+Vector2(0,-9),at+Vector2(7,0),at+Vector2(0,9),at+Vector2(-7,0)]),Color("e9cf8d"))
	draw_set_transform(Vector2.ZERO)
	if paused or model.health <= 0:
		draw_rect(Rect2(0,0,1152,648),Color(0,.02,.04,.25))

func _movement_pose() -> String:
	return "climb" if model.climbing else super._movement_pose()


func _travel_from_map(destination: String) -> void:
	if not is_instance_valid(map_panel) or leaving or not Districts.NAMES.has(destination): return
	if not map_panel.is_explored(destination):
		map_panel.status.text = "Explore this district on foot to reveal it and unlock map travel."
		return
	var refusal := Districts.allowed(destination,model.inventory.lineage,quest_stage)
	if not refusal.is_empty():
		map_panel.status.text = refusal
		return
	if destination == district_id:
		_toggle_town_map()
		return
	if model.health <= 0 or model.attack_time > 0 or not model.projectiles.is_empty():
		map_panel.status.text = "Finish your current action or recover before travelling."
		return
	_toggle_town_map()
	leaving = true
	_enter_district.call_deferred(destination,false)

func _resident_marker_kind(entry: Dictionary) -> String:
	if not entry.stock.is_empty(): return "trade"
	var expected := ["elowen","meriel","aldren","lyra","elowen"]
	if quest_stage < expected.size() and entry.id == expected[quest_stage]: return "quest_active"
	if quest_stage < 5 and entry.id in expected: return "quest"
	return "talk"

func _resident_marker_caption(entry: Dictionary) -> String:
	match _resident_marker_kind(entry):
		"trade": return "Trade · "+entry.role
		"quest_active": return "Quest · Speak here"
		"quest": return "Quest · "+entry.role
	return entry.role

func _activate_portal() -> bool:
	if paused or not model.grounded: return false
	for portal in district.portals:
		if absf(model.position.x-portal.x) < 32 and absf(model.position.y-portal.y) < 12:
			_check_district_exit()
			return true
	if district_id == "square" and model.position.x >= model.world_width-85 and absf(model.position.y-480) < 12:
		_check_district_exit()
		return true
	return false

func _apply_test_destination(_target: Dictionary, player) -> void:
	model.carry_player_from(player)
	model.position = Vector2(350,Encounter.FLOOR_Y)
	camera_x = 0
	camera_y = 0
	travel_grace = .5
