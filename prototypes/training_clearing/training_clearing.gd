extends Node2D
## Local gameplay experiment, separate from the character-builder entry point.

const Encounter := preload("res://prototypes/training_clearing/encounter.gd")
const Avatar := preload("res://prototypes/training_clearing/vanguard_visual.gd")
const Chronicle := preload("res://src/ui/chronicle_theme.gd")
const Profiles = preload("res://src/discipline_profiles.gd")
var save_timer := 0.0
const INK := Color("203c38")
const CREAM := Color("f6edce")
var model = Encounter.new()
var avatar: Node2D
var camera_x := 0.0
var camera_y := 0.0
var fingers := {}
var touch_left := false
var touch_right := false
var touch_guard := false
var paused := false
var feedback := preload("res://prototypes/training_clearing/combat_overlay.gd").new()
var monster_impacts := preload("res://src/monster_impact.gd").new()
var reaction := preload("res://src/ui/combat_reaction.gd").new()
var resources := preload("res://prototypes/training_clearing/resource_hud.gd").new()
var hud: Label
var notice: Label
var skill_button: Button
var skill_buttons: Array[Button] = []
var last_pose := ""
var inventory_panel: Panel
var skill_overview: Control
var paused_before_skills := false
var paused_before_inventory := false
var hp_button: Button
var mana_button: Button
var attack_button: Button
var guard_button: Button
var builder_button: Button
var restart_button: Button
var rowan: Node2D
var rowan_balloon: Panel
var talk_button: Button
var dialogue: Control
var shop: Control
var paused_before_rowan := false

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("182e2e"))
	avatar = Avatar.new()
	# Rig layers include negative z-indices; keep them above the world painting.
	avatar.z_index = 100
	add_child(avatar)
	var selection: Dictionary = get_tree().get_meta("training_character", {
		"lineage": "human", "loadout": CharacterCatalog.reference_loadout("human"),
	})
	avatar.configure(selection.lineage, selection.loadout.duplicate())
	model.configure_equipment(avatar.loadout)
	model.inventory.configure(avatar.race_id, avatar.loadout)
	model.progression = Profiles.get_profile(get_tree(),avatar.race_id)
	model.facing = -1.0 if selection.get("facing", &"right") == &"left" else 1.0
	avatar.scale = Vector2.ONE * .69
	add_child(feedback)
	monster_impacts.z_index = 120
	add_child(monster_impacts)
	add_child(resources)
	resources.player_name = CharacterCatalog.race(avatar.race_id).name.to_upper()
	resources.set_character(avatar.race_id,avatar.loadout)
	rowan = preload("res://prototypes/training_clearing/rowan_visual.gd").new()
	rowan.z_index = 90
	add_child(rowan)
	rowan_balloon = preload("res://src/ui/speech_balloon.gd").new()
	rowan_balloon.z_index = 180
	add_child(rowan_balloon)
	_build_ui()
	get_window().focus_exited.connect(_lose_focus)
	_update_view(0)

