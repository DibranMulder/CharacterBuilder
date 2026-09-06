class_name PartVisual
extends Node2D

var kind := "torso"
var size := Vector2(50, 70)
var color := Color.WHITE
var accent := Color("303846")
var back_view := false
var style: Dictionary = {}
var authored_skin := false

const INK := Color("352b25")
const STORYBOOK_FAE_WING_RIGHT := preload("res://assets/base_sprites/fae_wing_storybook.png")
const STORYBOOK_FAE_WING_LEFT := preload("res://assets/base_sprites/fae_wing_storybook_left.png")
const FAE_WING_ROOT_RIGHT := Vector2(2,52)
const FAE_WING_ROOT_LEFT := Vector2(82,52)


func setup(p_kind: String, p_size: Vector2, p_color: Color, p_accent: Color) -> PartVisual:
	kind = p_kind
	size = p_size
	color = p_color
	accent = p_accent
	queue_redraw()
	return self


func set_back_view(enabled: bool) -> void:
	back_view = enabled
	if has_node("AuthoredAnatomy"):
		var authored_anatomy: BaseAnatomyVisual = get_node("AuthoredAnatomy")
		authored_anatomy.set_back_view(enabled)
	queue_redraw()


func set_style(p_style: Dictionary) -> PartVisual:
	style = p_style
	queue_redraw()
	return self


func set_authored_skin(enabled: bool) -> PartVisual:
	authored_skin = enabled
	queue_redraw()
	return self


func _ellipse(center: Vector2, radii: Vector2, fill: Color) -> void:
	var points := PackedVector2Array()
	for i in 24:
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, fill)
	draw_polyline(points + PackedVector2Array([points[0]]), INK, 2.4, true)


func _outlined_polygon(points: PackedVector2Array, fill: Color, width := 2.4) -> void:
	draw_colored_polygon(points, fill)
	draw_polyline(points + PackedVector2Array([points[0]]), INK, width, true)


func _draw_membrane_lobe(tip: Vector2, half_width: float, fill: Color, vein: Color, outline: Color) -> void:
	var normal := Vector2(-tip.y,tip.x).normalized()
	var points := PackedVector2Array([Vector2.ZERO])
	for i in range(1,13):
		var t := float(i)/12.0
		points.append(tip*t+normal*sin(t*PI)*half_width)
	for i in range(12,0,-1):
		var t := float(i)/12.0
		points.append(tip*t-normal*sin(t*PI)*half_width)
	draw_colored_polygon(points,fill)
	draw_polyline(points+PackedVector2Array([points[0]]),outline,1.55,true)
	draw_line(Vector2.ZERO,tip,vein,1.2,true)
	# Two softly branching ribs keep the large transparent cells readable at
	# gameplay scale without turning the membrane into a dark equipment plate.
	draw_line(tip*.18,tip*.62+normal*half_width*.58,vein,1.0,true)
	draw_line(tip*.30,tip*.76-normal*half_width*.44,vein,1.0,true)


func _draw_hair(center: Vector2, radii: Vector2) -> void:
	var hair: Color = style.get("hair", accent.darkened(.45))
	var hair_style: String = style.get("hair_style", "crop")
	if hair_style == "none":
		return
	if hair_style in ["long", "ponytail", "braid"]:
		var back_hair := PackedVector2Array([
			center + Vector2(-radii.x*.8,-radii.y*.5), center + Vector2(radii.x*.55,-radii.y*.65),
			center + Vector2(radii.x*.72,radii.y*.55), center + Vector2(radii.x*.45,radii.y*1.35),
			center + Vector2(-radii.x*.62,radii.y*1.05),
		])
		_outlined_polygon(back_hair, hair, 2.6)
	if hair_style == "ponytail":
		draw_line(center + Vector2(-radii.x*.55,-radii.y*.45), center + Vector2(-radii.x*1.18,radii.y*.65), INK, radii.x*.48, true)
		draw_line(center + Vector2(-radii.x*.55,-radii.y*.45), center + Vector2(-radii.x*1.18,radii.y*.65), hair, radii.x*.38, true)
	elif hair_style == "braid":
		for i in 4:
			var bead := center + Vector2(-radii.x*.72-i*2.0, radii.y*(.25+i*.28))
			draw_circle(bead, radii.x*.15, INK)
			draw_circle(bead, radii.x*.11, hair)


