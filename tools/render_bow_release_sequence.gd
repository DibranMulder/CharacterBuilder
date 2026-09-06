extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/bow_release_sequence.png"
const VIEWPORT_SIZE := Vector2i(2100,430)
const TILE_SIZE := Vector2(350,430)
const SAMPLES := [
	{"title":"HUMAN / REST", "race":"human", "time":0.0},
	{"title":"HUMAN / FULL DRAW", "race":"human", "time":.40},
	{"title":"HUMAN / RELEASE", "race":"human", "time":.50},
	{"title":"HUMAN / RECOIL", "race":"human", "time":.57},
	{"title":"HUMAN / RECOVER", "race":"human", "time":.68},
	{"title":"CENTAUR / RELEASE", "race":"centaur", "time":.50},
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
	print("PASS: rendered ballistic bow release and relaxed-hand recovery to %s" % OUTPUT_PATH)
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
	# Bias the archer left within the clipped frame so the constant-speed arrow
	# remains visible through the recoil sample without bleeding into its neighbor.
	avatar.position = Vector2(128,362)
	avatar.scale = Vector2.ONE*(1.08 if sample.race == "human" else .82)
	clip.add_child(avatar)
	var race_id: String = sample.race
	var loadout := CharacterCatalog.reference_loadout(race_id)
	loadout.weapon = "bow"
	loadout.offhand = "none"
	loadout.back = "quiver"
	avatar.configure(race_id,loadout)
	if float(sample.time) > 0.0:
		avatar.play_weapon_attack(&"fire_bow")
		var sample_time := float(sample.time)
		# Crossing a callback inside one large custom_step can construct the arrow
		# after later recoil tracks have already evaluated. Step to the real release
		# boundary first so proof frames preserve runtime callback order.
		if sample_time > .48:
			avatar._active_tween.custom_step(.48)
			avatar._active_tween.custom_step(sample_time-.48)
		else:
			avatar._active_tween.custom_step(sample_time)
		avatar._active_tween.pause()
		_stage_arrow_flight(avatar,sample_time)


func _stage_arrow_flight(avatar: Node,time: float) -> void:
	if not avatar.has_node("FiredArrow"):
		return
	# Engine time is frozen for capture, so mirror the runtime's linear 300 px
	# flight here while the character action is sampled independently.
	var arrow: Sprite2D = avatar.get_node("FiredArrow")
	var elapsed := maxf(time-.48,0.0)
	var progress := clampf(elapsed/.28,0.0,1.0)
	var direction := -1.0 if avatar.facing == &"left" else 1.0
	arrow.position.x += 300.0*float(avatar._profile.scale)*progress*direction
	if elapsed > .18:
		arrow.modulate.a = clampf(1.0-(elapsed-.18)/.10,0.0,1.0)


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