func _build_ui() -> void:
	talk_button = _button("E · Rowan",Vector2.ZERO,Vector2(115,40))
	talk_button.pressed.connect(_talk_to_rowan)
	hud = _label("", Vector2(1010, 112), 15)
	notice = _label("", Vector2(484, 24), 18)
	builder_button = _button("Builder", Vector2(1010, 66), Vector2(112, 38))
	builder_button.pressed.connect(func(): get_tree().change_scene_to_file("res://main.tscn"))
	_button("Pause · Esc", Vector2(872, 20), Vector2(128, 38)).pressed.connect(_toggle_pause)
	restart_button = _button("Restart · R", Vector2(872, 66), Vector2(128, 38))
	restart_button.pressed.connect(_restart)
	_button("Pouch · I", Vector2(1010,20), Vector2(112,38)).pressed.connect(_toggle_inventory)
	_button("Skills · L", Vector2(738,20), Vector2(124,38)).pressed.connect(_toggle_skills)
	hp_button = _button("", Vector2(366,536), Vector2(144,48))
	hp_button.pressed.connect(_potion.bind("hp"))
	mana_button = _button("", Vector2(522,536), Vector2(144,48))
	mana_button.pressed.connect(_potion.bind("mana"))
	var left := _button("←", Vector2(26, 548), Vector2(82, 70))
	left.button_down.connect(func(): touch_left = true)
	left.button_up.connect(func(): touch_left = false)
	var right := _button("→", Vector2(118, 548), Vector2(82, 70))
	right.button_down.connect(func(): touch_right = true)
	right.button_up.connect(func(): touch_right = false)
	_button("JUMP\nSpace", Vector2(226, 548), Vector2(105, 70)).pressed.connect(_jump)
	var guard := _button("GUARD\nHold Shift / 2", Vector2(712, 548), Vector2(125, 70))
	guard_button = guard
	guard.disabled = not model.can_guard
	if not model.can_guard:
		guard.text = "NO SHIELD"
	guard.button_down.connect(func(): touch_guard = true)
	guard.button_up.connect(func(): touch_guard = false)
	attack_button = _button("ATTACK\nJ / 1", Vector2(847, 548), Vector2(125, 70))
	if model.mana_cost() > 0:
		attack_button.text = "SPELL\nJ / 1 · 8 mana"
	attack_button.disabled = model.weapon == "none"
	attack_button.pressed.connect(_attack.bind(false))
	skill_button = _button("", Vector2(982, 548), Vector2(144, 70))
	skill_button.theme_type_variation = "PrimaryButton"
	skill_button.pressed.connect(_attack.bind(true))
	for i in model.lineage_kit().size():
		var tile := preload("res://src/ui/skill_tile.gd").new()
		tile.position = Vector2(112+i*52,116)
		tile.size = Vector2(48,70)
		tile.z_index = 210
		tile.configure(model.lineage_kit()[i],str(i+3))
		tile.pressed.connect(_lineage_skill.bind(i))
		add_child(tile)
		skill_buttons.append(tile)

func _label(value: String, at: Vector2, size: int) -> Label:
	var label := Label.new()
	label.theme = Chronicle.create()
	label.z_index = 200
	label.text = value
	label.position = at
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("dae4c7"))
	label.add_theme_color_override("font_outline_color", Color("101b2c"))
	label.add_theme_constant_override("outline_size",3)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _button(value: String, at: Vector2, dimensions: Vector2) -> Button:
	var button := Button.new()
	button.theme = Chronicle.create()
	button.z_index = 200
	button.text = value
	button.position = at
	button.size = dimensions
	button.focus_mode = Control.FOCUS_NONE
	add_child(button)
	return button

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	if is_instance_valid(shop) or is_instance_valid(dialogue):
		if event.physical_keycode == KEY_ESCAPE:
			_back_to_rowan() if is_instance_valid(shop) else _close_rowan()
		return
	if is_instance_valid(skill_overview):
		if event.physical_keycode in [KEY_ESCAPE,KEY_L]: _toggle_skills()
		elif event.physical_keycode == KEY_I: _skills_to_pouch()
		return
	if event.physical_keycode == KEY_L:
		_toggle_skills()
		return
	if event.physical_keycode == KEY_I or (is_instance_valid(inventory_panel) and event.physical_keycode == KEY_ESCAPE):
		_toggle_inventory()
		return
	if is_instance_valid(inventory_panel):
		return
	match event.physical_keycode:
		KEY_E: _talk_to_rowan()
		KEY_H: _potion("hp")
		KEY_M: _potion("mana")
		KEY_SPACE, KEY_W, KEY_UP: _jump()
		KEY_J, KEY_1: _attack(false)
		KEY_K: _attack(true)
		KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8: _lineage_skill(event.physical_keycode-KEY_3)
		KEY_ESCAPE: _toggle_pause()
		KEY_R: _restart()

func _lineage_skill(slot: int) -> void:
	if paused: return
	if model.begin_lineage_skill(slot):
		avatar.present_arena_action(model.active_skill,model.attack_animation())
		last_pose = "attack"
	elif not model.last_rejection.is_empty():
		feedback.push({"kind":"notice","text":model.last_rejection,"position":model.position+Vector2(0,-170)})

func _jump() -> void:
	if not paused:
		model.jump()

func _attack(power: bool) -> void:
	if power:
		_lineage_skill(4)
		return
	if not paused and model.begin_attack(power):
		avatar.play_weapon_attack(model.attack_animation())
		last_pose = "attack"
	elif not paused and not model.last_rejection.is_empty():
		if not feedback.floaters.any(func(item): return item.text == model.last_rejection):
			feedback.push({"kind":"notice", "text":model.last_rejection, "position":model.position + Vector2(0,-170)})

