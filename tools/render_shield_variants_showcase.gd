extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const Ladder := preload("res://src/ladder_visual.gd")
const OUTPUT_PATH := "res://artifacts/shield_variants_showcase.png"
const VIEWPORT_SIZE := Vector2i(1200,800)
const TILE_SIZE := Vector2(400,400)
const VARIANTS := [
	{"title":"BOGKIN / MARSH SHIELD", "race":"bogkin", "shield":"marsh_shield"},
	{"title":"HUMAN / ADVENTURER SHIELD", "race":"human", "shield":"shield"},
	{"title":"DUNEBORN / DUNE SHIELD", "race":"duneborn", "shield":"dune_shield"},
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
	for row in 2:
		for column in VARIANTS.size():
			_add_variant(canvas,Vector2(column,row)*TILE_SIZE,VARIANTS[column],row == 1,column)
	Engine.time_scale = 0.0
	for frame in 6:
		await process_frame
	var texture := viewport.get_texture()
	if texture == null:
		push_error("No render texture; run this tool with a graphics display")
		Engine.time_scale = 1.0
		quit(1)
		return
	var image := texture.get_image()
	if image == null or image.save_png(OUTPUT_PATH) != OK:
		push_error("Could not save %s" % OUTPUT_PATH)
		Engine.time_scale = 1.0
		quit(1)
		return
	Engine.time_scale = 1.0
	print("PASS: rendered three swappable shield faces in wielded and rear climbing states to %s" % OUTPUT_PATH)
	quit()


func _add_variant(canvas: Node2D,origin: Vector2,variant: Dictionary,climbing: bool,index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("172740") if index%2 == 0 else Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(8,342),Vector2(TILE_SIZE.x-16,50)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(20,18)
	title.text = "%s / %s" % [variant.title,"REAR CARRY" if climbing else "WIELDED"]
	title.add_theme_font_size_override("font_size",17)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var ground := origin+Vector2(200,342)
	if climbing:
		var ladder := Ladder.new()
		ladder.position = ground
		ladder.scale = Vector2.ONE*.62
		ladder.z_index = -12
		canvas.add_child(ladder)
	var avatar := Avatar.new()
	avatar.position = ground
	avatar.scale = Vector2.ONE*(1.06 if variant.race == "bogkin" else .96)
	canvas.add_child(avatar)
	var loadout := CharacterCatalog.reference_loadout(variant.race)
	loadout.weapon = "sword" if variant.race != "duneborn" else "spear"
	loadout.offhand = variant.shield
	avatar.configure(variant.race,loadout)
	if climbing:
		avatar.play_motion(&"climb")
		avatar._active_tween.custom_step(.28)
		avatar._active_tween.pause()


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
