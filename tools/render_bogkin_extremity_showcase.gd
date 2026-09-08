extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/bogkin_extremity_showcase.png"
const VIEWPORT_SIZE := Vector2i(1200,760)
const TILE_SIZE := Vector2(400,380)
const POSES := [
	{"title":"BARE / OPEN PALM", "weapon":"none", "motion":&"stand", "time":0.0},
	{"title":"SWORD / FOREHAND", "weapon":"sword", "motion":&"forehand", "time":.38},
	{"title":"BOW / FULL DRAW", "weapon":"bow", "motion":&"fire_bow", "time":.42},
	{"title":"CLIMB / REAR GRIP", "weapon":"sword", "motion":&"climb", "time":.36},
	{"title":"RUN / WEBBED FEET", "weapon":"none", "motion":&"run", "time":.25},
	{"title":"TONGUE SNAP / GESTURE", "weapon":"none", "motion":&"gesture", "time":.32},
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
	for pose_index in POSES.size():
		_add_pose(canvas,Vector2(pose_index%3,pose_index/3)*TILE_SIZE,POSES[pose_index],pose_index)
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
	print("PASS: rendered Tidekin webbed extremities in six runtime poses to %s" % OUTPUT_PATH)
	quit()


func _add_pose(canvas: Node2D, origin: Vector2, pose: Dictionary, pose_index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("172740") if pose_index%2 == 0 else Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(8,322),Vector2(TILE_SIZE.x-16,50)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(22,20)
	title.text = pose.title
	title.add_theme_font_size_override("font_size",20)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var avatar := Avatar.new()
	avatar.position = origin+Vector2(200,322)
	avatar.scale = Vector2.ONE*1.45
	canvas.add_child(avatar)
	avatar.configure("bogkin",{
		"weapon":pose.weapon, "offhand":"none", "armor":"marsh_tunic", "pants":"cloth",
		"boots":"none", "head":"none", "back":"none", "accessory":"none",
	})
	match pose.motion:
		&"stand": avatar.play_motion(&"stand")
		&"forehand": avatar.play_weapon_attack(&"forehand")
		&"fire_bow": avatar.play_weapon_attack(&"fire_bow")
		&"gesture": avatar.play_gesture(0)
		_: avatar.play_motion(pose.motion)
	if avatar._active_tween and float(pose.time) > 0.0:
		avatar._active_tween.custom_step(float(pose.time))
		avatar._active_tween.pause()


func _add_rect(parent: Node, rect: Rect2, color: Color, z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
