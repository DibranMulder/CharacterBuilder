extends Node2D
const Duel = preload("res://prototypes/sparring_arena/duel.gd")
const Avatar = preload("res://prototypes/training_clearing/vanguard_visual.gd")
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
const Reaction = preload("res://src/ui/combat_reaction.gd")
var reactions := [Reaction.new(),Reaction.new()]
var bindings = preload("res://src/action_bindings.gd").new()
var bindings_panel: Control
var paused_before_bindings := false
var model = Duel.new()
var selection: Dictionary
var opponent := "goblin"
var difficulty := 1
var avatars: Array[Node2D] = []
var huds: Array[Node2D] = []
var skill_buttons: Array[Button] = []
var skill_overview: Control
var paused_before_skills := false
var feedback := preload("res://prototypes/training_clearing/combat_overlay.gd").new()
var effects: Array[Dictionary] = []
var last_serial := [-1,-1]
var poses := ["",""]
var paused := false
var held := {"left":false,"right":false,"guard":false}
var title: Label
var result: Label
var pause_button: Button
var attack_button: Button
var guard_button: Button
var status: Label
var opponent_selector: OptionButton
var opponents: Array[String] = []
var message_time := 0.0
var time := 0.0

func _ready() -> void:
	selection = get_tree().get_meta("training_character",{"lineage":"human","loadout":CharacterCatalog.reference_loadout("human"),"facing":&"right"}).duplicate(true)
	bindings.load_for(selection.lineage)
	for id in CharacterCatalog.race_ids():
		if id != selection.lineage: opponents.append(id)
	opponent = opponents[0] if not opponent in opponents else opponent
	add_child(feedback)
	for i in 2:
		var avatar := Avatar.new()
		avatar.z_index = 100+i
		avatar.scale = Vector2.ONE*.72
		add_child(avatar)
		avatars.append(avatar)
		var hud := preload("res://prototypes/training_clearing/resource_hud.gd").new()
		hud.show_guard = false
		hud.position.x = 820*i
		add_child(hud)
		huds.append(hud)
	_build_ui()
	rematch()
	get_window().focus_exited.connect(func(): _set_paused(true))

