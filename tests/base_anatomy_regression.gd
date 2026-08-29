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

	for redesigned_race in ["frost_troll","duneborn","frostling"]:
		var source_path: String = BaseAnatomy.HEAD_TEXTURES[redesigned_race].resource_path
		assert(source_path.ends_with("_v2.png"), "%s is not using its reference-matched head sheet" % redesigned_race)
		var profile := CharacterCatalog.race(redesigned_race)
		assert(profile.has("head_sprite_scale"), "%s has no authored head scale" % redesigned_race)
	assert(CharacterCatalog.race("fae").visual.body_shape == "slender", "Fae lost its reference-matched slender body")
	assert(CharacterCatalog.race("fae").topology == "winged", "Fae lost its anatomical wings")
	assert(CharacterCatalog.race("frost_troll").extremity_scale >= 1.8, "Frost Troll hands and feet are no longer oversized")
	assert(CharacterCatalog.race("frost_troll").torso.x >= 108.0, "Frost Troll lost its broad upper torso")
	assert(CharacterCatalog.race("frost_troll").shoulder_spread >= .40, "Frost Troll shoulders are too narrow")
	assert(CharacterCatalog.race("frost_troll").armor_width_scale > 1.4, "Frost Troll armor no longer fits its broad chest")
	assert(BaseAnatomy.FROST_TROLL_EXTREMITY_REGIONS.foot.position.y >= 530.0, "Frost Troll foot exposes its generated 3D ankle opening")
	for troll_part in ["hand_open","hand_grip","foot"]:
		var troll_extremity: BaseAnatomyVisual = BaseAnatomy.new().setup("frost_troll",troll_part,Vector2(48,42))
		var atlas_texture: AtlasTexture = troll_extremity.get_node("Sprite").texture
		assert(atlas_texture.atlas.resource_path.ends_with("frost_troll_extremities.png"), "%s still uses human anatomy" % troll_part)
		troll_extremity.free()

	for part_id in ["hand_open","hand_grip","foot","hoof"]:
		var extremity: BaseAnatomyVisual = BaseAnatomy.new().setup("human",part_id,Vector2(30,30))
		assert(extremity.has_sprite(), "%s has no authored base sprite" % part_id)
		extremity.free()

	var centaur_tail: BaseAnatomyVisual = BaseAnatomy.new().setup("centaur","horse_tail",Vector2(62,66))
	assert(centaur_tail.has_sprite(), "centaur has no authored horse tail sprite")
	var side_tail_texture: Texture2D = centaur_tail.get_node("Sprite").texture
	centaur_tail.set_back_view(true)
	var climbing_tail_texture: Texture2D = centaur_tail.get_node("Sprite").texture
	assert(side_tail_texture != climbing_tail_texture, "centaur tail does not switch to its rear climbing sprite")
	centaur_tail.free()

	print("PASS: 8 front/rear sprite heads, shared base extremities, and side/rear centaur tails")
	quit()
