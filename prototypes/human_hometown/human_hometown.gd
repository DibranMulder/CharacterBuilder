extends "res://prototypes/training_clearing/training_clearing.gd"
## First Human hometown map: Village Square, local services and an outbound training road.
const Town = preload("res://prototypes/human_hometown/town.gd")
const Market = preload("res://prototypes/human_hometown/market.gd")
@export var district_id := "square"
var district: Dictionary = Town.SPEC
var merchants: Array[Node2D] = []
var merchant_markers: Array[Node2D] = []
var exit_markers: Array[Node2D] = []
var active_merchant := -1
var environment: Node2D
var town_caption: Label
var local_hint: Label
var sentries: Array[Node2D] = []
var leaving := false

func _init() -> void:
	show_play_controls = true
	show_tutorial_entry = false
	location_title = "WENDMERE CROSSROADS"
	model.configure_map(Town.SPEC)
	model.position = Vector2(350,Encounter.FLOOR_Y)
	model.recovery_anchor = Vector2(350,Encounter.FLOOR_Y)

func _ready() -> void:
	district = Market.SPEC if district_id == "market" else Town.SPEC
	model.configure_map(district)
	merchant_visual_enabled = district_id != "market"
	location_title = "WENDMERE · MARKET ROW" if district_id == "market" else "WENDMERE CROSSROADS"
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
	if district_id == "market": _build_merchants()
	for i in (2 if district_id == "square" else 1):
		var marker := preload("res://src/ui/world_interaction_marker.gd").new()
		add_child(marker)
		exit_markers.append(marker)
	town_caption = _label("",Vector2(460,103),15)
	local_hint = _label("",Vector2(365,498),16)
	_update_view(0)

func _physics_process(delta: float) -> void:
	if district_id == "market": _select_nearby_merchant()
	super._physics_process(delta)
	_check_district_exit()

func _check_district_exit() -> void:
	if not _can_leave(): return
	if district_id == "square":
		if model.position.x <= 85:
			leaving = true
			_enter_district.call_deferred("market",true)
		elif model.position.x >= model.world_width-85: _start_tutorial()
	elif model.position.x >= model.world_width-85:
		leaving = true
		_enter_district.call_deferred("square",false)

func _can_leave() -> bool:
	return not paused and not leaving and model.health > 0 and model.grounded and model.attack_time <= 0 and model.projectiles.is_empty()

func _enter_district(destination: String, from_east: bool) -> void:
	var visits: Dictionary = get_tree().get_meta("wendmere_districts",{})
	visits[district_id] = model
	if not visits.has(destination):
		var next = Encounter.new()
		next.configure_map(Market.SPEC if destination == "market" else Town.SPEC)
		next.recovery_anchor = Vector2(350,Encounter.FLOOR_Y)
		visits[destination] = next
	var next = visits[destination]
	next.carry_player_from(model)
	next.position = Vector2(next.world_width-180 if from_east else 180,Encounter.FLOOR_Y)
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
	get_tree().change_scene_to_file("res://prototypes/human_hometown/market_row.tscn" if destination == "market" else "res://prototypes/human_hometown/human_hometown.tscn")

func _update_view(delta: float) -> void:
	if district_id == "market": _select_nearby_merchant()
	super._update_view(delta)
	if not is_instance_valid(environment): return
	environment.position = Vector2(-camera_x,-camera_y)
	for i in sentries.size():
		sentries[i].position = Vector2(district.sentries[i]-camera_x,Encounter.FLOOR_Y-camera_y)
	var in_menu := is_instance_valid(inventory_panel) or is_instance_valid(skill_overview) or is_instance_valid(dialogue) or is_instance_valid(shop)
	var landmark := Town.nearest(model.position.x)
	if district_id == "market":
		landmark = {"name":"Market Row","hint":"Approach a shopkeeper · E to browse or sell gear"}
		if model.position.x > 2130: landmark.hint = "Continue east through the arch to Village Square."
		for i in merchants.size():
			merchants[i].position = Vector2(Market.MERCHANTS[i].x-camera_x,Encounter.FLOOR_Y-8-camera_y)
			var spec: Dictionary = Market.MERCHANTS[i]
			merchant_markers[i].refresh(Vector2(spec.x-camera_x,210-camera_y),spec.name+"\n"+spec.role,i == active_merchant and model.can_talk_to_rowan(),not in_menu and not paused)
		talk_button.text = "E · Trade"
	else:
		talk_button.text = "E · Talk / Trade"
	for i in exit_markers.size():
		var west := district_id == "square" and i == 0
		var x: float = 110.0 if west else model.world_width-110
		var destination := "Market Row" if west else ("Willow Trail" if district_id == "square" else "Village Square")
		exit_markers[i].refresh(Vector2(x-camera_x,210-camera_y),destination+"\nWalk "+("west" if west else "east"),absf(model.position.x-x)<200 and _can_leave(),not in_menu and not paused,"west" if west else "east")
	town_caption.text = "Open Lands · "+landmark.name
	town_caption.visible = not in_menu
	local_hint.text = landmark.hint
	local_hint.visible = not in_menu and not paused

func _start_tutorial() -> void:
	if district_id != "square" or not _can_leave() or model.position.x < model.world_width-85: return
	leaving = true
	get_tree().set_meta("wendmere_model",model)
	get_tree().set_meta("clearing_departure",model)
	get_tree().set_meta("start_clearing_tutorial",true)
	get_tree().set_meta("training_character",{"lineage":model.inventory.lineage,"loadout":model.inventory.equipped.duplicate(),"facing":&"right"})
	get_tree().change_scene_to_file("res://prototypes/training_clearing/training_clearing.tscn")

func _build_merchants() -> void:
	for i in Market.MERCHANTS.size():
		var npc := Avatar.new()
		npc.configure("human",Market.loadout(i))
		npc.scale = Vector2.ONE*.69
		npc.present_static_pose("idle")
		npc.process_mode = Node.PROCESS_MODE_DISABLED
		npc.z_index = 90
		add_child(npc)
		merchants.append(npc)
		var marker := preload("res://src/ui/world_interaction_marker.gd").new()
		add_child(marker)
		merchant_markers.append(marker)
	_select_nearby_merchant()

func _select_nearby_merchant() -> void:
	if paused: return
	active_merchant = Market.nearest(model.position.x)
	model.select_merchant(Market.MERCHANTS[active_merchant])
	# Static shopkeepers stay at their storefronts; the shared interaction anchor follows selection.
	model.rowan.conversing = true

func _make_dialogue() -> Control:
	if district_id != "market": return super._make_dialogue()
	var panel := preload("res://prototypes/human_hometown/market_dialogue.gd").new()
	panel.merchant = Market.MERCHANTS[active_merchant]
	panel.outfit = Market.loadout(active_merchant)
	return panel

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
	if paused or model.health <= 0:
		draw_rect(Rect2(0,0,1152,648),Color(0,.02,.04,.25))
