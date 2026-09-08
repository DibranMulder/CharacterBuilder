extends Node2D
## Chronicle palette and brass-framed resources; Guard is separate from mana.
var model
var player_name := ""
var font := ThemeDB.fallback_font

func _init() -> void:
	z_index = 200

func _panel(rect: Rect2, fill: Color, border: Color, width := 1) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(5)
	draw_style_box(style, rect)

func _text(value: String, at: Vector2, size: int, color := Color("fff5d6")) -> void:
	draw_string_outline(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 3, Color("101b2c"))
	draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _bar(rect: Rect2, fraction: float, color: Color, caption: String, size := 13) -> void:
	_panel(rect, Color("101b2c"), Color("c79b48"))
	var inner := rect.grow(-3)
	inner.size.x *= clampf(fraction, 0, 1)
	if inner.size.x > 0:
		draw_rect(inner, color)
		draw_line(inner.position, inner.position + Vector2(inner.size.x, 0), color.lightened(.3), 2)
	var text_width := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	_text(caption, rect.get_center() + Vector2(-text_width * .5, size * .35), size)

func _draw() -> void:
	if model == null:
		return
	_panel(Rect2(20, 14, 440, 117), Color("183454"), Color("c79b48"), 2)
	draw_circle(Vector2(64, 68), 30, Color("c79b48"))
	draw_circle(Vector2(64, 68), 27, Color("101b2c"))
	_text("LVL", Vector2(52, 60), 12, Color("f2c45f"))
	var level_text := str(model.adventure_level)
	_text(level_text, Vector2(64 - font.get_string_size(level_text, 0, -1, 25).x / 2, 87), 25)
	_text(player_name, Vector2(108, 35), 15)
	_bar(Rect2(108, 43, 334, 23), model.health / 100.0, Color("b85645"), "HP  %d / 100" % ceil(model.health))
	_bar(Rect2(108, 71, 334, 23), model.mana / 100.0, Color("3279b4"), "MANA  %d / 100" % floor(model.mana))
	_bar(Rect2(108, 100, 334, 19), float(model.xp) / model.xp_required(), Color("487c58"), "XP  %d / %d" % [model.xp, model.xp_required()], 11)
	_bar(Rect2(366, 600, 300, 18), model.stamina / 100.0, Color("2d756e"), "GUARD  %d / 100" % model.stamina, 11)
