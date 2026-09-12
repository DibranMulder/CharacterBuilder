extends Control
signal closed
signal trade_requested
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
var merchant: Dictionary
var outfit: Dictionary
func _ready() -> void:
	size = Vector2(1152,648)
	z_index = 300
	theme = Chronicle.create()
	var panel := Panel.new()
	panel.position = Vector2(220,420)
	panel.size = Vector2(895,208)
	panel.add_theme_stylebox_override("panel",theme.get_stylebox("panel","InkPanel"))
	add_child(panel)
	var portrait := preload("res://src/ui/character_portrait.gd").new()
	portrait.position = Vector2(295,518)
	add_child(portrait)
	portrait.configure("human",outfit)
	_label(merchant.name+" · "+merchant.role,Vector2(365,445),25,Chronicle.GOLD)
	_label(merchant.greeting,Vector2(365,491),18,Chronicle.PARCHMENT)
	_button("Trade",Vector2(849,466),func(): trade_requested.emit())
	_button("Farewell · Esc",Vector2(849,531),func(): closed.emit())
func _label(text_: String, at: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text_
	label.position = at
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	add_child(label)
func _button(text_: String, at: Vector2, action: Callable) -> void:
	var button := Button.new()
	button.text = text_
	button.position = at
	button.size = Vector2(237,48)
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	add_child(button)
