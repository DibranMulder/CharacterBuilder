class_name HumanLimbSurface
extends Node2D

# One contour spans both bones. Internal joints never receive a cap or outline;
# the same surface can later carry fitted sleeves and trouser material.
var lower: Node2D
var length: float
var width: float
var skin: Color
var is_leg := false
var armor := "none"
var pants := "none"
var accent := Color.WHITE
var painted_surface: Node2D
var paint_texture: Texture2D
var paint_material: Material


func _ready() -> void:
	painted_surface = preload("res://src/human_limb_paint.gd").new()
	painted_surface.surface = self
	painted_surface.show_behind_parent = true
	add_child(painted_surface)


func setup(lower_bone: Node2D, lower_length: float, limb_width: float, tone: Color, leg := false) -> void:
	lower = lower_bone
	length = lower_length
	width = limb_width
	skin = tone
	is_leg = leg


func _process(_delta: float) -> void:
	queue_redraw()
	if is_instance_valid(painted_surface):
		painted_surface.visible = not is_leg or pants == "none"
		painted_surface.queue_redraw()


func centerline() -> PackedVector2Array:
	var elbow := to_local(lower.global_position)
	var wrist := to_local(lower.to_global(Vector2(0, length)))
	var start := -elbow.normalized() * width * .18
	var entry := elbow * .72
	var exit_point := elbow.lerp(wrist, .28)
	var points := PackedVector2Array([start, elbow * .32, entry])
	for step in range(1, 9):
		var t := float(step) / 8.0
		points.append(entry.lerp(elbow, t).lerp(elbow.lerp(exit_point, t), t))
	points.append(elbow.lerp(wrist, .68))
	points.append(wrist)
	return points


func _draw() -> void:
	if not is_instance_valid(lower):
		return
	var centers := centerline()
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	var shade_edge := PackedVector2Array()
	for i in centers.size():
		var before := centers[maxi(0, i - 1)]
		var after := centers[mini(centers.size() - 1, i + 1)]
		var tangent := (after - before).normalized()
		var normal := Vector2(-tangent.y, tangent.x)
		var t := float(i) / (centers.size() - 1)
		var radius := width * lerpf(.5, .29 if not is_leg else .34, t)
		if is_leg and pants != "none":
			# Cloth volume is part of the continuous contour, not an overlay
			# ending at the knee. Baggy trousers retain a generous upper leg.
			radius *= lerpf(1.8 if pants == "baggy" else 1.28, 1.08, t)
		outer.append(centers[i] + normal * radius)
		inner.append(centers[i] - normal * radius)
		shade_edge.append(centers[i] + normal * radius * .38)
	var reversed_inner := inner.duplicate()
	reversed_inner.reverse()
	var fill := skin
	if is_leg:
		fill = {
			"ranger": Color("4b5d3e"), "cloth": accent,
			"baggy": Color("3b4650"), "leather": Color("785638"),
			"plate": Color("939fa5"),
		}.get(pants, skin)
	# A rounded proximal contour disappears into the torso/pelvis. A flat
	# cut at this point remains visible when an arm rises above the shoulder.
	var cap := PackedVector2Array()
	var direction := (centers[1] - centers[0]).normalized()
	var normal := Vector2(-direction.y, direction.x)
	var radius := outer[0].distance_to(inner[0]) * .5
	for step in range(1, 9):
		var angle := float(step) / 9.0 * PI
		cap.append(centers[0] - normal * cos(angle) * radius - direction * sin(angle) * radius)
	var silhouette := outer + reversed_inner + cap
	var tones := PackedColorArray()
	for i in silhouette.size():
		if i < outer.size():
			tones.append(fill.darkened(.12))
		elif i < outer.size() + reversed_inner.size():
			tones.append(fill.lightened(.06))
		else:
			tones.append(fill)
	if is_leg and pants != "none":
		draw_polygon(silhouette, tones)
	var reversed_shade := shade_edge.duplicate()
	reversed_shade.reverse()
	if is_leg and pants != "none":
		draw_colored_polygon(outer + reversed_shade, fill.darkened(.18))
	# Fine warm ink matches the head, without outlining the shoulder or wrist
	# seams that disappear beneath adjacent anatomy.
	var ink := Color("795039")
	if is_leg and pants != "none":
		draw_polyline(outer, ink, .85, true)
		draw_polyline(inner, ink, .85, true)
	if is_leg and pants != "none":
		# A side seam and short compression folds carry the material through
		# the bend without painting a hard horizontal boundary across the knee.
		draw_polyline(shade_edge, fill.lightened(.12), .7, true)
		for index in [3, 8, 11]:
			var edge := inner[index].lerp(outer[index], .12)
			var fold_end := centers[index].lerp(centers[maxi(0, index - 1)], .4)
			draw_line(edge, fold_end, fill.darkened(.28), .8, true)
		if pants == "plate":
			_draw_cover(outer, inner, 4, 8, fill.lightened(.12), 1.12)
	if not is_leg and armor != "none":
		var sleeve_color: Color = {
			"marsh_tunic": Color("e1d1ac"), "cloth": accent,
			"leather": Color("82603d"), "plate": Color("a5b3b7"),
			"fur_coat": Color("343d5b"), "troll_jerkin": Color("655043"),
			"fae_tunic": Color("d6aa47"), "lamellar": Color("9f6840"),
			"woodland_harness": Color("657443"),
		}.get(armor, Color("e1d1ac"))
		_draw_cover(outer, inner, 0, 6, sleeve_color, 1.12)
		if armor in ["marsh_tunic", "leather", "plate", "lamellar", "woodland_harness"]:
			var bracer_color := Color("947044") if armor != "plate" else Color("9dabb1")
			_draw_cover(outer, inner, 10, centers.size() - 1, bracer_color, 1.25)


func _draw_cover(outer: PackedVector2Array, inner: PackedVector2Array, first: int, last: int, fill: Color, expansion: float) -> void:
	var a := PackedVector2Array()
	var b := PackedVector2Array()
	for i in range(first, last + 1):
		var middle := (outer[i] + inner[i]) * .5
		a.append(middle + (outer[i] - middle) * expansion)
		b.append(middle + (inner[i] - middle) * expansion)
	b.reverse()
	var outline := a + b
	var tones := PackedColorArray()
	for i in outline.size():
		tones.append(fill.darkened(.19) if i < a.size() else fill.lightened(.10))
	draw_polygon(outline, tones)
	draw_polyline(outline + PackedVector2Array([outline[0]]), Color("795039"), .9, true)
	draw_polyline(a, fill.darkened(.22), 1.8, true)
	# Cuff stitching and a narrow reflected edge give small cloth/leather
	# pieces the same light-and-seam language as the authored torso garment.
	var cuff_a := a[a.size() - 1]
	var cuff_b := b[0]
	draw_line(cuff_a.lerp(cuff_b,.16),cuff_a.lerp(cuff_b,.84),fill.lightened(.26),.65,true)