func _button(text: String, at: Vector2, size: Vector2, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = at
	button.size = size
	button.theme = Chronicle.create()
	button.theme_type_variation = &"QuietButton"
	button.focus_mode = Control.FOCUS_NONE
	button.z_index = 210
	button.pressed.connect(action)
	add_child(button)
	return button

func _label(at: Vector2, size: Vector2, heading := false) -> Label:
	var label := Label.new()
	label.position = at
	label.size = size
	label.theme = Chronicle.create()
	if heading: label.theme_type_variation = &"ChronicleHeading"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 210
	add_child(label)
	return label

func _build_ui() -> void:
	title = _label(Vector2(355,18),Vector2(442,38),true)
	title.text = "THE PROVING RING"
	var subtitle := _label(Vector2(350,57),Vector2(452,24))
	subtitle.text = "Local sparring · same rules, different lineages"
	opponent_selector = OptionButton.new()
	opponent_selector.position = Vector2(365,91)
	opponent_selector.size = Vector2(245,34)
	opponent_selector.theme = Chronicle.create()
	opponent_selector.z_index = 210
	for id in opponents: opponent_selector.add_item(CharacterCatalog.race(id).name)
	opponent_selector.select(opponents.find(opponent))
	opponent_selector.item_selected.connect(func(index): opponent = opponents[index]; rematch())
	add_child(opponent_selector)
	var level := OptionButton.new()
	level.position = Vector2(620,91)
	level.size = Vector2(165,34)
	level.theme = Chronicle.create()
	level.z_index = 210
	for text in ["Learning bot","Sparring bot","Veteran bot"]: level.add_item(text)
	level.select(1)
	level.item_selected.connect(func(index): difficulty = index; rematch())
	add_child(level)
	_button("Bindings · B",Vector2(800,136),Vector2(130,32),_toggle_bindings)
	_button("Builder",Vector2(365,136),Vector2(92,32),_builder)
	_button("Rematch · R",Vector2(463,136),Vector2(112,32),rematch)
	_button("Skills · L",Vector2(581,136),Vector2(96,32),_toggle_skills)
	pause_button = _button("Pause · Esc",Vector2(683,136),Vector2(112,32),func(): _set_paused(not paused))
	result = _label(Vector2(280,191),Vector2(592,42),true)
	status = _label(Vector2(245,500),Vector2(660,30))
	var left := _button("←  A",Vector2(18,554),Vector2(73,62),func(): pass)
	var right := _button("D  →",Vector2(98,554),Vector2(73,62),func(): pass)
	var jump := _button("JUMP\nSpace",Vector2(180,554),Vector2(92,62),_jump)
	jump.tooltip_text = "Jump over strikes and projectiles."
	attack_button = _button("ATTACK\nJ / 1",Vector2(280,554),Vector2(110,62),func(): _attack(-1))
	guard_button = _button("GUARD\nShift / 2",Vector2(398,554),Vector2(108,62),func(): pass)
	for pair in [[left,"left"],[right,"right"],[guard_button,"guard"]]:
		pair[0].button_down.connect(func(): held[pair[1]] = true)
		pair[0].button_up.connect(func(): held[pair[1]] = false)
	for i in 6:
		var button := preload("res://src/ui/skill_tile.gd").new()
		button.position = Vector2(112+i*52,116)
		button.size = Vector2(48,70)
		button.z_index = 210
		button.pressed.connect(_attack.bind(i))
		add_child(button)
		skill_buttons.append(button)

func rematch() -> void:
	reactions = [Reaction.new(),Reaction.new()]
	model = Duel.new()
	model.configure(selection.lineage,selection.loadout,opponent,difficulty)
	last_serial = [-1,-1]
	poses = ["",""]
	feedback.reset()
	effects.clear()
	_set_paused(false)
	status.text = ""
	message_time = 0
	for i in 2:
		var fighter = model.fighters[i]
		avatars[i].configure(fighter.lineage,fighter.loadout)
		avatars[i].scale = Vector2.ONE*(.62 if fighter.lineage == "frost_troll" else .72)
		huds[i].model = fighter
		huds[i].player_name = CharacterCatalog.race(fighter.lineage).name
		huds[i].set_character(fighter.lineage,fighter.loadout)
	for i in skill_buttons.size():
		var skill: Dictionary = model.fighters[0].skills[i]
		skill_buttons[i].configure(skill,str(i+3))
	_update_view()

func _set_paused(value: bool) -> void:
	paused = value
	held = {"left":false,"right":false,"guard":false}
	for avatar in avatars: avatar.process_mode = Node.PROCESS_MODE_DISABLED if paused else Node.PROCESS_MODE_INHERIT
	if pause_button: pause_button.text = "Resume · Esc" if paused else "Pause · Esc"

func _builder() -> void:
	get_tree().set_meta("training_character",selection.duplicate(true))
	get_tree().change_scene_to_file("res://main.tscn")

func _toggle_skills() -> void:
	if is_instance_valid(bindings_panel): return
	if is_instance_valid(skill_overview):
		skill_overview.queue_free()
		skill_overview = null
		_set_paused(paused_before_skills)
		return
	paused_before_skills = paused
	_set_paused(true)
	skill_overview = preload("res://src/ui/skill_overview.gd").new()
	skill_overview.bindings = bindings
	skill_overview.lineage = selection.lineage
	skill_overview.progression = preload("res://src/discipline_profiles.gd").get_profile(get_tree(),selection.lineage)
	skill_overview.sandbox = true
	skill_overview.combat_model = model.fighters[0]
	skill_overview.show_pouch = false
	skill_overview.closed.connect(_toggle_skills)
	add_child(skill_overview)

func _jump() -> void:
	if not paused and model.countdown <= 0 and model.winner < 0: model.fighters[0].jump()

func _attack(slot: int) -> void:
	if paused: return
	if not model.request(slot) and not model.fighters[0].rejection.is_empty():
		status.text = model.fighters[0].rejection
		message_time = 1.5

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	if is_instance_valid(bindings_panel):
		if event.physical_keycode in [KEY_B,KEY_ESCAPE]: _toggle_bindings()
		return
	if is_instance_valid(skill_overview):
		if event.physical_keycode in [KEY_ESCAPE,KEY_L]: _toggle_skills()
		return
	if event.physical_keycode in bindings.KEYS:
		var action: String = bindings.action_for(event.physical_keycode)
		if action == "attack": _attack(-1)
		elif action.begins_with("skill:"): _attack(int(action.get_slice(":",1)))
		return
	match event.physical_keycode:
		KEY_B: _toggle_bindings()
		KEY_L: _toggle_skills()
		KEY_ESCAPE: _set_paused(not paused)
		KEY_R: rematch()
		KEY_SPACE,KEY_UP: _jump()
		KEY_J: _attack(-1)
		KEY_7: _attack(4)
		KEY_8: _attack(5)

func _physics_process(delta: float) -> void:
	if not paused:
		for reaction in reactions: reaction.advance(delta)
		time += delta
		var direction := float(held.right or Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))-float(held.left or Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
		for i in 2: model.muzzles[i] = to_local(avatars[i].skill_projectile_socket(model.fighters[i].action))
		model.step(delta,direction,held.guard or Input.is_physical_key_pressed(KEY_SHIFT) or bindings.held("guard"))
		for event in model.events:
			if event.kind == "effect":
				event.age = 0.0
				effects.append(event)
			else:
				feedback.push(event)
				if event.has("target"): reactions[event.target].receive(event)
		feedback.advance(delta)
		for effect in effects: effect.age += delta
		effects = effects.filter(func(effect): return effect.age < .55)
		message_time = maxf(0,message_time-delta)
	_update_view()

func _update_view() -> void:
	for child in get_children():
		if child is BaseButton and child not in skill_buttons:
			child.visible = paused and child.position.y < 190 and not is_instance_valid(skill_overview) and not is_instance_valid(bindings_panel)
	var viewport := get_viewport_rect().size
	var factor := minf(viewport.x/1152,viewport.y/648)
	scale = Vector2.ONE*factor
	position = (viewport-Vector2(1152,648)*factor)*.5
	for i in 2:
		var fighter = model.fighters[i]
		var avatar = avatars[i]
		avatar.position = fighter.position-Vector2(0,8)+reactions[i].offset()
		avatar.set_facing(&"right" if fighter.facing > 0 else &"left")
		avatar.modulate = reactions[i].tint()
		if fighter.serial != last_serial[i] and not fighter.action.is_empty():
			last_serial[i] = fighter.serial
			avatar.present_arena_action(fighter.action,fighter.attack_animation())
			poses[i] = "attack"
		if fighter.action.is_empty() or model.winner >= 0:
			var pose := "guard" if fighter.guarding else ("air" if not fighter.grounded else ("run" if absf(fighter.velocity.x) > 10 and model.winner < 0 else "idle"))
			if pose != poses[i]:
				if pose == "run": avatar.play_motion(&"run")
				else: avatar.present_static_pose(pose)
				poses[i] = pose
		if model.winner >= 0: avatar.process_mode = Node.PROCESS_MODE_DISABLED
		huds[i].queue_redraw()
	var player = model.fighters[0]
	for i in skill_buttons.size():
		var skill: Dictionary = player.skills[i]
		var cooldown: float = player.cooldowns[i]
		skill_buttons[i].hotkey = bindings.label_for("skill:%d" % i)
		skill_buttons[i].visible = not is_instance_valid(bindings_panel) and not is_instance_valid(skill_overview)
		skill_buttons[i].cooldown = cooldown
		skill_buttons[i].cooldown_max = skill.cooldown
		skill_buttons[i].mana_available = player.mana >= skill.mana
		skill_buttons[i].disabled = paused or model.countdown > 0 or model.winner >= 0 or cooldown > 0 or player.mana < skill.mana or not player.action.is_empty()
		skill_buttons[i].queue_redraw()
	attack_button.text = "ATTACK\nJ " + bindings.label_for("attack")
	attack_button.disabled = paused or model.countdown > 0 or model.winner >= 0 or player.loadout.weapon == "none"
	guard_button.disabled = not player.can_guard() or paused or model.winner >= 0
	guard_button.text = "GUARD %d\nShift %s"%[player.stamina,bindings.label_for("guard")] if player.can_guard() else "NO SHIELD"
	result.text = "Paused" if paused else ("Ready · %d"%ceili(model.countdown) if model.countdown > 0 else "")
	if model.winner >= 0:
		result.text = ["Victory","Defeat","Draw"][model.winner]+" · %.1fs · R to rematch"%model.elapsed
		status.text = "Damage dealt %d  ·  Damage taken %d"%[player.dealt,player.received]
	elif message_time <= 0:
		status.text = "ROOTED" if player.rooted > 0 else ("SLOWED" if player.slow > 0 else ("WARD %d"%player.ward if player.ward > 0 else ""))
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(0,0,1152,648),Color("142f37"))
	for i in 12:
		var x := i*110-20
		draw_line(Vector2(x,150),Vector2(x+25,470),Color("234648"),22)
		draw_circle(Vector2(x,215+(i%3)*30),90,Color("244749"))
	draw_rect(Rect2(0,366,1152,104),Color("3c5150"))
	for i in 12:
		draw_rect(Rect2(i*102,366,96,32),Color("56665e"))
	for x in [38,1114]:
		draw_rect(Rect2(x-24,165,48,305),Color("626c5c"))
		draw_rect(Rect2(x-31,159,62,18),Color("a19977"))
		draw_rect(Rect2(x-29,452,58,18),Color("a19977"))
		var flame := Vector2(x,290)
		draw_circle(flame,24+sin(time*5)*2,Color(1,.7,.28,.12))
		draw_line(flame+Vector2(0,42),flame,Color("614932"),8)
		draw_colored_polygon(PackedVector2Array([flame+Vector2(-8,9),flame+Vector2(0,-19),flame+Vector2(9,9)]),Color("eeb25a"))
	draw_rect(Rect2(0,470,1152,178),Color("444b43"))
	draw_line(Vector2(0,470),Vector2(1152,470),Color("b9b18a"),5)
	for row in 3:
		for col in 10:
			draw_rect(Rect2(col*132-(66 if row%2 else 0),479+row*54,127,48),Color("565e50"),false,2)
	draw_set_transform(Vector2(576,489),0,Vector2(1,.12))
	draw_arc(Vector2.ZERO,130,0,TAU,64,Color("b8a16a"),2,true)
	draw_set_transform(Vector2.ZERO)
	var font: Font = Chronicle.create().default_font
	for i in model.fighters.size():
		var fighter = model.fighters[i]
		if fighter.ward > 0: draw_arc(fighter.position+Vector2(0,-72),75,0,TAU,48,Color("8bbec8"),2,true)
		if fighter.rooted > 0: draw_arc(fighter.position-Vector2(0,5),30,0,TAU,24,Color("9cdac0"),4,true)
		if not fighter.action.is_empty() and not fighter.released:
			var at: Vector2 = fighter.position+Vector2(-75,-225)
			draw_style_box(Chronicle.create().get_stylebox("panel","InkPanel"),Rect2(at,Vector2(150,37)))
			draw_string(font,at+Vector2(9,20),fighter.action.name,0,132,14,Chronicle.IVORY)
			draw_rect(Rect2(at+Vector2(5,29),Vector2(140*minf(1,fighter.action_time/fighter.action.windup),3)),Chronicle.GOLD)
	for shot in model.projectiles:
		var color := Color("a8dbe7") if shot.kind in ["slowbolt","rootbolt"] else Chronicle.GOLD
		draw_line(shot.position-shot.velocity.normalized()*22,shot.position,color,4,true)
		draw_circle(shot.position,5,Chronicle.IVORY)
	for effect in effects:
		var color: Color = CharacterCatalog.race(model.fighters[effect.owner].lineage).accent.lightened(.35)
		color.a = 1-effect.age/.55
		var radius: float = 22+effect.age*190
		draw_arc(effect.position,radius,0,TAU,48,color,3,true)
		if effect.effect in ["dash","retreat"]:
			draw_line(effect.position,model.fighters[effect.owner].position-Vector2(0,65),color,5,true)

func _toggle_bindings() -> void:
	if is_instance_valid(bindings_panel):
		bindings_panel.queue_free()
		bindings_panel = null
		_set_paused(paused_before_bindings)
		return
	if is_instance_valid(skill_overview): return
	paused_before_bindings = paused
	_set_paused(true)
	bindings_panel = preload("res://src/ui/action_bindings_panel.gd").new()
	bindings_panel.bindings = bindings
	bindings_panel.kit = model.fighters[0].skills
	bindings_panel.closed.connect(_toggle_bindings)
	add_child(bindings_panel)
	bindings_panel.status.text = "Potions are unavailable in sparring. Assignments also apply outside the arena."
