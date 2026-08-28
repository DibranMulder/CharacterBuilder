extends Node2D

const Avatar := preload("res://src/modular_character.gd")
const Ladder := preload("res://src/ladder_visual.gd")

var avatar: ModularCharacter
var race_selector: OptionButton
var gear_selectors := {}
var gesture_box: HBoxContainer
var weapon_attack_box: HBoxContainer
var race_ids: Array[String]
var title_label: Label
var tagline_label: Label
var ladder: Node2D


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("111827"))
	_build_background()
	ladder=Ladder.new(); ladder.position=Vector2(790,480); ladder.z_index=-10; ladder.visible=false; add_child(ladder)
	avatar = Avatar.new(); avatar.position = Vector2(790,505); avatar.scale = Vector2.ONE * 1.35; add_child(avatar)
	avatar.motion_changed.connect(_motion_changed)
	avatar.equipment_changed.connect(_equipment_changed)
	_build_ui()
	_build_motion_controls()
	_select_race(0)


func _build_background() -> void:
	var backdrop := Polygon2D.new()
	backdrop.polygon = PackedVector2Array([Vector2(440,0),Vector2(1152,0),Vector2(1152,648),Vector2(440,648)])
	backdrop.color = Color("17243a"); backdrop.z_index=-50; add_child(backdrop)
	var floor := Polygon2D.new()
	floor.polygon = PackedVector2Array([Vector2(440,514),Vector2(1152,514),Vector2(1152,648),Vector2(440,648)])
	floor.color = Color("20344a"); floor.z_index=-40; add_child(floor)
	for i in 9:
		var star := Polygon2D.new(); var x := 490.0 + i*79.0; var y := 48.0 + (i%3)*67.0
		star.polygon=PackedVector2Array([Vector2(x,y-3),Vector2(x+3,y),Vector2(x,y+3),Vector2(x-3,y)])
		star.color=Color(0.55,0.82,0.95,0.45); star.z_index=-45; add_child(star)


func _panel_style(color: Color, radius := 12) -> StyleBoxFlat:
	var style := StyleBoxFlat.new(); style.bg_color=color
	style.corner_radius_top_left=radius; style.corner_radius_top_right=radius; style.corner_radius_bottom_left=radius; style.corner_radius_bottom_right=radius
	style.content_margin_left=18; style.content_margin_right=18; style.content_margin_top=10; style.content_margin_bottom=10
	return style


func _build_ui() -> void:
	var panel := PanelContainer.new(); panel.position=Vector2(28,16); panel.size=Vector2(390,616)
	panel.add_theme_stylebox_override("panel",_panel_style(Color("202b3d"))); add_child(panel)
	var column := VBoxContainer.new(); column.add_theme_constant_override("separation",4); panel.add_child(column)
	var heading := Label.new(); heading.text="LINEAGE FORGE"; heading.add_theme_font_size_override("font_size",28); heading.add_theme_color_override("font_color",Color("77d4cf")); column.add_child(heading)
	var intro := Label.new(); intro.text="Build race, gear, and motion."; intro.add_theme_color_override("font_color",Color("aebdd0")); column.add_child(intro)
	column.add_child(HSeparator.new())
	column.add_child(_label("Race"))
	race_selector=OptionButton.new(); race_ids=CharacterCatalog.race_ids()
	for id in race_ids: race_selector.add_item(CharacterCatalog.race(id).name)
	race_selector.item_selected.connect(_select_race); column.add_child(race_selector)
	title_label=_label(""); title_label.add_theme_font_size_override("font_size",20); title_label.add_theme_color_override("font_color",Color("f3c969")); column.add_child(title_label)
	tagline_label=_label(""); tagline_label.add_theme_color_override("font_color",Color("91a4bb")); column.add_child(tagline_label)
	column.add_child(HSeparator.new())
	var grid := GridContainer.new(); grid.columns=2; grid.add_theme_constant_override("h_separation",12); grid.add_theme_constant_override("v_separation",7); column.add_child(grid)
	for slot in CharacterCatalog.SLOT_ORDER:
		grid.add_child(_label(String(slot).capitalize()))
		var selector := OptionButton.new(); selector.custom_minimum_size.x=205
		for item in CharacterCatalog.items_for(slot): selector.add_item(String(item).capitalize())
		selector.item_selected.connect(_equip_selected.bind(slot,selector)); grid.add_child(selector); gear_selectors[String(slot)]=selector
	column.add_child(HSeparator.new())
	column.add_child(_label("Weapon attacks"))
	weapon_attack_box=HBoxContainer.new(); weapon_attack_box.add_theme_constant_override("separation",6); column.add_child(weapon_attack_box)
	_rebuild_weapon_attacks()
	column.add_child(_label("Race gestures"))
	gesture_box=HBoxContainer.new(); gesture_box.add_theme_constant_override("separation",6); column.add_child(gesture_box)


