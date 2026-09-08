extends Node2D
## Local gameplay experiment, separate from the character-builder entry point.

const Encounter := preload("res://prototypes/training_clearing/encounter.gd")
const Avatar := preload("res://prototypes/training_clearing/vanguard_visual.gd")
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
var floaters: Array[Dictionary] = []
var hud: Label
var objective: Label
var notice: Label
var skill_button: Button
var last_pose := ""

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
	model.facing = -1.0 if selection.get("facing", &"right") == &"left" else 1.0
	avatar.scale = Vector2.ONE * .69
	_build_ui()
	get_window().focus_exited.connect(_lose_focus)
	_update_view(0)

func _build_ui() -> void:
	var title := _label("THE FIRST CLEARING", Vector2(26, 18), 26)
	title.add_theme_color_override("font_color", CREAM)
	_label("%s  /  %s + %s" % [CharacterCatalog.race(avatar.race_id).name.to_upper(), model.weapon.to_upper(), String(avatar.loadout.offhand).to_upper()], Vector2(28, 50), 12)
	hud = _label("", Vector2(28, 81), 17)
	objective = _label("", Vector2(28, 115), 15)
	notice = _label("", Vector2(28, 149), 15)
	_button("Builder", Vector2(1010, 20), Vector2(112, 38)).pressed.connect(func(): get_tree().change_scene_to_file("res://main.tscn"))
	_button("Pause · Esc", Vector2(872, 20), Vector2(128, 38)).pressed.connect(_toggle_pause)
	_button("Restart · R", Vector2(872, 66), Vector2(128, 38)).pressed.connect(_restart)
	var left := _button("←", Vector2(26, 548), Vector2(82, 70))
	left.button_down.connect(func(): touch_left = true)
	left.button_up.connect(func(): touch_left = false)
	var right := _button("→", Vector2(118, 548), Vector2(82, 70))
	right.button_down.connect(func(): touch_right = true)
	right.button_up.connect(func(): touch_right = false)
	_button("JUMP\nSpace", Vector2(226, 548), Vector2(105, 70)).pressed.connect(_jump)
	var guard := _button("GUARD\nHold Shift / 2", Vector2(712, 548), Vector2(125, 70))
	guard.disabled = not model.can_guard
	if not model.can_guard:
		guard.text = "NO SHIELD"
	guard.button_down.connect(func(): touch_guard = true)
	guard.button_up.connect(func(): touch_guard = false)
	var attack_button := _button("ATTACK\nJ / 1", Vector2(847, 548), Vector2(125, 70))
	attack_button.disabled = model.weapon == "none"
	attack_button.pressed.connect(_attack.bind(false))
	skill_button = _button("", Vector2(982, 548), Vector2(144, 70))
	skill_button.pressed.connect(_attack.bind(true))
	_label("A / D or arrows to move   •   Gold = warning   •   Red = strike   •   Guard faces your enemy", Vector2(26, 628), 12)

