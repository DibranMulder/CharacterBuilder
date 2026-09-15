extends Control
signal closed
signal trade_requested
signal service_requested(action: String)
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
	if merchant.role == "Waystone Guardian":
		var portrait := TextureRect.new()
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.texture = load("res://assets/npcs/wendmere/guardian.png")
		portrait.position = Vector2(235,433)
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.size = Vector2(115,180)
		add_child(portrait)
	else:
		var portrait := TextureRect.new()
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		var art := preload("res://prototypes/human_hometown/resident_art.gd")
		portrait.texture = art.texture(merchant.id)
		portrait.material = art.material()
		portrait.position = Vector2(235,433)
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.size = Vector2(115,180)
		add_child(portrait)
	_label(merchant.name+" · "+merchant.role,Vector2(365,445),25,Chronicle.GOLD)
	_label(merchant.greeting,Vector2(365,491),14,Chronicle.PARCHMENT)
	if not merchant.stock.is_empty(): _button("Trade",Vector2(849,466),func(): trade_requested.emit())
	if "Trainer" in merchant.role:
		_button("View skills",Vector2(849,466),func(): service_requested.emit("skills"))
	if merchant.role == "Innkeeper":
		_button("Hero overview",Vector2(849,466),func(): service_requested.emit("hero"))
	if merchant.role in ["Apothecary","Provisioner"]: _provisions()
	_button("Farewell · Esc",Vector2(849,531),func(): closed.emit())
func _label(text_: String, at: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text_
	label.position = at
	if font_size == 14:
		label.size = Vector2(465,100)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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

func _provisions() -> void:
	var panel := Panel.new()
	panel.position = Vector2(350,205)
	panel.size = Vector2(740,200)
	panel.add_theme_stylebox_override("panel",theme.get_stylebox("panel","InkPanel"))
	add_child(panel)
	_label("PROVISIONS · Catalogue preview",Vector2(370,217),20,Chronicle.GOLD)
	var rows := ["Mending Salve · 6 coins · Gradually restores health out of combat", "Draught of Vigor · 8 coins · Restores stamina", "Focusing Tonic · 8 coins · Restores mana", "Antidote · 5 coins · Cures poison"] if merchant.role == "Apothecary" else ["Waybread · 4 coins · Improves regeneration out of combat", "Torch · 3 coins · Light for the road", "Climbing rope · 10 coins · Utility supply"]
	for i in rows.size(): _label(rows[i],Vector2(370,253+i*26),16,Chronicle.PARCHMENT)
	_label("These provisions are not available to purchase yet.",Vector2(370,373),15,Chronicle.PARCHMENT)