func _toggle_pause() -> void:
	if is_instance_valid(skill_overview) or is_instance_valid(inventory_panel) or is_instance_valid(dialogue) or is_instance_valid(shop):
		return
	paused = not paused
	avatar.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT
	touch_left = false
	touch_right = false
	touch_guard = false
	fingers.clear()

func _lose_focus() -> void:
	if not paused:
		_toggle_pause()

func _restart() -> void:
	_save_progress()
	reaction = preload("res://src/ui/combat_reaction.gd").new()
	if is_instance_valid(skill_overview): _toggle_skills()
	_close_rowan()
	if is_instance_valid(inventory_panel):
		_toggle_inventory()
	var selected_facing: float = model.facing
	model = Encounter.new()
	model.configure_equipment(avatar.loadout)
	model.inventory.configure(avatar.race_id, avatar.loadout)
	model.facing = selected_facing
	model.progression = Profiles.get_profile(get_tree(),avatar.race_id)
	feedback.reset()
	monster_impacts.reset()
	paused = false
	avatar.process_mode = Node.PROCESS_MODE_INHERIT
	avatar.stop_motion()
	last_pose = ""
	touch_left = false
	touch_right = false
	touch_guard = false
	camera_x = 0
	camera_y = 0
	fingers.clear()

func _toggle_inventory() -> void:
	if is_instance_valid(skill_overview) or is_instance_valid(dialogue) or is_instance_valid(shop): return
	if is_instance_valid(inventory_panel):
		inventory_panel.queue_free()
		inventory_panel = null
		paused = paused_before_inventory
		avatar.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT
		return
	paused_before_inventory = paused
	if not paused:
		_toggle_pause()
	inventory_panel = preload("res://prototypes/training_clearing/inventory_panel.gd").new()
	inventory_panel.model = model
	inventory_panel.closed.connect(_toggle_inventory)
	inventory_panel.equipment_changed.connect(_equipment_changed)
	inventory_panel.skills_requested.connect(_toggle_skills)
	inventory_panel.disciplines_requested.connect(func(): _toggle_skills(); skill_overview.show_disciplines())
	add_child(inventory_panel)

func _toggle_skills() -> void:
	if is_instance_valid(dialogue) or is_instance_valid(shop): return
	if is_instance_valid(skill_overview):
		skill_overview.queue_free()
		skill_overview = null
		paused = paused_before_skills
		avatar.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT
		return
	if is_instance_valid(inventory_panel): _toggle_inventory()
	paused_before_skills = paused
	if not paused: _toggle_pause()
	skill_overview = preload("res://src/ui/skill_overview.gd").new()
	skill_overview.lineage = avatar.race_id
	skill_overview.progression = model.progression
	skill_overview.combat_model = model
	skill_overview.closed.connect(_toggle_skills)
	skill_overview.pouch_requested.connect(_skills_to_pouch)
	add_child(skill_overview)

func _skills_to_pouch() -> void:
	_toggle_skills()
	_toggle_inventory()

func _talk_to_rowan() -> void:
	if paused or is_instance_valid(inventory_panel) or not model.can_talk_to_rowan(): return
	paused_before_rowan = paused
	model.rowan.begin_conversation(model.position)
	_toggle_pause()
	dialogue = preload("res://prototypes/training_clearing/rowan_dialogue.gd").new()
	dialogue.closed.connect(_close_rowan)
	dialogue.trade_requested.connect(_open_shop)
	add_child(dialogue)
	_update_view(0)

func _open_shop() -> void:
	if not is_instance_valid(dialogue) or is_instance_valid(shop) or not model.can_talk_to_rowan(): return
	dialogue.hide()
	shop = preload("res://prototypes/training_clearing/shop_panel.gd").new()
	shop.model = model
	shop.closed.connect(_back_to_rowan)
	add_child(shop)

func _back_to_rowan() -> void:
	if is_instance_valid(shop):
		shop.queue_free()
		shop = null
	if is_instance_valid(dialogue): dialogue.show()

