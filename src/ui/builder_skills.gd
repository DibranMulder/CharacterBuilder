extends PanelContainer
const Catalog = preload("res://src/builder_skill_catalog.gd")
signal closed
var avatar: Node
var selected_id := "human_crosscut"
var skill_list: ItemList
var heading: Label
var detail: Label
var requirements: Label
var availability: Label
var preview: Button
var category: OptionButton
var skills: Array = []

func _ready() -> void:
	position = Vector2(28,12)
	size = Vector2(390,624)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("202b3d")
	style.set_corner_radius_all(12)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	add_theme_stylebox_override("panel",style)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",5)
	add_child(column)
	var top := HBoxContainer.new()
	column.add_child(top)
	var title := _label("SKILL PREVIEW",22,Color("77d4cf"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(title)
	var back := Button.new()
	back.text = "Gear"
	back.pressed.connect(func(): closed.emit())
	top.add_child(back)
	category = OptionButton.new()
	category.add_item("Human lineage · 4 abilities")
	category.add_item("Sword proficiency · 7 techniques")
	category.item_selected.connect(_select_category)
	column.add_child(category)
	skill_list = ItemList.new()
	skill_list.custom_minimum_size.y = 182
	skill_list.add_theme_font_size_override("font_size",16)
	skill_list.add_theme_constant_override("v_separation",1)
	skill_list.item_selected.connect(_select_skill)
	column.add_child(skill_list)
	column.add_child(HSeparator.new())
	heading = _label("",24,Color("f3c969")); column.add_child(heading)
	detail = _label("",15,Color("d6dfeb"))
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.custom_minimum_size.y = 68
	column.add_child(detail)
	requirements = _label("",13,Color("b1c4dc"))
	requirements.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(requirements)
	availability = _label("",13,Color("f3c969"))
	availability.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	availability.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(availability)
	var actions := HBoxContainer.new()
	column.add_child(actions)
	preview = Button.new(); preview.text = "Preview skill"
	preview.custom_minimum_size.y = 36
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.pressed.connect(func(): avatar.play_skill_preview(selected_id))
	actions.add_child(preview)
	var stop := Button.new(); stop.text = "Stop"
	stop.pressed.connect(avatar.stop_motion)
	actions.add_child(stop)
	column.add_child(_label("Animation sandbox · no combat or XP",12,Color("91a4bb")))
	avatar.equipment_changed.connect(func(_slot,_item): refresh())
	_select_category(0)

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	return label

func _select_category(index: int) -> void:
	category.select(index)
	skills = Catalog.HUMAN if index == 0 else Catalog.SWORD
	skill_list.clear()
	for skill in skills: skill_list.add_item(skill.name)
	_select_skill(0)

func _select_skill(index: int) -> void:
	selected_id = skills[index].id
	skill_list.select(index)
	skill_list.ensure_current_is_visible()
	refresh()

func refresh() -> void:
	if not is_instance_valid(preview): return
	var skill := Catalog.find(selected_id)
	heading.text = skill.name
	detail.text = skill.description
	requirements.text = "Unlock: " + skill.unlock
	if skill.has("stats"): requirements.text += "\n" + skill.stats
	var reason := Catalog.unavailable_reason(skill,avatar)
	preview.disabled = not reason.is_empty()
	availability.text = reason if not reason.is_empty() else "Ready to preview · progression unlocks bypassed"