func _label(value: String, at: Vector2, size: int) -> Label:
	var label := Label.new()
	label.z_index = 200
	label.text = value
	label.position = at
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color("dae4c7"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _button(value: String, at: Vector2, dimensions: Vector2) -> Button:
	var button := Button.new()
	button.z_index = 200
	button.text = value
	button.position = at
	button.size = dimensions
	button.focus_mode = Control.FOCUS_NONE
	var style := StyleBoxFlat.new()
	style.bg_color = Color("294c48")
	style.border_color = Color("91ad85")
	style.set_border_width_all(1)
	style.set_corner_radius_all(9)
	button.add_theme_stylebox_override("normal", style)
	var pressed := style.duplicate()
	pressed.bg_color = Color("627c51")
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_color_override("font_color", CREAM)
	add_child(button)
	return button

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.physical_keycode:
		KEY_SPACE, KEY_W, KEY_UP: _jump()
		KEY_J, KEY_1: _attack(false)
		KEY_K, KEY_3: _attack(true)
		KEY_ESCAPE: _toggle_pause()
		KEY_R: _restart()

func _input(event: InputEvent) -> void:
	# Track each finger independently instead of relying on single-mouse emulation.
	if event is InputEventScreenTouch:
		if not event.pressed:
			fingers.erase(event.index)
		else:
			var local: Vector2 = (event.position - position) / scale
			if Rect2(26, 548, 82, 70).has_point(local):
				fingers[event.index] = "left"
			elif Rect2(118, 548, 82, 70).has_point(local):
				fingers[event.index] = "right"
			elif Rect2(712, 548, 125, 70).has_point(local):
				fingers[event.index] = "guard"
			elif Rect2(226, 548, 105, 70).has_point(local):
				_jump()
			elif Rect2(847, 548, 125, 70).has_point(local):
				_attack(false)
			elif Rect2(982, 548, 144, 70).has_point(local):
				_attack(true)
			else:
				return
		touch_left = "left" in fingers.values()
		touch_right = "right" in fingers.values()
		touch_guard = "guard" in fingers.values()
		get_viewport().set_input_as_handled()

func _jump() -> void:
	if not paused:
		model.jump()

func _attack(power: bool) -> void:
	if not paused and model.begin_attack(power):
		avatar.play_weapon_attack(model.attack_animation())
		last_pose = "attack"

func _toggle_pause() -> void:
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
	var selected_facing: float = model.facing
	model = Encounter.new()
	model.configure_equipment(avatar.loadout)
	model.facing = selected_facing
	floaters.clear()
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

func _physics_process(delta: float) -> void:
	if not paused:
		var direction := float(touch_right or Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(touch_left or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
		model.step(delta, direction, touch_guard or Input.is_physical_key_pressed(KEY_SHIFT) or Input.is_physical_key_pressed(KEY_2))
		for event in model.events:
			floaters.append({"text": event.text, "position": event.position, "life": 1.0})
		for floater in floaters:
			floater.life -= delta
			floater.position.y -= delta * 30
		floaters = floaters.filter(func(item): return item.life > 0)
	_update_view(delta)

func _update_view(delta: float) -> void:
	var viewport_size := get_viewport_rect().size
	var factor := minf(viewport_size.x / 1152.0, viewport_size.y / 648.0)
	scale = Vector2.ONE * factor
	position = (viewport_size - Vector2(1152, 648) * factor) * .5
	camera_x = lerpf(camera_x, clampf(model.position.x - 430, 0, 1048), minf(1, delta * 8))
	camera_y = lerpf(camera_y, minf(0, model.position.y - 425), minf(1, delta * 10))
	avatar.position = model.position - Vector2(camera_x, camera_y + 8)
	var direction: StringName = &"right" if model.facing > 0 else &"left"
	if avatar.facing != direction:
		avatar.set_facing(direction)
	avatar.modulate = Color("ffffff") if model.invulnerable <= 0 else Color("aadce0")
	avatar.visible = model.health > 0
	if model.health > 0 and model.attack_time <= 0 and not paused:
		var pose := "guard" if model.guarding else ("air" if not model.grounded else ("run" if absf(model.velocity.x) > 20 else "idle"))
		if pose != last_pose:
			if pose == "run":
				avatar.play_motion(&"run")
			else:
				avatar.present_static_pose(pose)
			last_pose = pose
	hud.text = "HEALTH %d / 100    STAMINA %d / 100    DEFEATED %d / 3    BLOCKS %d" % [model.health, model.stamina, model.kills, model.blocks]
	objective.text = "Practice: %s Move     %s Jump     %s     %s Defeat two enemies" % [_mark(model.moved), _mark(model.jumped), (_mark(model.blocks > 0) + " Block a hit") if model.can_guard else "No shield: evade attacks", _mark(model.kills >= 2)]
	notice.text = "PAUSED — Esc or Pause to resume" if paused else ("Defeated — recovering here in %.1fs" % model.death_time if model.health <= 0 else ("Clearing complete! Optional: follow the trail to the Elder Briar. R to try again." if model.complete() else "Let an enemy wind up, face it, and hold Guard. Power Strike costs 25 stamina."))
	if model.elite_defeated and model.complete():
		notice.text = "All challenges complete. How did the timing feel? Restart to try a different approach."
	skill_button.text = "POWER · %.1fs" % model.skill_cooldown if model.skill_cooldown > 0 else "POWER STRIKE\nK / 3 · 25 stamina"
	skill_button.disabled = model.weapon == "none"
	if not paused and model.health > 0 and not model.complete():
		notice.text = "No weapon equipped — return to Builder to choose one." if model.weapon == "none" else "Your exact builder equipment is active. J attacks; K powers up the selected weapon."
	queue_redraw()

func _mark(done: bool) -> String:
	return "✓" if done else "○"

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1152, 648), Color("82aea0"))
	draw_circle(Vector2(940 - camera_x * .08, 205), 65, Color("e9dca1"))
	for i in range(-2, 17):
		var x := i * 155.0 - fmod(camera_x * .28, 155)
		draw_line(Vector2(x, 470), Vector2(x + 22, 155), Color("618a7d"), 25)
		draw_circle(Vector2(x + 25, 180), 94, Color("71998a"))
		draw_circle(Vector2(x - 20, 120), 82, Color("71998a"))
	draw_set_transform(Vector2(-camera_x, -camera_y))
	draw_rect(Rect2(0, 480, 2200, 168), Color("655f42"))
	draw_rect(Rect2(0, 479, 2200, 12), Color("aec181"))
	for i in 75:
		var x := float(i * 31)
		draw_line(Vector2(x, 480), Vector2(x + 5, 469 - i % 5), Color("5c7e4c"), 2)
	for platform in Encounter.PLATFORMS:
		draw_style_box(_ledge_style(), platform)
		draw_line(platform.position, platform.position + Vector2(platform.size.x, 0), Color("d2d69c"), 5)
	_sign(Vector2(110, 447), "PRACTICE GROVE")
	_sign(Vector2(945, 447), "JUMP TO THE LEDGES")
	_sign(Vector2(1650, 447), "OPTIONAL ELITE →")
	for enemy in model.enemies:
		_draw_enemy(enemy)
	for projectile in model.projectiles:
		var point: Vector2 = projectile.position
		if model.weapon in ["staff", "branch_staff"]:
			draw_circle(point, 9 if projectile.power else 6, Color("a0efff"))
		else:
			draw_line(point - Vector2(projectile.direction * 24, 0), point, CREAM, 3)
			draw_circle(point, 3, Color("ddd5ba"))
	if model.guarding and model.health > 0:
		var center: Vector2 = model.position + Vector2(model.facing * 35, -85)
		draw_arc(center, 57, -1.3 if model.facing > 0 else 1.85, 1.3 if model.facing > 0 else 4.45, 24, Color("91eff3"), 5, true)
	if not model.is_ranged() and model.attack_kind == "power" and model.attack_time > .35 and model.attack_time < .5:
		draw_arc(model.position + Vector2(0, -55), 115, -1.3 if model.attack_facing > 0 else 1.85, 1.3 if model.attack_facing > 0 else 4.45, 30, Color("fff2a0"), 7, true)
	for floater in floaters:
		draw_string(ThemeDB.fallback_font, floater.position, floater.text, HORIZONTAL_ALIGNMENT_CENTER, -1, 23, Color(1, 1, .8, floater.life))
	draw_set_transform(Vector2.ZERO)
	draw_rect(Rect2(0, 0, 1152, 187), Color(.06, .15, .15, .91))
	draw_rect(Rect2(0, 530, 1152, 118), Color("182f30"))
	if paused or model.health <= 0:
		draw_rect(Rect2(0, 187, 1152, 343), Color(0, .05, .05, .35))

func _ledge_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("6a6849")
	style.set_corner_radius_all(5)
	return style

func _sign(at: Vector2, title: String) -> void:
	draw_line(at, at + Vector2(0, 33), Color("615238"), 5)
	draw_rect(Rect2(at - Vector2(74, 28), Vector2(160, 30)), Color("ece0b6"))
	draw_string(ThemeDB.fallback_font, at + Vector2(-67, -8), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, INK)

func _draw_enemy(enemy: Dictionary) -> void:
	if enemy.hp <= 0:
		return
	var center := Vector2(enemy.x, 445)
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
