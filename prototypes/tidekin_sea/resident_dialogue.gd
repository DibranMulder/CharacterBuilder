extends Control
signal closed
signal trade_requested
signal service_requested(action: String)
var resident: Dictionary
func _ready() -> void:
	z_index = 300
	theme = preload("res://src/ui/chronicle_theme.gd").create()
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel",theme.get_stylebox("panel","InkPanel"))
	panel.position = Vector2(260,370)
	panel.size = Vector2(840,245)
	add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,20)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation",14)
	margin.add_child(box)
	var title := Label.new()
	title.text = resident.name+" · "+resident.role
	title.add_theme_font_size_override("font_size",24)
	box.add_child(title)
	var words := Label.new()
	words.text = resident.greeting
	words.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	words.custom_minimum_size = Vector2(760,80)
	box.add_child(words)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation",16)
	box.add_child(buttons)
	if not resident.stock.is_empty(): _button(buttons,"Trade",func(): trade_requested.emit())
	if "Trainer" in resident.role: _button(buttons,"View skills",func(): service_requested.emit("skills"))
	if resident.role == "Innkeeper": _button(buttons,"Hero overview",func(): service_requested.emit("hero"))
	_button(buttons,"Farewell · Esc",func(): closed.emit())
func _button(parent: Node, text_: String, action: Callable) -> void:
	var button := Button.new()
	button.text = text_
	button.custom_minimum_size = Vector2(175,44)
	button.pressed.connect(action)
	parent.add_child(button)
