extends SceneTree

const BaseAnatomy := preload("res://src/base_anatomy_visual.gd")


func _initialize() -> void:
	for race_id in CharacterCatalog.race_ids():
		var head: BaseAnatomyVisual = BaseAnatomy.new().setup(race_id,"head",Vector2(64,64))
		assert(head.has_sprite(), "%s has no authored head sprite" % race_id)
		var front_texture: Texture2D = head.get_node("Sprite").texture
		head.set_back_view(true)
		var back_texture: Texture2D = head.get_node("Sprite").texture
		assert(front_texture != back_texture, "%s front and rear head views did not switch" % race_id)
		head.free()

	for part_id in ["hand_open","hand_grip","foot","hoof"]:
		var extremity: BaseAnatomyVisual = BaseAnatomy.new().setup("human",part_id,Vector2(30,30))
		assert(extremity.has_sprite(), "%s has no authored base sprite" % part_id)
		extremity.free()

	print("PASS: 8 front/rear sprite heads and shared base extremities")
	quit()
