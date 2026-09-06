extends SceneTree

const Avatar := preload("res://src/modular_character.gd")
const Staircase := preload("res://src/staircase_visual.gd")
const OUTPUT_PATH := "res://artifacts/stair_climb_showcase.png"
const CANVAS_SIZE := Vector2i(1600,900)
const TILE_SIZE := Vector2(400,450)
const LOADOUTS := {
	"bogkin": {"weapon":"sword", "offhand":"marsh_shield", "armor":"marsh_tunic", "pants":"cloth", "boots":"none"},
	"human": {"weapon":"spear", "offhand":"none", "armor":"marsh_tunic", "pants":"ranger", "boots":"leather", "back":"long_cape", "accessory":"scarf"},
	"centaur": {"weapon":"bow", "offhand":"none", "armor":"woodland_harness", "back":"quiver"},
	"fae": {"weapon":"branch_staff", "offhand":"none", "armor":"fae_tunic", "pants":"baggy", "boots":"wraps"},
	"frost_troll": {"weapon":"axe", "offhand":"none", "armor":"troll_jerkin", "pants":"leather", "boots":"none"},
	"goblin": {"weapon":"bow", "offhand":"none", "armor":"leather", "pants":"leather", "boots":"leather", "back":"quiver"},
	"duneborn": {"weapon":"spear", "offhand":"dune_shield", "armor":"lamellar", "pants":"cloth", "boots":"leather"},
	"frostling": {"weapon":"staff", "offhand":"none", "armor":"fur_coat", "pants":"cloth", "boots":"leather", "head":"hood"},
}


func _initialize() -> void:
	_render.call_deferred()


func _render() -> void:
	RenderingServer.set_default_clear_color(Color("101a2b"))
	var viewport := SubViewport.new()
	viewport.size = CANVAS_SIZE
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var canvas := Node2D.new()
	viewport.add_child(canvas)
	_add_rect(canvas,Rect2(Vector2.ZERO,Vector2(CANVAS_SIZE)),Color("101a2b"),-100)
	var race_ids := CharacterCatalog.race_ids()
	for race_index in race_ids.size():
		var race_id: String = race_ids[race_index]
		_add_tile(canvas,Vector2(race_index%4,race_index/4)*TILE_SIZE,race_id,race_index)
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
	print("PASS: rendered all 8 stair-climbing lineages to %s" % OUTPUT_PATH)
	quit()


func _add_tile(canvas: Node2D, origin: Vector2, race_id: String, race_index: int) -> void:
	_add_rect(canvas,Rect2(origin+Vector2(8,8),TILE_SIZE-Vector2(16,16)),Color("172740") if race_index%2 == 0 else Color("192b43"),-90)
	var title := Label.new()
	title.position = origin+Vector2(22,20)
	title.text = "%s / STAIRS" % String(CharacterCatalog.race(race_id).name).to_upper()
	title.add_theme_font_size_override("font_size",22)
	title.add_theme_color_override("font_color",Color("f2d181"))
	canvas.add_child(title)
	var ground := origin+Vector2(200,380)
	var stairs := Staircase.new()
	stairs.position = ground
	stairs.scale = Vector2.ONE*.45
	stairs.z_index = -12
	canvas.add_child(stairs)
	var avatar := Avatar.new()
	avatar.position = ground
	avatar.scale = Vector2.ONE*(.82 if race_id != "frost_troll" else .67)
	canvas.add_child(avatar)
	avatar.configure(race_id,LOADOUTS[race_id])
	avatar.play_motion(&"stairs")
	var sample_time := Avatar.STAIR_FRAME_DURATION*(2.0 if CharacterCatalog.race(race_id).topology == "centaur" else 4.0)
	avatar._active_tween.custom_step(sample_time)
	avatar._active_tween.pause()


func _add_rect(parent: Node, rect: Rect2, color: Color, z_index: int) -> void:
	var polygon := Polygon2D.new()
	polygon.polygon = PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
	polygon.color = color
	polygon.z_index = z_index
	parent.add_child(polygon)
