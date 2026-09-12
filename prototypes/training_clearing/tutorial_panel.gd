extends Control
## Fixed-size world hint. Text and drawing change only when the instruction changes.
var guide
var model
var camera := Vector2.ZERO
var title: Label
var body: Label
var cached_title := ""
var cached_body := ""

func _ready() -> void:
	size = Vector2(340,64)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 250
	var style := StyleBoxFlat.new()
	style.bg_color = Color("142a2ee8")
	style.border_color = Color("d8bb72")
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	var background := Panel.new()
	background.size = size
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.add_theme_stylebox_override("panel",style)
	add_child(background)
	title = Label.new()
	title.position = Vector2(12,8)
	title.size = Vector2(316,22)
	title.add_theme_font_size_override("font_size",17)
	title.add_theme_color_override("font_color",Color("f2d387"))
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)
	body = Label.new()
	body.position = Vector2(12,33)
	body.size = Vector2(316,20)
	body.add_theme_font_size_override("font_size",13)
	body.add_theme_color_override("font_color",Color("fff5d6"))
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(body)
	refresh()

func refresh() -> void:
	if not guide.started: return
	var hint: Dictionary = guide.hint()
	if hint.title != cached_title:
		cached_title = hint.title
		title.text = cached_title
	if hint.text != cached_body:
		cached_body = hint.text
		body.text = cached_body
	var at: Vector2 = hint.at-camera
	# Keep Rowan and his touch interaction unobscured by the nearby hint.
	if model.rowan_enabled and hint.at == model.rowan.position:
		at += Vector2(350,-45)
	position = Vector2(clampf(at.x-170,20,792),clampf(at.y-230,198,288))
