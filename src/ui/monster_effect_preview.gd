extends Node2D
## Isolated presentation sandbox: fixed poses, no XP, damage, or saved equipment.
const Impact = preload("res://src/monster_impact.gd")
const Avatar = preload("res://prototypes/training_clearing/vanguard_visual.gd")
const CASES := [
	["Crosscut","human","sword","crosscut","Two crossing cuts bloom on the monster."],
	["Blade Rhythm","human","sword","slash","Layered ivory cuts, a gold impact ring, and trailing sparks."],
	["Pursuing Hew","frost_troll","axe","earth","Stone slabs rise beneath the monster, then crumble into earth chips."],
	["Siege Volley","goblin","crossbow","rain","A shower of bolts descends onto the monster from above."],
	["Winter Halo","frostling","staff","ice","Ice facets burst around the target with drifting crystal fragments."],
	["Cyclone","fae","staff","wind","Wind ribbons coil around the monster and shed bright motes."],
]
var avatar: Node2D
var impacts := Impact.new()
var technique: OptionButton
var intensity: OptionButton
var description: Label
var current := 2
var tier := 1
var target := Vector2(805,490)
var age := 10.0
var running := false
var emitted := false
var mirrored := false
var release := .43
var recoil := 0.0
var playback: Button

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("142534"))
	_label("MONSTER EFFECTS",Vector2(30,24),30,Color("efbd62"))
	_label("A stronger impact at every milestone",Vector2(31,66),17,Color("b9cbd1"))
	_button("Back to builder",Vector2(946,24),Vector2(177,38),func(): get_tree().change_scene_to_file("res://main.tscn"))
	_label("TECHNIQUE",Vector2(30,149),14,Color("8fbab8"))
	technique = OptionButton.new()
	technique.position = Vector2(30,178)
	technique.size = Vector2(266,40)
	for entry in CASES: technique.add_item(entry[0])
	technique.select(current)
	technique.item_selected.connect(_select)
	add_child(technique)
	_label("EFFECT MILESTONE",Vector2(30,245),14,Color("8fbab8"))
	intensity = OptionButton.new()
	intensity.position = Vector2(30,274)
	intensity.size = Vector2(266,40)
	for value in ["Level 1 · Contact","Level 30 · Impact","Level 75+ · Spectacle"]: intensity.add_item(value)
	intensity.select(tier)
	intensity.item_selected.connect(func(index): tier=index; _stop())
	add_child(intensity)
	description = _label("",Vector2(30,337),17,Color("d5ddd7"))
	description.size = Vector2(266,100)
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	playback = _button("Play impact · Space",Vector2(30,448),Vector2(266,44),play)
	_button("Stop",Vector2(30,502),Vector2(125,36),_stop)
	_button("Mirror",Vector2(168,502),Vector2(128,36),func(): mirrored=not mirrored; _select(current))
	var reduced := CheckButton.new()
	reduced.text = "Reduced effects"
	reduced.position = Vector2(30,553)
	reduced.toggled.connect(func(value): impacts.reduced_effects=value)
	add_child(reduced)
	_label("Visual sandbox · no damage or XP",Vector2(350,596),15,Color("93a7ad"))
	_label("Compare tiers using the same attack pose.",Vector2(350,620),13,Color("93a7ad"))
	avatar = Avatar.new()
	avatar.z_index = 10
	avatar.scale = Vector2.ONE*.83
	add_child(avatar)
	impacts.z_index = 20
	add_child(impacts)
	_select(current)

