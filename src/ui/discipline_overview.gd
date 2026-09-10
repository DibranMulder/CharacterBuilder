extends Control
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
const Progress = preload("res://src/discipline_progress.gd")
const Skills = preload("res://prototypes/sparring_arena/lineage_skills.gd")
const Icon = preload("res://src/ui/chronicle_round_icon.gd")
const BOARD = preload("res://designs/disciplines-talent-tree.png")
const INK := Color("392f22")
const NODE_CENTERS := [Vector2(424,166),Vector2(607,166),Vector2(607,321),Vector2(424,321),Vector2(790,166),Vector2(790,321)]
var progression
var combat_model
var lineage := "human"
var sandbox := false
var selected := "attack"
var selected_skill := -1
var rows := {}
var detail: Label
var summary: Label
var unlocks: Array[Label] = []
var nodes: Array[Button] = []
var detail_title: Label
var detail_icon: TextureRect
var status: Label

func _ready() -> void:
	position = Vector2(0,80)
	size = Vector2(1152,568)
	theme = Chronicle.create()
	_summary_strip()
	_label("DISCIPLINES",Rect2(39,93,237,30),21,INK,true)
	var y := 128.0
	var family := ""
	for id in Progress.CATALOG:
		var spec: Array = Progress.CATALOG[id]
		if spec[1] != family:
			family = spec[1]
			_label(family.to_upper(),Rect2(42,y,205,21),15,_family_color(family))
			y += 23
		var button := Button.new()
		button.position = Vector2(27,y)
		button.size = Vector2(261,25)
		for state in ["normal","hover","pressed","focus"]: button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(select.bind(id))
		add_child(button)
		rows[id] = button
		_add_icon(id,Vector2(29,y-1),Vector2(26,26))
		_label(spec[0],Rect2(60,y,115,25),16,INK)
		_label(str(progression.level(id)),Rect2(174,y-2,28,28),23,INK,true)
		var bar := preload("res://src/ui/discipline_xp_bar.gd").new()
		bar.position = Vector2(210,y+10)
		bar.size = Vector2(63,6)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var level: int = progression.level(id)
		bar.value = 100 if level == 99 else 100.0*(progression.xp[id]-Progress.threshold(level))/(Progress.threshold(level+1)-Progress.threshold(level))
		bar.color = _family_color(family)
		add_child(bar)
		y += 27
	_label("LINEAGE ABILITIES",Rect2(344,103,347,25),14,INK,true)
	_label("SHARED",Rect2(718,103,144,25),14,INK,true)
	var kit := Skills.combat_kit(lineage)
	for i in kit.size():
		var node := preload("res://src/ui/chronicle_skill_node.gd").new()
		node.position = NODE_CENTERS[i]-Vector2(36,36)
		node.size = Vector2(72,72)
		node.unlocked = progression.allows(kit[i])
		node.tooltip_text = kit[i].name+"\n"+progression.requirement_text(kit[i])
		node.pressed.connect(show_skill.bind(i))
		add_child(node)
		node.portrait.ability(kit[i])
		nodes.append(node)
		var caption := _label(kit[i].name,Rect2(NODE_CENTERS[i]+Vector2(-82,36),Vector2(164,25)),14,Chronicle.IVORY,true)
		unlocks.append(caption)
		var requirements: PackedStringArray = []
		for id in kit[i].requirements: requirements.append("%s %d"%[Progress.CATALOG[id][0],kit[i].requirements[id]])
		_label(" · ".join(requirements),Rect2(NODE_CENTERS[i]+Vector2(-87,64),Vector2(174,23)),12,Chronicle.GOLD,true)
	_label("DISCIPLINE MASTERY",Rect2(499,482,216,27),17,Chronicle.GOLD,true)
	_add_icon("exploration",Vector2(579,418),Vector2(56,56))
	detail_icon = _add_icon(selected,Vector2(966,116),Vector2(48,48))
	detail_title = _label("",Rect2(891,174,225,54),21,Chronicle.GOLD,true)
	detail = _label("",Rect2(900,240,210,221),15,Chronicle.PARCHMENT)
	status = _label("",Rect2(898,473,218,30),14,Chronicle.CYAN,true)
	_label("UNLOCKED",Rect2(360,528,94,26),13,Chronicle.GOLD)
	_label("SELECTED",Rect2(478,528,94,26),13,Chronicle.GOLD)
	_label("LOCKED",Rect2(592,528,94,26),13,Chronicle.GOLD)
	_label("Automatic unlocks · no Talent Points",Rect2(822,528,302,26),12,Chronicle.PARCHMENT,true)
	select("attack")

