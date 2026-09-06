extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const OUTPUT_PATH := "res://artifacts/equipment_catalog_showcase.png"
const COLUMNS := 7
const TILE_SIZE := Vector2(240,240)
const EMPTY_LOADOUT := {
	"weapon":"none", "offhand":"none", "armor":"none", "pants":"none",
	"boots":"none", "head":"none", "back":"none", "accessory":"none",
}


func _initialize() -> void:
	_render.call_deferred()


func _render() -> void:
	var entries: Array[Dictionary] = []
	for slot in CharacterCatalog.SLOT_ORDER:
		for item in CharacterCatalog.items_for(slot):
			if item != "none":
				entries.append({"slot":String(slot),"item":String(item)})
	var rows := ceili(float(entries.size())/float(COLUMNS))
	var viewport_size := Vector2i(int(TILE_SIZE.x)*COLUMNS,int(TILE_SIZE.y)*rows)
	RenderingServer.set_default_clear_color(Color("101a2b"))
	var viewport := SubViewport.new()
	viewport.size = viewport_size
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Node2D.new()
	viewport.add_child(canvas)
	_add_rect(canvas,Rect2(Vector2.ZERO,Vector2(viewport_size)),Color("101a2b"),-100)
	for index in entries.size():
		_add_entry(canvas,Vector2(index%COLUMNS,index/COLUMNS)*TILE_SIZE,entries[index],index)
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
	print("PASS: rendered %d selectable equipment items at runtime scale to %s" % [entries.size(),OUTPUT_PATH])
	quit()


func _add_entry(canvas: Node2D,origin: Vector2,entry: Dictionary,index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(5,5),TILE_SIZE-Vector2(10,10)),Color("172740") if index%2 == 0 else Color("192b43"),-90)
	_add_rect(canvas,Rect2(origin+Vector2(5,202),Vector2(TILE_SIZE.x-10,33)),Color("21384c"),-80)
	var title := Label.new()
	title.position = origin+Vector2(12,10)
	title.text = "%s / %s" % [String(entry.slot).to_upper(),String(entry.item).replace("_"," ").to_upper()]
	title.add_theme_font_size_override("font_size",13)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var avatar := Avatar.new()
	avatar.position = origin+Vector2(120,202)
	avatar.scale = Vector2.ONE*.60
	canvas.add_child(avatar)
	var loadout := EMPTY_LOADOUT.duplicate()
	loadout[entry.slot] = entry.item
	avatar.configure("human",loadout)
	avatar.play_motion(&"stand")


func _add_rect(parent: Node,rect: Rect2,color: Color,z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