func _label(value: String, at: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.position = at
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	add_child(label)
	return label

func _button(value: String, at: Vector2, dimensions: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text=value
	button.position=at
	button.size=dimensions
	button.pressed.connect(callback)
	add_child(button)
	return button

func _select(index: int) -> void:
	_stop()
	current=index
	technique.select(index)
	var entry: Array = CASES[index]
	var loadout := CharacterCatalog.reference_loadout(entry[1])
	loadout.weapon=entry[2]
	if entry[2] in ["crossbow","staff"]: loadout.offhand="none"
	avatar.configure(entry[1],loadout)
	avatar.set_facing(&"left" if mirrored else &"right")
	var ranged: bool = entry[2] in ["crossbow","staff"]
	avatar.position=Vector2(985 if ranged else 850,490) if mirrored else Vector2(460 if ranged else 640,490)
	avatar.position.y-=float({"human":10,"frost_troll":20,"goblin":15,"frostling":19,"fae":0}.get(entry[1],0))
	target=Vector2(665 if mirrored else 805,490)
	description.text=entry[4]
	release=.43 if entry[2]=="axe" else (.6 if ranged else .39)
	queue_redraw()

func play() -> void:
	_stop()
	running=true
	age=0
	var weapon: String = CASES[current][2]
	avatar.play_weapon_attack(&"fire_crossbow" if weapon=="crossbow" else (&"cast_spell" if weapon=="staff" else &"forehand"))

func _stop() -> void:
	running=false
	emitted=false
	age=10
	recoil=0
	impacts.reset()
	if is_instance_valid(avatar): avatar.stop_motion()
	queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode==KEY_SPACE: play(); get_viewport().set_input_as_handled()
		if event.physical_keycode==KEY_ESCAPE: _stop()

func _process(delta: float) -> void:
	impacts.advance(delta)
	recoil=maxf(0,recoil-delta)
	if running:
		age+=delta
		if age>=release and not emitted:
			emitted=true
			recoil=.28
			impacts.push({"kind":"power","effect":CASES[current][3],"tier":tier,"foot":target,"direction":-1 if mirrored else 1})
		if age>release+1.5: running=false
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(16,130,298,451),Color("1b3241"))
	for i in 7:
		var x := 354+i*119.0
		draw_rect(Rect2(x,152,15,340),Color("213c44"))
		draw_circle(Vector2(x+6,184),70,Color("213c44"))
	draw_rect(Rect2(330,492,800,84),Color("3c4843"))
	draw_line(Vector2(330,491),Vector2(1130,491),Color("9b9b72"),4)
	for i in 10: draw_line(Vector2(340+i*83,502),Vector2(340+i*83,574),Color("536054"),2)
	var shift := sin(recoil/.28*PI)*(5+tier*4)*(-1 if mirrored else 1)
	var center := target+Vector2(shift,-37)
	draw_circle(center+Vector2(0,36),35,Color(.08,.12,.12,.25))
	for i in 4:
		var x := -29+i*19
		draw_line(center+Vector2(x,10),target+Vector2(x+shift-7,0),Color("233126"),7,true)
	draw_circle(center,39,Color("203328"))
	draw_circle(center,35,Color("c0af72") if recoil>.19 else Color("86915c"))
	for i in 4:
		var p := center+Vector2(-28+i*17,-24)
		draw_colored_polygon(PackedVector2Array([p+Vector2(-8,4),p+Vector2(0,-19),p+Vector2(10,4)]),Color("53694c"))
	var eye := center+Vector2(19 if mirrored else -19,-5)
	draw_circle(eye,10,Color("f8eac0"))
	draw_circle(eye+Vector2(3 if mirrored else -3,0),5,Color("203328"))
	draw_rect(Rect2(target+Vector2(-45,-105),Vector2(90,6)),Color("233126"))
	draw_rect(Rect2(target+Vector2(-44,-104),Vector2(88,4)),Color("b8cc87"))
	draw_string(ThemeDB.fallback_font,target+Vector2(-59,-119),"BRIAR CRAWLER",HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("d6debf"))
	if running and CASES[current][2] in ["crossbow","staff"] and age>.38 and age<release:
		var p := to_local(avatar.projectile_socket()).lerp(target+Vector2(0,-40),clampf((age-.38)/(release-.38),0,1))
		draw_line(p-Vector2(30*(-1 if mirrored else 1),0),p,Color("ffebae"),3,true)
