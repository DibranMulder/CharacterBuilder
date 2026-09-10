extends Control
signal closed
signal pouch_requested
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
const Skills = preload("res://prototypes/sparring_arena/lineage_skills.gd")
const Tile = preload("res://src/ui/skill_tile.gd")
var lineage := "human"
var selected_lineage := "human"
var show_pouch := true
var progression
var combat_model
var sandbox := false
var discipline_panel: Control
var selected_slot := 0
var cards: Array[Button] = []
var tiles: Array[Button] = []
var names: Array[Label] = []
var summaries: Array[Label] = []
var lineage_buttons := {}
var heading: Label
var detail_name: Label
var detail_text: Label
var values: Label
var detail_icon: Button

func _ready() -> void:
	size = Vector2(1152,648)
	z_index = 300
	mouse_filter = Control.MOUSE_FILTER_STOP
	theme = Chronicle.create()
	selected_lineage = lineage
	if progression == null: progression = preload("res://src/discipline_progress.gd").new()
	preload("res://src/ui/chronicle_menu_header.gd").install(self,"skills","L",func(): closed.emit(),func(): pouch_requested.emit(),func(): _select_lineage(lineage),show_pouch,show_disciplines)
	_label("LINEAGES",Rect2(38,105,210,34),23,Color("463d2b"))
	_label("COMBAT SKILL OVERVIEW",Rect2(305,108,492,28),16,Color("64533a"))
	for i in CharacterCatalog.race_ids().size():
		var id: String = CharacterCatalog.race_ids()[i]
		var button := _button(CharacterCatalog.race(id).name,Rect2(36,157+i*49,225,42),_select_lineage.bind(id))
		lineage_buttons[id] = button
	heading = _label("",Rect2(310,145,480,34),25,Color("463d2b"))
	for i in 4:
		var origin := Vector2(303+(i%2)*254,201+(i/2)*180)
		var card := _button("",Rect2(origin,Vector2(243,164)),_select_skill.bind(i))
		cards.append(card)
		var tile := Tile.new()
		tile.position = origin+Vector2(12,13)
		tile.icon_edge = 52
		tile.size = Vector2(52,74)
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(tile)
		tiles.append(tile)
		names.append(_label("",Rect2(origin+Vector2(76,15),Vector2(153,56)),18,Chronicle.GOLD))
		summaries.append(_label("",Rect2(origin+Vector2(13,87),Vector2(216,65)),14,Chronicle.PARCHMENT))
	detail_icon = Tile.new()
	detail_icon.position = Vector2(944,115)
	detail_icon.icon_edge = 64
	detail_icon.size = Vector2(64,64)
	detail_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(detail_icon)
	detail_name = _label("",Rect2(853,195,255,67),25,Chronicle.GOLD)
	detail_text = _label("",Rect2(854,275,250,110),17,Chronicle.PARCHMENT)
	values = _label("",Rect2(854,395,250,151),16,Chronicle.IVORY)
	_label("Lineage skills · train disciplines to unlock",Rect2(300,571,505,30),15,Color("64533a"))
	_label("Arena sandbox: all skills available; no XP rewards." if sandbox else "Shared skills: Power Strike [7] · Arcane Bolt [8]. See Disciplines for requirements and progress.",Rect2(32,607,1090,27),14,Chronicle.PARCHMENT)
	_select_lineage(lineage)
	discipline_panel = preload("res://src/ui/discipline_overview.gd").new()
	discipline_panel.progression = progression
	discipline_panel.combat_model = combat_model
	discipline_panel.lineage = lineage
	discipline_panel.sandbox = sandbox
	add_child(discipline_panel)
	discipline_panel.hide()

func show_disciplines() -> void:
	discipline_panel.show()
	_set_tab("Disciplines & Levels")

func _set_tab(title: String) -> void:
	for child in get_children():
		if child is Button and child.text in ["Combat Skills","Disciplines & Levels"]:
			child.theme_type_variation = &"PrimaryButton" if child.text == title else &"Button"

func _label(value: String, rect: Rect2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = rect.position
	label.size = rect.size
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	if font_size >= 18: label.add_theme_font_override("font",theme.get_font("font","ChronicleHeading"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func _button(value: String, rect: Rect2, callback: Callable) -> Button:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.text = value
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(callback)
	add_child(button)
	return button

func _select_lineage(id: String) -> void:
	if is_instance_valid(discipline_panel): discipline_panel.hide()
	_set_tab("Combat Skills")
	selected_lineage = id
	heading.text = CharacterCatalog.race(id).name+(" · Your kit" if id == lineage else "")
	var kit := Skills.kit(id)
	for key in lineage_buttons:
		lineage_buttons[key].theme_type_variation = &"PrimaryButton" if key == id else &"QuietButton"
	for i in 4:
		tiles[i].configure(kit[i],str(i+3) if id == lineage else "")
		tiles[i].locked = not progression.allows(kit[i]) and not sandbox
		names[i].text = kit[i].name
		var role: String = {"melee":"Frontal strike","bolt":"Ranged attack","dash":"Forward rush","retreat":"Backward escape","rootbolt":"Rooting projectile","slowbolt":"Slowing projectile","heal":"Healing","ward":"Absorption ward","pulse":"Radial knockback","drain":"Lifesteal projectile"}.get(kit[i].kind,"Combat skill")
		summaries[i].text = "%d mana · %.1fs cooldown\n%s\n%s"%[kit[i].mana,kit[i].cooldown,role,progression.requirement_text(kit[i])]
	_select_skill(0)

func _select_skill(slot: int) -> void:
	selected_slot = slot
	var skill: Dictionary = Skills.kit(selected_lineage)[slot]
	for i in 4:
		tiles[i].selected = i == slot
		tiles[i].queue_redraw()
	detail_icon.configure(skill)
	detail_name.text = skill.name
	detail_text.text = skill.description
	detail_text.text += "\n"+progression.requirement_text(skill)
	values.text = "POWER       %d\nMANA          %d\nCOOLDOWN  %.1f s\nWINDUP       %.2f s\nREACH          %d\n\n%s"%[skill.power,skill.mana,skill.cooldown,skill.windup,skill.reach,"Hotkey %d"%(slot+3) if selected_lineage == lineage else "Opponent skill · Preview only"]

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Chronicle.NAVY)
	draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(12,6,1128,66))
	draw_style_box(theme.get_stylebox("panel","ParchmentPanel"),Rect2(20,87,253,510))
	draw_style_box(theme.get_stylebox("panel","ParchmentPanel"),Rect2(283,87,540,510))
	draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(835,87,297,510))
