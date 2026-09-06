extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/staff_cast_sequence.png"
const VIEWPORT_SIZE := Vector2i(1800,430)
const TILE_SIZE := Vector2(300,430)
const SAMPLES := [
	{"title":"CRYSTAL / REST", "race":"frostling", "time":0.0},
	{"title":"CRYSTAL / GATHER", "race":"frostling", "time":.18},
	{"title":"CRYSTAL / EMIT", "race":"frostling", "time":.31},
	{"title":"CRYSTAL / FOLLOW", "race":"frostling", "time":.43},
	{"title":"CRYSTAL / RECOVER", "race":"frostling", "time":.66},
	{"title":"BRANCH / FOLLOW", "race":"fae", "time":.43},
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
	for index in SAMPLES.size():
		_add_sample(canvas,Vector2(index*TILE_SIZE.x,0),SAMPLES[index],index)
	Engine.time_scale = 0.0
	for frame in 6:
		await process_frame
	var image := viewport.get_texture().get_image()
	if image == null or image.save_png(OUTPUT_PATH) != OK:
		push_error("Could not save %s" % OUTPUT_PATH)
		Engine.time_scale = 1.0
		quit(1)
		return
	Engine.time_scale = 1.0
	print("PASS: rendered crystal and branch staff cast follow-through to %s" % OUTPUT_PATH)
	quit()


func _add_sample(canvas: Node2D,origin: Vector2,sample: Dictionary,index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("172740") if index%2 == 0 else Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(8,370),Vector2(TILE_SIZE.x-16,52)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(16,20)
	title.text = sample.title
	title.add_theme_font_size_override("font_size",15)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var clip := Control.new()
	clip.position = origin+Vector2(8,8)
	clip.size = TILE_SIZE-Vector2(16,16)
	clip.clip_contents = true
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(clip)
	var avatar := Avatar.new()
	avatar.position = Vector2(137,362)
	avatar.scale = Vector2.ONE*1.08
	clip.add_child(avatar)
	var race_id: String = sample.race
	avatar.configure(race_id,CharacterCatalog.reference_loadout(race_id))
	if float(sample.time) > 0.0:
		avatar.play_weapon_attack(&"cast_spell")
		var sample_time := float(sample.time)
		# Preserve the exact emission callback transform before evaluating the
		# follow-through tracks in manually sampled later frames.
		if sample_time > .30:
			avatar._active_tween.custom_step(.30)
			avatar._active_tween.custom_step(sample_time-.30)
		else:
			avatar._active_tween.custom_step(sample_time)
		avatar._active_tween.pause()
		_stage_spell_flight(avatar,sample_time)


func _stage_spell_flight(avatar: Node,time: float) -> void:
	if not avatar.has_node("StaffSpell"):
		return
	# Character samples advance their action tween manually while Engine time is
	# frozen for capture. Mirror the runtime projectile's quadratic flight here
	# so later pose samples do not falsely leave the spell pinned to the crystal.
	var spell: Sprite2D = avatar.get_node("StaffSpell")
	var elapsed := maxf(time-.30,0.0)
	var progress := clampf(elapsed/.38,0.0,1.0)
	var direction := -1.0 if avatar.facing == &"left" else 1.0
	spell.position.x += 320.0*float(avatar._profile.scale)*progress*progress*direction
	spell.rotation = TAU*progress
	spell.scale = Vector2.ONE.lerp(Vector2(.68,.68),progress)
	if elapsed > .22:
		spell.modulate.a = clampf(1.0-(elapsed-.22)/.16,0.0,1.0)


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