func _close_rowan() -> void:
	if not is_instance_valid(dialogue) and not is_instance_valid(shop): return
	if is_instance_valid(shop): shop.queue_free()
	if is_instance_valid(dialogue): dialogue.queue_free()
	shop = null
	dialogue = null
	model.rowan.end_conversation()
	paused = paused_before_rowan
	avatar.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT
	_update_view(0)

func _equipment_changed() -> void:
	var facing_direction: StringName = avatar.facing
	avatar.configure(avatar.race_id, model.inventory.equipped.duplicate())
	avatar.set_facing(facing_direction)
	resources.set_character(avatar.race_id,avatar.loadout)
	last_pose = ""
	_update_view(0)

func _potion(kind: String) -> void:
	if paused:
		return
	var event: Dictionary = model.use_potion(kind)
	if not event.is_empty():
		feedback.push(event)
		reaction.receive(event)
	_update_view(0)

func _physics_process(delta: float) -> void:
	if not paused:
		reaction.advance(delta)
		monster_impacts.advance(delta)
		var direction := float(touch_right or Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(touch_left or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
		var socket: Vector2 = avatar.skill_projectile_socket(model.active_skill) if model.attack_kind == "lineage" else avatar.projectile_socket()
		var muzzle: Vector2 = to_local(socket) + Vector2(camera_x, camera_y)
		var available := []
		for skill in model.lineage_kit(): available.append(model.progression.allows(skill))
		model.step(delta, direction, touch_guard or Input.is_physical_key_pressed(KEY_SHIFT) or Input.is_physical_key_pressed(KEY_2), muzzle)
		for i in available.size():
			if not available[i] and model.progression.allows(model.lineage_kit()[i]):
				feedback.push({"kind":"level","text":"Unlocked: "+model.lineage_kit()[i].name,"position":model.position+Vector2(0,-220)})
		for event in model.events:
			feedback.push(event)
			monster_impacts.push(event)
			if event.get("kind","") in ["taken","blocked","ward","heal"]: reaction.receive(event)
		feedback.advance(delta)
		for notice_text in model.progression.notices:
			feedback.push({"kind":"level","text":notice_text,"position":model.position+Vector2(0,-180)})
		model.progression.notices.clear()
		save_timer += delta
		if save_timer >= 10:
			_save_progress()
			save_timer = 0
	_update_view(delta)

func _update_view(delta: float) -> void:
	var viewport_size := get_viewport_rect().size
	var factor := minf(viewport_size.x / 1152.0, viewport_size.y / 648.0)
	scale = Vector2.ONE * factor
	position = (viewport_size - Vector2(1152, 648) * factor) * .5
	camera_x = lerpf(camera_x, clampf(model.position.x - 430, 0, 1048), minf(1, delta * 8))
	camera_y = lerpf(camera_y, minf(0, model.position.y - 425), minf(1, delta * 10))
	if is_instance_valid(dialogue):
		camera_x = model.rowan.position.x-550
		camera_y = 80
	for child in get_children():
		if child is Button and child not in skill_buttons:
			child.visible = paused and child.position.y < 100 and not is_instance_valid(dialogue) and not is_instance_valid(inventory_panel) and not is_instance_valid(skill_overview)
	for i in skill_buttons.size():
		var tile := skill_buttons[i]
		tile.cooldown = model.lineage_cooldowns[i]
		tile.cooldown_max = tile.skill.cooldown
		tile.mana_available = model.mana >= tile.skill.mana
		tile.locked = not model.progression.allows(tile.skill)
		tile.tooltip_text = "%s\n%s\n%s"%[tile.skill.name,tile.skill.description,model.progression.requirement_text(tile.skill)]
		tile.disabled = tile.locked or paused or model.health <= 0 or model.attack_time > 0 or model.guarding or tile.cooldown > 0 or not tile.mana_available
		tile.queue_redraw()
	avatar.position = model.position - Vector2(camera_x, camera_y + 8)+reaction.offset()
	rowan.position = model.rowan.position-Vector2(camera_x,camera_y)
	var npc_delta := delta if not paused or is_instance_valid(dialogue) else 0.0
	rowan.advance(npc_delta,model.rowan.walking,model.rowan.facing)
	rowan_balloon.position = rowan.position+Vector2(-119,-328)
	rowan_balloon.show_line(model.rowan.speech if not paused else "")
	talk_button.position = rowan.position+Vector2(-58,-250)
	talk_button.visible = false
	var direction: StringName = &"right" if model.facing > 0 else &"left"
	if avatar.facing != direction:
		avatar.set_facing(direction)
	avatar.modulate = reaction.tint()
	avatar.visible = model.health > 0
	if model.health > 0 and model.attack_time <= 0 and not paused:
		var pose := "guard" if model.guarding else ("air" if not model.grounded else ("run" if absf(model.velocity.x) > 20 else "idle"))
		if pose != last_pose:
			if pose == "run":
				avatar.play_motion(&"run")
			else:
				avatar.present_static_pose(pose)
			last_pose = pose
	resources.model = model
	resources.queue_redraw()
	feedback.camera = Vector2(camera_x, camera_y)
	monster_impacts.camera = Vector2(camera_x,camera_y)
	monster_impacts.queue_redraw()
	feedback.queue_redraw()
	hud.text = "%d coins" % model.inventory.coins
	guard_button.disabled = not model.can_guard
	guard_button.text = "GUARD\nShift / 2" if model.can_guard else "NO SHIELD"
	attack_button.disabled = model.weapon == "none"
	attack_button.text = "SPELL\nJ / 1 · 8 mana" if model.mana_cost() > 0 else "ATTACK\nJ / 1"
	hp_button.text = "HP ×%d · H" % model.inventory.potions.hp
	mana_button.text = "Mana ×%d · M" % model.inventory.potions.mana
	hp_button.disabled = paused or model.health <= 0 or model.health >= 100 or model.inventory.potions.hp == 0 or model.potion_cooldown > 0
	mana_button.disabled = paused or model.health <= 0 or model.mana >= 100 or model.inventory.potions.mana == 0 or model.potion_cooldown > 0
	notice.text = "Paused" if paused else ("Recovering · %.1fs" % model.death_time if model.health <= 0 else "")
	if is_instance_valid(dialogue): notice.text = ""
	skill_button.text = "POWER · %.1fs" % model.skill_cooldown if model.skill_cooldown > 0 else "POWER STRIKE\nK / 3 · 25 mana"
	skill_button.disabled = model.weapon == "none"
	queue_redraw()

func _save_progress() -> void:
	if Profiles.save(get_tree()) != OK: push_warning("Discipline progress could not be saved locally.")

func _exit_tree() -> void:
	_save_progress()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1152, 648), Color("82aea0"))
	draw_circle(Vector2(940 - camera_x * .08, 205), 65, Color("e9dca1"))
	for i in range(-2, 17):
		var x := i * 155.0 - fmod(camera_x * .28, 155)
		draw_line(Vector2(x, 470), Vector2(x + 22, 155), Color("618a7d"), 25)
		draw_circle(Vector2(x + 25, 180), 94, Color("71998a"))
		draw_circle(Vector2(x - 20, 120), 82, Color("71998a"))
	draw_set_transform(Vector2(-camera_x, -camera_y))
	draw_rect(Rect2(-400, 480, 2600, 248), Color("655f42"))
	draw_rect(Rect2(-400, 479, 2600, 12), Color("aec181"))
	for i in 75:
		var x := float(i * 31)
		draw_line(Vector2(x, 480), Vector2(x + 5, 469 - i % 5), Color("5c7e4c"), 2)
	for platform in Encounter.PLATFORMS:
		draw_style_box(_ledge_style(), platform)
		draw_line(platform.position, platform.position + Vector2(platform.size.x, 0), Color("d2d69c"), 5)
	_draw_rowan_stall()
	for enemy in model.enemies:
		_draw_enemy(enemy)
	for drop in model.loot:
		var at: Vector2 = drop.position + Vector2(0,-14)
		draw_circle(at, 15, Color("f2c45f"))
		draw_rect(Rect2(at - Vector2(9,8), Vector2(18,16)), Color("805839"))
		draw_line(at + Vector2(0,-8), at + Vector2(0,8), CREAM, 2)
	for projectile in model.projectiles:
		var point: Vector2 = projectile.position
		if model.weapon in ["staff", "branch_staff"]:
			draw_circle(point, 9 if projectile.power else 6, Color("a0efff"))
		else:
			draw_line(point - projectile.velocity.normalized() * 24, point, CREAM, 3)
			draw_circle(point, 3, Color("ddd5ba"))
	if model.guarding and model.health > 0:
		var center: Vector2 = model.position + Vector2(model.facing * 35, -85)
		draw_arc(center, 57, -1.3 if model.facing > 0 else 1.85, 1.3 if model.facing > 0 else 4.45, 24, Color("91eff3"), 5, true)
	if not model.is_ranged() and model.attack_kind == "power" and model.attack_time > .35 and model.attack_time < .5:
		draw_arc(model.position + Vector2(0, -55), 115, -1.3 if model.attack_facing > 0 else 1.85, 1.3 if model.attack_facing > 0 else 4.45, 30, Color("fff2a0"), 7, true)
	draw_set_transform(Vector2.ZERO)
	if paused or model.health <= 0:
		draw_rect(Rect2(0, 0, 1152, 648), Color(0, .05, .05, .35))

