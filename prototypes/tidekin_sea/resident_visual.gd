extends Node2D
## One baked viewport per resident, released with the map. No per-frame rig work.
var resident: Dictionary
func _ready() -> void:
	if resident.id == "nacre":
		var guardian := Sprite2D.new()
		guardian.texture = preload("res://assets/monsters/tidekin/reefsong_whalelet.png")
		guardian.scale = Vector2.ONE*(225.0/guardian.texture.get_height())
		guardian.position = Vector2(0,-130)
		add_child(guardian)
		return
	var viewport := SubViewport.new()
	viewport.size = Vector2i(320,340)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)
	var rig := preload("res://src/modular_character.gd").new()
	viewport.add_child(rig)
	rig.configure("bogkin",resident.gear)
	rig.stop_motion()
	rig.process_mode = Node.PROCESS_MODE_DISABLED
	rig.scale = Vector2.ONE*.9
	rig.position = Vector2(160,325)
	var sprite := Sprite2D.new()
	sprite.texture = viewport.get_texture()
	sprite.position = Vector2(0,-155)
	add_child(sprite)
