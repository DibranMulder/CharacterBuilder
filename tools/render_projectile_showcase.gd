extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/projectile_showcase.png"
const VIEWPORT_SIZE := Vector2i(1200,760)
const TILE_SIZE := Vector2(600,380)
const SAMPLES := [
	{"title":"BOW RELEASE / RIGHT", "weapon":"bow", "facing":&"right", "time":.50},
	{"title":"BOW RELEASE / LEFT", "weapon":"bow", "facing":&"left", "time":.50},
	{"title":"STAFF SPELL / RIGHT", "weapon":"staff", "facing":&"right", "time":.31},
	{"title":"STAFF SPELL / LEFT", "weapon":"staff", "facing":&"left", "time":.31},
]


func _initialize() -> void:
	_render.call_deferred()


func _render() -> void:
	RenderingServer.set_default_clear_color(Color("101a2b"))
	var viewport := SubViewport.new()
	viewport.size = VIEWPORT_SIZE
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Node2D.new()
	viewport.add_child(canvas)
	_add_rect(canvas,Rect2(Vector2.ZERO,Vector2(VIEWPORT_SIZE)),Color("101a2b"),-100)
	for sample_index in SAMPLES.size():
		_add_sample(canvas,Vector2(sample_index%2,sample_index/2)*TILE_SIZE,SAMPLES[sample_index])
	# Freeze gameplay tweens at the release sockets while still allowing the
	# SubViewport several frames to populate its render texture.
	Engine.time_scale = 0.0
	for frame in 6:
		await process_frame
	var texture := viewport.get_texture()
	if texture == null:
		push_error("No render texture; run this tool with a graphics display")
		quit(1)
		return
	var image := texture.get_image()
	if image == null or image.save_png(OUTPUT_PATH) != OK:
		push_error("Could not save %s" % OUTPUT_PATH)
		quit(1)
		return
	Engine.time_scale = 1.0
	print("PASS: rendered authored bow and staff projectiles in both facings to %s" % OUTPUT_PATH)
	quit()


func _add_sample(canvas: Node2D, origin: Vector2, sample: Dictionary) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(8,322),Vector2(TILE_SIZE.x-16,50)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(24,20)
	title.text = sample.title
	title.add_theme_font_size_override("font_size",22)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var avatar := Avatar.new()
	avatar.position = origin+Vector2(300,322)
	avatar.scale = Vector2.ONE*1.45
	canvas.add_child(avatar)
	avatar.configure("human",{
		"weapon":sample.weapon, "offhand":"none", "armor":"cloth", "pants":"leather",
		"boots":"leather", "head":"none", "back":"quiver" if sample.weapon == "bow" else "cape", "accessory":"none",
	})
	avatar.set_facing(sample.facing)
	avatar.play_weapon_attack(&"fire_bow" if sample.weapon == "bow" else &"cast_spell")
	avatar._active_tween.custom_step(float(sample.time))
	avatar._active_tween.pause()
	if sample.weapon == "bow":
		avatar._gear.weapon.set_bow_draw(0.0)
		# Keep opposing proof samples inside their own tiles instead of letting
		# the mirrored arrows collide into a false double-headed silhouette.
		avatar.get_node("FiredArrow").position.x += 18.0*(-1.0 if sample.facing == &"left" else 1.0)
	else:
		avatar.get_node("StaffSpell").position.x += 64.0*(-1.0 if sample.facing == &"left" else 1.0)


func _add_rect(parent: Node, rect: Rect2, color: Color, z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
