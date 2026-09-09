extends Control
signal closed
signal trade_requested
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
var speech: Label

func _ready() -> void:
	size = Vector2(1152,648)
	z_index = 300
	theme = Chronicle.create()
	var portrait := TextureRect.new()
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var atlas := AtlasTexture.new()
	atlas.atlas = preload("res://assets/npcs/elder_rowan.png")
	atlas.region = Rect2(290,110,470,470)
	portrait.texture = atlas
	portrait.position = Vector2(124,431)
	portrait.size = Vector2(158,158)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var material := ShaderMaterial.new()
	material.shader = preload("res://prototypes/training_clearing/rowan_portrait.gdshader")
	material.set_shader_parameter("region_origin",Vector2(290,110)/atlas.atlas.get_size())
	material.set_shader_parameter("region_size",Vector2(470,470)/atlas.atlas.get_size())
	portrait.material = material
	add_child(portrait)
	_label("Elder Rowan",Vector2(295,427),24,true,Chronicle.PARCHMENT)
	speech = _label("The old road remembers every traveler.\nRest a moment. I have supplies for the trail,\nand coin for what you no longer need.",Vector2(301,477),18,false,Color("302a21"))
	_label("Forest Wardens",Vector2(301,568),13,true,Color("5e633f"))
	_button("Trade",Vector2(785,452),"PrimaryButton",func(): trade_requested.emit())
	_button("Tell me about the grove.",Vector2(785,503),"Button",func(): speech.text = "Briars have overrun the eastern trail.\nAn elder growth waits beyond the ledges.\nKeep your blade sharp—and a potion close.")
	_button("Farewell · Esc",Vector2(785,554),"QuietButton",func(): closed.emit())

func _label(value: String, at: Vector2, font_size: int, fancy: bool, color: Color) -> Label:
	var label := Label.new()
	label.position = at
	label.text = value
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if fancy: label.theme_type_variation = "ChronicleHeading"
	add_child(label)
	return label

func _button(value: String, at: Vector2, variant: String, action: Callable) -> void:
	var button := Button.new()
	button.position = at
	button.size = Vector2(278,44)
	button.text = value
	button.theme_type_variation = variant
	button.pressed.connect(action)
	add_child(button)

func _draw() -> void:
	draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(112,418,984,214))
	draw_style_box(theme.get_stylebox("panel","ParchmentPanel"),Rect2(262,451,497,152))
	draw_style_box(theme.get_stylebox("panel","InkPanel"),Rect2(275,419,241,39))
	draw_circle(Vector2(203,510),84,Chronicle.BRASS)
	draw_circle(Vector2(203,510),80,Chronicle.NAVY)
	draw_arc(Vector2(203,510),85,0,TAU,96,Chronicle.GOLD,2,true)
	draw_arc(Vector2(203,510),79,0,TAU,96,Chronicle.GOLD,1,true)