func _draw() -> void:
	if authored_skin:
		return
	match kind:
		"head":
			var center := Vector2(0, -size.y * 0.35)
			var radii := size * 0.5
			_draw_hair(center, radii)
			_ellipse(Vector2(0, -size.y * 0.35), size * 0.5, color)
			var hair: Color = style.get("hair", accent.darkened(.45))
			var hair_style: String = style.get("hair_style", "crop")
			if hair_style != "none":
				# A broad cap and separated fringe make hair part of the silhouette,
				# matching the illustrated reference without baking it into equipment.
				draw_arc(center + Vector2(0,-radii.y*.05), radii.x*.82, PI*1.06, TAU*1.02, 22, INK, radii.y*.40, true)
				draw_arc(center + Vector2(0,-radii.y*.05), radii.x*.82, PI*1.06, TAU*1.02, 22, hair, radii.y*.31, true)
				var fringe := PackedVector2Array([
					center + Vector2(-radii.x*.62,-radii.y*.48), center + Vector2(radii.x*.62,-radii.y*.5),
					center + Vector2(radii.x*.44,-radii.y*.05), center + Vector2(radii.x*.15,-radii.y*.25),
					center + Vector2(-radii.x*.06,radii.y*.03), center + Vector2(-radii.x*.22,-radii.y*.25),
					center + Vector2(-radii.x*.52,-radii.y*.02),
				])
				_outlined_polygon(fringe, hair, 2.0)
			if back_view:
				draw_arc(center, radii.x*.72, PI*.08, PI*.92, 18, hair, radii.y*.28)
				draw_line(Vector2(-size.x*.24,-size.y*.16),Vector2(size.x*.24,-size.y*.16),INK,2.0)
			else:
				var eye := Vector2(size.x * 0.18, -size.y * 0.38)
				var frog_face: bool = String(style.get("face", "")) == "frog"
				var eye_radius := 7.0 if frog_face else 5.4
				draw_circle(eye + Vector2(0,-2 if frog_face else 0), eye_radius, INK)
				draw_circle(eye + Vector2(0,-2 if frog_face else 0), eye_radius-1.4, Color("fffaf0"))
				draw_circle(eye + Vector2(1.0,-1.6 if frog_face else .4), 2.8 if frog_face else 2.5, style.get("eye", Color("50351f")))
				draw_circle(eye + Vector2(1.7,-.8), .9, Color.WHITE)
				if frog_face:
					draw_circle(Vector2(size.x*.33,-size.y*.27),1.2,INK)
					draw_arc(Vector2(size.x*.08,-size.y*.17),size.x*.27,.1,PI-.1,12,INK,2.0)
				else:
					draw_line(Vector2(size.x*.31,-size.y*.30),Vector2(size.x*.38,-size.y*.26),INK,1.5,true)
					draw_arc(Vector2(size.x * 0.13, -size.y * 0.20), 7.0, 0.25, 2.15, 8, INK, 1.6)
				draw_circle(Vector2(size.x*.31,-size.y*.16),3.2,Color(1.0,.42,.38,.16))
		"torso":
			var body_shape: String = style.get("body_shape", "balanced")
			var shoulder_ratio := 0.48
			var waist_ratio := 0.34
			if body_shape == "slender":
				shoulder_ratio = 0.44
				waist_ratio = 0.27
			elif body_shape == "lean":
				shoulder_ratio = 0.46
				waist_ratio = 0.30
			elif body_shape == "top_heavy":
				shoulder_ratio = 0.58
				waist_ratio = 0.38
			elif body_shape == "compact":
				shoulder_ratio = 0.52
				waist_ratio = 0.43
			var pts := PackedVector2Array([
				Vector2(-size.x * shoulder_ratio, 0), Vector2(size.x * shoulder_ratio, 0),
				Vector2(size.x * waist_ratio, size.y), Vector2(-size.x * waist_ratio, size.y)])
			_outlined_polygon(pts, color)
			draw_colored_polygon(PackedVector2Array([pts[0],Vector2(0,0),Vector2(-size.x*.05,size.y),pts[3]]), color.darkened(.08))
			draw_arc(Vector2(0,3),size.x*.14,0,PI,10,INK,2.0)
			if style.get("skin_pattern", "") == "mottled":
				draw_circle(Vector2(-size.x*.27,size.y*.25),size.x*.065,color.darkened(.15))
				draw_circle(Vector2(size.x*.31,size.y*.40),size.x*.045,color.darkened(.13))
		"limb":
			# Explicit shoulder bulb: the lower half merges into the upper-arm
			# capsule, leaving a clean half-circle at the shoulder end.
			draw_circle(Vector2.ZERO,size.x*.64,INK)
			draw_circle(Vector2.ZERO,size.x*.52,color.lightened(.03))
			draw_line(Vector2.ZERO,Vector2(0,size.y),INK,size.x+4.5,true)
			draw_line(Vector2.ZERO,Vector2(0,size.y),color,size.x,true)
			draw_circle(Vector2(0,size.y),size.x*.53,INK)
			draw_circle(Vector2(0,size.y),size.x*.40,color.lightened(.04))
			if style.get("skin_pattern", "") == "mottled":
				draw_circle(Vector2(size.x*.12,size.y*.32),size.x*.15,color.darkened(.14))
				draw_circle(Vector2(-size.x*.08,size.y*.58),size.x*.10,color.darkened(.12))
		"shin":
			draw_line(Vector2.ZERO,Vector2(0,size.y),INK,size.x+4.5,true)
			draw_line(Vector2.ZERO,Vector2(0,size.y),color,size.x,true)
			draw_circle(Vector2(0,size.y),size.x*.50,INK)
			draw_circle(Vector2(0,size.y),size.x*.36,color)
		"horse":
			if back_view:
				# Foreshortened top/rear view for ladders: the withers taper into a
				# rounded rump instead of projecting horizontally to one side.
				var back := PackedVector2Array([
					Vector2(-size.y*.28,-size.y*.18), Vector2(size.y*.28,-size.y*.18),
					Vector2(size.y*.48,size.y*.20), Vector2(size.y*.50,size.y*.58),
					Vector2(size.y*.32,size.y*.82), Vector2(0,size.y*.94),
					Vector2(-size.y*.32,size.y*.82), Vector2(-size.y*.50,size.y*.58),
					Vector2(-size.y*.48,size.y*.20),
				])
				_outlined_polygon(back,color)
				draw_line(Vector2(0,-size.y*.04),Vector2(0,size.y*.67),color.lightened(.10),3.0,true)
				draw_arc(Vector2(0,size.y*.45),size.y*.31,.08,PI-.08,16,color.darkened(.10),3.0)
			else:
				_ellipse(Vector2(0, 4), size * 0.5, color)
				draw_arc(Vector2(size.x*.28,0),size.y*.30,-PI*.55,PI*.55,12,color.lightened(.08),5.0)
		"horse_neck":
			# A narrow human-waist transition opening into the horse's withers and
			# chest. This keeps the centaur readable as two joined anatomies.
			var neck := PackedVector2Array([
				Vector2(-size.x*.20,0), Vector2(size.x*.20,0),
				Vector2(size.x*(.38 if back_view else .48),size.y*.70), Vector2(size.x*.30,size.y),
				Vector2(-size.x*.30,size.y), Vector2(-size.x*(.38 if back_view else .42),size.y*(.70 if back_view else .88)),
			])
			_outlined_polygon(neck,color)
			if back_view:
				draw_line(Vector2(0,size.y*.12),Vector2(0,size.y*.82),color.lightened(.08),3.0,true)
			else:
				draw_arc(Vector2(size.x*.08,size.y*.62),size.x*.30,-PI*.82,PI*.42,14,color.lightened(.08),5.0)
		"wing":
			# Authored true-alpha membranes replace the former flat polygons while
			# preserving this node as the waist-rooted animation/pivot contract.
			var wing_texture := STORYBOOK_FAE_WING_LEFT if size.x < 0.0 else STORYBOOK_FAE_WING_RIGHT
			var wing_root := FAE_WING_ROOT_LEFT if size.x < 0.0 else FAE_WING_ROOT_RIGHT
			draw_texture(wing_texture,-wing_root)
		"ear":
			var ear := PackedVector2Array([Vector2.ZERO, Vector2(size.x, -size.y * .5), Vector2(size.x * .15, size.y * .5)])
			draw_colored_polygon(ear, color)
			draw_polyline(ear + PackedVector2Array([ear[0]]), INK, 2.0)
		"shadow":
			_ellipse(Vector2.ZERO, size * 0.5, Color(0.03, 0.06, 0.1, 0.32))
