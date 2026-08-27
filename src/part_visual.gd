class_name PartVisual
extends Node2D

var kind := "torso"
var size := Vector2(50, 70)
var color := Color.WHITE
var accent := Color("303846")


func setup(p_kind: String, p_size: Vector2, p_color: Color, p_accent: Color) -> PartVisual:
	kind = p_kind
	size = p_size
	color = p_color
	accent = p_accent
	queue_redraw()
	return self


func _ellipse(center: Vector2, radii: Vector2, fill: Color) -> void:
	var points := PackedVector2Array()
	for i in 24:
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, fill)
	draw_polyline(points + PackedVector2Array([points[0]]), accent.darkened(0.35), 2.0, true)


func _draw() -> void:
	match kind:
		"head":
			_ellipse(Vector2(0, -size.y * 0.35), size * 0.5, color)
			draw_circle(Vector2(size.x * 0.18, -size.y * 0.42), 3.7, Color("f7f3df"))
			draw_circle(Vector2(size.x * 0.2, -size.y * 0.42), 1.8, Color("18202b"))
			draw_arc(Vector2(size.x * 0.1, -size.y * 0.27), 8.0, 0.15, 2.2, 8, accent.darkened(0.4), 1.5)
		"torso":
			var pts := PackedVector2Array([
				Vector2(-size.x * 0.48, 0), Vector2(size.x * 0.48, 0),
				Vector2(size.x * 0.34, size.y), Vector2(-size.x * 0.34, size.y)])
			draw_colored_polygon(pts, color)
			draw_polyline(pts + PackedVector2Array([pts[0]]), accent.darkened(0.4), 2.2, true)
		"limb":
			draw_line(Vector2.ZERO, Vector2(0, size.y), color, size.x, true)
			draw_circle(Vector2.ZERO, size.x * 0.5, color)
			draw_circle(Vector2(0, size.y), size.x * 0.52, color)
			draw_line(Vector2.ZERO, Vector2(0, size.y), accent.darkened(0.35), 2.0, true)
		"horse":
			_ellipse(Vector2(0, 4), size * 0.5, color)
		"wing":
			var wing := PackedVector2Array([Vector2.ZERO, Vector2(size.x, -size.y * .65), Vector2(size.x * .72, size.y * .15), Vector2(size.x * .2, size.y)])
			draw_colored_polygon(wing, Color(color, 0.58))
			draw_polyline(wing + PackedVector2Array([wing[0]]), accent, 2.0, true)
		"ear":
			var ear := PackedVector2Array([Vector2.ZERO, Vector2(size.x, -size.y * .5), Vector2(size.x * .15, size.y * .5)])
			draw_colored_polygon(ear, color)
			draw_polyline(ear + PackedVector2Array([ear[0]]), accent.darkened(.35), 2.0)
		"shadow":
			_ellipse(Vector2.ZERO, size * 0.5, Color(0.03, 0.06, 0.1, 0.32))