func _summary_strip() -> void:
	_label("OVERALL",Rect2(20,9,76,20),12,Chronicle.GOLD,true)
	_label(str(progression.overall_level()),Rect2(20,24,76,45),36,Chronicle.IVORY,true)
	_label("TOTAL LEVEL",Rect2(106,7,128,20),13,Chronicle.GOLD,true)
	summary = _label(str(progression.total_level()),Rect2(106,25,128,29),26,Chronicle.GOLD,true)
	_label("12 disciplines",Rect2(106,54,128,18),12,Chronicle.PARCHMENT,true)
	var adventure: int = combat_model.adventure_level if combat_model != null else 1
	_label("ADVENTURE",Rect2(248,9,119,22),13,Chronicle.GOLD,true)
	_label(str(adventure),Rect2(248,32,119,36),26,Chronicle.IVORY,true)
	var damage := "—"
	if combat_model != null:
		damage = str(int(combat_model.weapon_feel().damage)) if combat_model.has_method("weapon_feel") else str(int(combat_model.basic().power))
		var weapon: String = combat_model.weapon if combat_model.has_method("weapon_feel") else combat_model.loadout.weapon
		if weapon == "none": damage = "0"
	var specs := [["attack","DAMAGE",damage],["defense","DEFENSE LV",str(progression.level("defense"))],
		["agility","AGILITY LV",str(progression.level("agility"))],["health","HEALTH",str(int(combat_model.health)) if combat_model != null else "—"],
		["stamina","STAMINA",str(int(combat_model.stamina)) if combat_model != null else "—"],["mana","MANA",str(int(combat_model.mana)) if combat_model != null else "—"]]
	for i in specs.size():
		var x := 386+i*124
		_add_icon(specs[i][0],Vector2(x,15),Vector2(33,33))
		_label(specs[i][2],Rect2(x+37,12,75,31),24,Chronicle.IVORY)
		_label(specs[i][1],Rect2(x,48,110,21),12,Chronicle.GOLD,true)

func _add_icon(id: String, at: Vector2, dimensions: Vector2) -> TextureRect:
	var icon := Icon.new()
	icon.discipline(id)
	icon.position = at
	icon.size = dimensions
	add_child(icon)
	return icon

func _label(text: String, rect: Rect2, font_size: int, color: Color, centered := false) -> Label:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER if rect.size.y <= 54 else VERTICAL_ALIGNMENT_TOP
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.add_theme_font_override("font",theme.get_font("font","ChronicleHeading"))
	if centered: label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	return label

func select(id: String) -> void:
	selected = id
	selected_skill = -1
	var level: int = progression.level(id)
	var next := "Maximum level reached" if level == 99 else "%d XP to level %d"%[Progress.threshold(level+1)-progression.xp[id],level+1]
	detail_title.text = "%s · Level %d"%[Progress.CATALOG[id][0],level]
	detail_icon.discipline(id)
	detail.text = "%d total XP\n%s\n\nHOW TO TRAIN\n%s"%[progression.xp[id],next,Progress.CATALOG[id][2]]
	status.text = "No XP in arena" if sandbox else "Trained through play"
	_refresh_nodes()

func show_skill(slot: int) -> void:
	selected_skill = slot
	var skill := Skills.combat_kit(lineage)[slot]
	detail_title.text = skill.name
	detail_icon.ability(skill)
	detail.text = "%s\n\n%s\n\n%d mana · %.1fs cooldown\n%d power · %d reach\n\n%s"%["Lineage skill" if slot < 4 else "Shared discipline skill",skill.description,skill.mana,skill.cooldown,skill.power,skill.reach,progression.requirement_text(skill)]
	status.text = "Unlocked · Key %d"%(slot+3) if progression.allows(skill) else "Locked · Train disciplines"
	if sandbox: status.text = "Arena sandbox · Key %d"%(slot+3)
	_refresh_nodes()