func _build_motion_controls() -> void:
	var panel := PanelContainer.new(); panel.position=Vector2(650,18); panel.size=Vector2(420,108)
	panel.add_theme_stylebox_override("panel",_panel_style(Color("202b3d"),10)); add_child(panel)
	var rows:=VBoxContainer.new(); rows.add_theme_constant_override("separation",5); panel.add_child(rows)
	var row:=HBoxContainer.new(); row.add_theme_constant_override("separation",7); rows.add_child(row)
	var label:=_label("Motion"); label.add_theme_color_override("font_color",Color("77d4cf")); row.add_child(label)
	for motion in Avatar.MOTIONS:
		var button:=Button.new(); button.text=String(motion).capitalize(); button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		button.pressed.connect(avatar.play_motion.bind(motion)); row.add_child(button)
	var facing_row:=HBoxContainer.new(); facing_row.add_theme_constant_override("separation",7); rows.add_child(facing_row)
	var facing_label:=_label("Facing"); facing_label.add_theme_color_override("font_color",Color("77d4cf")); facing_row.add_child(facing_label)
	for direction in [&"left", &"right"]:
		var button:=Button.new(); button.text=String(direction).capitalize(); button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		button.pressed.connect(avatar.set_facing.bind(direction)); facing_row.add_child(button)


func _motion_changed(motion: StringName) -> void:
	ladder.visible = motion == &"climb"


func _label(text_: String) -> Label:
	var label:=Label.new(); label.text=text_; return label


func _select_race(index: int) -> void:
	if index < 0 or index >= race_ids.size(): return
	var id := race_ids[index]; avatar.configure(id, avatar.loadout)
	var profile:=CharacterCatalog.race(id); title_label.text=profile.name; tagline_label.text=profile.tagline
	for child in gesture_box.get_children(): child.queue_free()
	for i in avatar.available_gestures().size():
		var gesture: Dictionary=avatar.available_gestures()[i]; var button:=Button.new(); button.text=gesture.name; button.size_flags_horizontal=Control.SIZE_EXPAND_FILL; button.pressed.connect(avatar.play_gesture.bind(i)); gesture_box.add_child(button)
	_sync_selectors()
	_rebuild_weapon_attacks()


func _equip_selected(index: int, slot: StringName, selector: OptionButton) -> void:
	var items:=CharacterCatalog.items_for(slot)
	if index >= 0 and index < items.size():
		avatar.equip(slot,items[index])


func _equipment_changed(slot: StringName, _item_id: String) -> void:
	if slot in [&"weapon",&"offhand"]:
		_sync_selectors()
	if slot == &"weapon":
		_rebuild_weapon_attacks()


func _rebuild_weapon_attacks() -> void:
	if not weapon_attack_box:
		return
	for child in weapon_attack_box.get_children():
		weapon_attack_box.remove_child(child)
		child.queue_free()
	for attack in avatar.available_weapon_attacks():
		var attack_button := Button.new()
		attack_button.text = String(attack).capitalize()
		attack_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		attack_button.pressed.connect(avatar.play_weapon_attack.bind(attack))
		weapon_attack_box.add_child(attack_button)


func _sync_selectors() -> void:
	for slot in gear_selectors:
		var selector: OptionButton=gear_selectors[slot]; var items:=CharacterCatalog.items_for(slot)
		selector.disabled = not avatar.supports_equipment_slot(slot)
		selector.tooltip_text = "Not used by this race" if selector.disabled else ""
		selector.select(items.find(avatar.loadout[slot]))
