extends Node2D
## Field Notes: outlined, source-labelled combat text above the character rig.

var model
var camera := Vector2.ZERO
var floaters: Array[Dictionary] = []
var hurt_time := 0.0
var sequence := 0
var font := SystemFont.new()
const COLORS := {"dealt": Color("fff5d6"), "power": Color("f2c45f"),
	"taken": Color("ff987f"), "blocked": Color("72d6e5"),
	"heal": Color("b6e8a1"), "ward": Color("b9abf2"),
	"xp": Color("b6d69a"), "level": Color("f2c45f"), "notice": Color("72d6e5")}

func _init() -> void:
	font.font_names = PackedStringArray(["Arial", "Helvetica", "sans-serif"])
	font.font_weight = 800
	z_index = 150

func push(event: Dictionary) -> void:
	var item := event.duplicate()
	item.kind = item.get("kind", "notice")
	item.age = 0.0
	item.drift = -1.0 if item.kind == "taken" else 1.0
	item.position += Vector2((sequence % 3 - 1) * 18, 0)
	for other in floaters:
		if other.position.distance_to(item.position) < 55:
			item.position.y -= 34
	sequence += 1
	floaters.append(item)
	if item.kind == "taken":
		hurt_time = .24
	queue_redraw()

func advance(delta: float) -> void:
	hurt_time = maxf(0, hurt_time - delta)
	for item in floaters:
		item.age += delta
	floaters = floaters.filter(func(item): return item.age < 1.25)
	queue_redraw()

func reset() -> void:
	floaters.clear()
	hurt_time = 0
	sequence = 0

func _text(value: String, at: Vector2, size: int, color: Color) -> void:
	var origin := at - Vector2(font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x * .5, 0)
	draw_string_outline(font, origin + Vector2(1, 2), value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 6, Color(0.035, .055, .085, color.a))
	draw_string(font, origin, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw() -> void:
	for item in floaters:
		var color: Color = COLORS.get(item.kind, COLORS.notice)
		color.a = clampf((1.25 - item.age) / .35, 0, 1)
		var point: Vector2 = item.position - camera + Vector2(item.drift * item.age * 12, -item.age * 38)
		point.y = maxf(225, point.y)
		var pop: float = 1.0 + .22 * maxf(0, 1 - item.age / .16)
		var size := 32 if item.kind in ["dealt", "power", "taken"] else 22
		if item.kind == "power":
			size = 39
			_text("POWER", point + Vector2(0, 19), 12, color)
		_text(item.text, point, roundi(size * pop), color)
		if item.kind == "blocked":
			var shield_at := point + Vector2(font.get_string_size(item.text, 0, -1, roundi(size * pop)).x * .5 + 14, -10)
			var shield := PackedVector2Array([shield_at + Vector2(-7,-8), shield_at + Vector2(0,-5), shield_at + Vector2(7,-8), shield_at + Vector2(6,3), shield_at + Vector2(0,9), shield_at + Vector2(-6,3)])
			draw_colored_polygon(shield, color)
			shield.append(shield[0])
			draw_polyline(shield, Color(.035, .055, .085, color.a), 2, true)
		if item.has("impact") and item.age < .22:
			var center: Vector2 = item.impact - camera
			var radius: float = 9 + item.age * 120
			color.a = 1 - item.age / .22
			if item.kind == "heal":
				for side in [-1,1]:
					var at := center+Vector2(side*radius,-item.age*90)
					draw_line(at-Vector2(5,0),at+Vector2(5,0),color,3,true)
					draw_line(at-Vector2(0,5),at+Vector2(0,5),color,3,true)
				continue
			if item.kind in ["blocked","ward"]:
				var shield := PackedVector2Array([center+Vector2(-radius,-radius),center+Vector2(radius,-radius),center+Vector2(radius*.8,radius*.4),center+Vector2(0,radius),center+Vector2(-radius*.8,radius*.4),center+Vector2(-radius,-radius)])
				draw_polyline(shield,color,3,true)
				continue
			draw_arc(center, radius, 0, TAU, 24, color, 3, true)
			for ray in 6:
				var direction := Vector2.from_angle(ray * TAU / 6)
				draw_line(center + direction * radius, center + direction * (radius + 9), color, 2, true)
	if hurt_time > 0:
		draw_rect(Rect2(3, 190, 1146, 337), Color(1, .3, .23, hurt_time * 2), false, 6)