func _refresh_nodes() -> void:
	for i in nodes.size():
		nodes[i].selected = i == selected_skill
		nodes[i].queue_redraw()
	queue_redraw()

func _family_color(family: String) -> Color:
	return {"Martial":Color("924d31"),"Mystic":Color("78578e"),"World":Color("54744b")}[family]

func _paper(rect: Rect2) -> void:
	draw_style_box(theme.get_stylebox("panel","ParchmentPanel"),rect)
	# Blank parchment from the supplied board, tiled beneath live controls.
	for y in range(int(rect.position.y+8),int(rect.end.y-8),48):
		for x in range(int(rect.position.x+8),int(rect.end.x-8),48):
			var area := Rect2(x,y,minf(48,rect.end.x-8-x),minf(48,rect.end.y-8-y))
			draw_texture_rect_region(BOARD,area,Rect2(1500,445,area.size.x,area.size.y),Color(1,1,1,.65))
	for corner in [rect.position+Vector2(10,10),rect.end-Vector2(10,10)]:
		var direction := 1.0 if corner == rect.position+Vector2(10,10) else -1.0
		for branch in 6:
			var end: Vector2 = corner+Vector2(12+branch*11,9+branch*7)*direction
			draw_line(corner,end,Color("929568"),1,true)
			draw_colored_polygon(PackedVector2Array([end,end+Vector2(3,-12)*direction,end+Vector2(10,-16)*direction,end+Vector2(8,-4)*direction]),Color("929568"))

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Chronicle.NAVY)
	draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(12,0,1128,76))
	draw_circle(Vector2(58,38),35,Chronicle.BLUE)
	draw_arc(Vector2(58,38),35,0,TAU,64,Chronicle.BRASS,2,true)
	draw_arc(Vector2(58,38),32,0,TAU,64,Chronicle.BRASS,1,true)
	for x in [100,240,377,501,625,749,873,997]: draw_line(Vector2(x,12),Vector2(x,65),Color("635533"),1)
	_paper(Rect2(12,81,292,476))
	_paper(Rect2(311,81,829,437))
	if rows.has(selected):
		var row: Button = rows[selected]
		draw_rect(Rect2(row.position,row.size),Color(.65,.47,.2,.13))
		draw_string(theme.get_font("font","ChronicleHeading"),row.position+Vector2(250,19),"›",0,-1,20,Color("785b26"))
	for y in [139,297,401]: draw_line(Vector2(142,y),Vector2(280,y),Color("ad9769"),1,true)
	var kit := Skills.combat_kit(lineage)
	for i in NODE_CENTERS.size():
		var curve := Curve2D.new()
		curve.add_point(Vector2(607,447),Vector2.ZERO,Vector2((NODE_CENTERS[i].x-607)*.5,-45))
		curve.add_point(NODE_CENTERS[i]+Vector2(0,29),Vector2(35,75),Vector2.ZERO)
		var points := curve.get_baked_points()
		draw_polyline(points,Color("59492d"),5,true)
		var edge := Color("3eaa9d") if progression.allows(kit[i]) else Color("a58c55")
		if i == selected_skill: edge = Chronicle.CYAN
		draw_polyline(points,edge,2,true)
		for offset in [Vector2(-82,36),Vector2(-87,64)]:
			draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(NODE_CENTERS[i]+offset,Vector2(164 if offset.y == 36 else 174,25)))
	draw_circle(Vector2(607,447),38,Chronicle.BLUE)
	draw_arc(Vector2(607,447),38,0,TAU,64,Chronicle.BRASS,3,true)
	draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(492,480,230,31))
	draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(881,103,247,407))
	draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(311,522,829,35))
	for pair in [[Vector2(345,539),Color("45bfb0")],[Vector2(463,539),Chronicle.CYAN],[Vector2(577,539),Color("917d54")]]:
		draw_circle(pair[0],6,Chronicle.NAVY)
		draw_arc(pair[0],6,0,TAU,24,pair[1],2,true)