func _ledge_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("6a6849")
	style.set_corner_radius_all(5)
	return style

func _draw_rowan_stall() -> void:
	var at := Encounter.ROWAN_POSITION+Vector2(76,0)
	for x in [-20,110]: draw_line(at+Vector2(x,0),at+Vector2(x,-202),Color("59412b"),6)
	draw_colored_polygon(PackedVector2Array([at+Vector2(-34,-207),at+Vector2(118,-207),at+Vector2(142,-163),at+Vector2(-46,-163)]),Color("ad8650"))
	for i in 6:
		draw_line(at+Vector2(-25+i*28,-202),at+Vector2(-34+i*33,-166),Color("d2b575"),7,true)
	draw_rect(Rect2(at+Vector2(-17,-78),Vector2(121,78)),Color("634e35"))
	draw_rect(Rect2(at+Vector2(-23,-86),Vector2(135,10)),Color("b48e54"))
	for i in 4:
		var bottle := at+Vector2(4+i*24,-100)
		draw_circle(bottle,9,Color("9a513c") if i%2==0 else Color("427d99"))
		draw_rect(Rect2(bottle+Vector2(-3,-15),Vector2(6,9)),Color("c4b38a"))

func _draw_enemy(enemy: Dictionary) -> void:
	if enemy.hp <= 0:
		return
	var center := Vector2(enemy.x, 445)
	# Recoil belongs only to the painted monster; hitboxes and telegraphs stay put.
	if enemy.flash > 0:
		center.x += float(enemy.get("hit_direction",1))*sin(enemy.flash/.18*PI)*(5+int(enemy.get("hit_tier",0))*3)
	var radius := 46.0 if enemy.elite else 30.0
	var body := Color("9c6244") if enemy.elite else Color("8a8551")
	if enemy.flash > 0:
		body = CREAM
	if enemy.state == "windup":
		draw_circle(center, radius + 8, Color("f2cd70"))
		var remaining: float = enemy.timer / (1.05 if enemy.elite else .8)
		draw_rect(Rect2(enemy.x - 40, 365 - radius, 80 * remaining, 5), Color("ffd267"))
	if enemy.state == "strike":
		draw_line(center, center + Vector2(enemy.facing * 130, 0), Color("eb7154"), 13)
	for j in 3:
		var offset := Vector2(-radius + 12 + j * radius * .65, 0)
		draw_line(center + offset, Vector2(center.x + offset.x - 8, 479), INK, 7)
	draw_circle(center, radius + 3, INK)
	draw_circle(center, radius, body)
	for j in 3:
		var tip := center + Vector2(-radius * .65 + j * radius * .6, -radius + 8)
		draw_colored_polygon(PackedVector2Array([tip + Vector2(-9, 9), tip + Vector2(0, -18), tip + Vector2(12, 9)]), Color("526344"))
	var eye := center + Vector2(enemy.facing * radius * .6, -6)
	draw_circle(eye, 8, CREAM)
	draw_circle(eye + Vector2(enemy.facing * 3, 0), 4, INK)
	draw_rect(Rect2(enemy.x - 35, 388 - radius, 70, 5), INK)
	draw_rect(Rect2(enemy.x - 35, 388 - radius, 70 * enemy.hp / enemy.max_hp, 5), Color("c8d794"))
	var title := "ELDER BRIAR · ELITE" if enemy.elite else "BRIAR CRAWLER"
	draw_string(ThemeDB.fallback_font, Vector2(enemy.x - 64, 380 - radius), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, INK)
