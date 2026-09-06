extends SceneTree

const BaseAnatomy := preload("res://src/base_anatomy_visual.gd")
const Avatar := preload("res://src/modular_character.gd")
const Part := preload("res://src/part_visual.gd")


func _initialize() -> void:
	assert(BaseAnatomy.SHARED_ANATOMY_TONE_RANGE == Vector2(.42,1.12), "shared anatomy lost its modeled shadow/highlight transfer")
	for race_id in CharacterCatalog.race_ids():
		var head: BaseAnatomyVisual = BaseAnatomy.new().setup(race_id,"head",Vector2(64,64))
		assert(head.has_sprite(), "%s has no authored head sprite" % race_id)
		var head_material: ShaderMaterial = head.get_node("Sprite").material
		assert(head_material != null and "magenta_spill" in head_material.shader.code and "despill" in head_material.shader.code, "%s head keying does not remove antialiased magenta spill" % race_id)
		var front_texture: Texture2D = head.get_node("Sprite").texture
		head.set_back_view(true)
		var back_texture: Texture2D = head.get_node("Sprite").texture
		assert(front_texture != back_texture, "%s front and rear head views did not switch" % race_id)
		head.free()

	var expected_head_versions := {"frost_troll":"_v2.png", "centaur":"_v2.png", "duneborn":"_v3.png", "frostling":"_v3.png"}
	for redesigned_race in expected_head_versions:
		var source_path: String = BaseAnatomy.HEAD_TEXTURES[redesigned_race].resource_path
		assert(source_path.ends_with(expected_head_versions[redesigned_race]), "%s is not using its style-matched head sheet" % redesigned_race)
		if redesigned_race in ["frost_troll","duneborn","frostling"]:
			assert(CharacterCatalog.race(redesigned_race).has("head_sprite_scale"), "%s has no authored head scale" % redesigned_race)
	assert(CharacterCatalog.race("fae").visual.body_shape == "slender", "Fae lost its reference-matched slender body")
	assert(CharacterCatalog.race("fae").topology == "winged", "Fae lost its anatomical wings")
	assert(CharacterCatalog.race("fae").scale >= CharacterCatalog.race("human").scale, "Fae must retain the Human-height poised silhouette from the light-lineage reference")
	assert(CharacterCatalog.race("frost_troll").extremity_scale >= 1.8, "Frost Troll hands and feet are no longer oversized")
	assert(CharacterCatalog.race("frost_troll").torso.x >= 108.0, "Frost Troll lost its broad upper torso")
	assert(CharacterCatalog.race("frost_troll").shoulder_spread >= .40, "Frost Troll shoulders are too narrow")
	assert(CharacterCatalog.race("frost_troll").armor_width_scale > 1.4, "Frost Troll armor no longer fits its broad chest")
	assert(Avatar.ANATOMY_JOINT_OVERLAP_RATIO >= .28 and Avatar.ANATOMY_JOINT_OVERLAP_MAX >= 6.0, "shared painted limbs no longer overlap deeply enough to hide paired joint caps")
	assert(Avatar.FROST_TROLL_JOINT_OVERLAP_RATIO >= .36 and Avatar.FROST_TROLL_JOINT_OVERLAP_MAX >= 9.0, "Frost Troll's broad painted limbs no longer receive their deeper joint seam")
	var bogkin_profile: Dictionary = CharacterCatalog.race("bogkin")
	var bogkin_to_human_scale: float = float(bogkin_profile.scale)/float(CharacterCatalog.race("human").scale)
	assert(bogkin_to_human_scale >= .75 and bogkin_to_human_scale <= .85, "Bogkin global scale no longer matches the compact frogfolk-to-Human reference relationship")
	assert(bogkin_profile.torso.x >= 60.0 and bogkin_profile.torso.y <= 56.0, "Bogkin lost its broad, squat frogfolk torso")
	assert(bogkin_profile.leg <= 40.0 and bogkin_profile.leg_width >= 22.0, "Bogkin legs no longer read as compact spring limbs")
	assert(bogkin_profile.extremity_scale >= 1.2, "Bogkin webbed hands and feet are no longer oversized")
	assert(bogkin_profile.armor_width_scale > 1.1, "Bogkin armor no longer follows its broad torso silhouette")
	assert(CharacterCatalog.reference_loadout("bogkin").boots == "none", "Bogkin reference loadout must expose its authored webbed feet")
	assert(CharacterCatalog.race("frostling").scale > CharacterCatalog.race("goblin").scale, "Frostling must remain visibly taller than the compact Goblin reference silhouette")
	assert(CharacterCatalog.reference_loadout("duneborn").boots == "leather", "Duneborn reference loadout must retain the concept's brown travel boots")
	assert(BaseAnatomy.FROST_TROLL_EXTREMITY_REGIONS.foot.position.y >= 530.0, "Frost Troll foot exposes its generated 3D ankle opening")
	for troll_part in ["hand_open","hand_grip","hand_grip_back","foot"]:
		var troll_extremity: BaseAnatomyVisual = BaseAnatomy.new().setup("frost_troll",troll_part,Vector2(48,42))
		var atlas_texture: AtlasTexture = troll_extremity.get_node("Sprite").texture
		assert(atlas_texture.atlas.resource_path.ends_with("frost_troll_extremities.png"), "%s still uses human anatomy" % troll_part)
		assert(troll_extremity.get_node("Sprite").material.get_shader_parameter("key_mode") == 1, "Frost Troll %s no longer removes its chroma key" % troll_part)
		troll_extremity.free()
	for bogkin_part in ["hand_open","hand_grip","hand_grip_back","foot"]:
		var bogkin_extremity: BaseAnatomyVisual = BaseAnatomy.new().setup("bogkin",bogkin_part,Vector2(48,42))
		assert(bogkin_extremity.has_sprite(), "Bogkin %s has no authored webbed anatomy" % bogkin_part)
		var bogkin_sprite: Sprite2D = bogkin_extremity.get_node("Sprite")
		var bogkin_texture: AtlasTexture = bogkin_sprite.texture
		assert(bogkin_texture.atlas.resource_path.ends_with("bogkin_extremities_storybook_v1.png"), "Bogkin %s still uses shared human anatomy" % bogkin_part)
		assert(bogkin_texture.region == BaseAnatomy.BOGKIN_EXTREMITY_REGIONS[bogkin_part], "Bogkin %s uses the wrong atlas region" % bogkin_part)
		assert(bogkin_sprite.material.get_shader_parameter("key_mode") == 0, "Bogkin %s should preserve its true alpha" % bogkin_part)
		bogkin_extremity.free()
	for troll_part in ["torso","upper_arm","forearm","thigh","shin"]:
		var troll_anatomy: BaseAnatomyVisual = BaseAnatomy.new().setup("frost_troll",troll_part,Vector2(48,52))
		assert(troll_anatomy.has_sprite(), "Frost Troll %s has no authored painted anatomy" % troll_part)
		var troll_anatomy_texture: AtlasTexture = troll_anatomy.get_node("Sprite").texture
		assert(troll_anatomy_texture.atlas.resource_path.ends_with("frost_troll_anatomy_%s_storybook_v2.png" % troll_part), "Frost Troll %s still uses the curved or mismatched anatomy" % troll_part)
		assert(troll_anatomy.get_node("Sprite").material.get_shader_parameter("key_mode") == 1, "Frost Troll %s no longer removes its chroma key" % troll_part)
		troll_anatomy.free()
	var troll_avatar := Avatar.new()
	root.add_child(troll_avatar)
	troll_avatar.configure("frost_troll",{})
	for troll_bone in ["torso","left_arm","left_forearm","left_leg","left_shin"]:
		var troll_part_visual: PartVisual = troll_avatar._bones[troll_bone].get_child(0)
		assert(troll_part_visual.authored_skin, "Frost Troll %s still draws procedural anatomy" % troll_bone)
		assert(troll_part_visual.has_node("AuthoredAnatomy"), "Frost Troll %s did not attach its authored cutout" % troll_bone)
	troll_avatar.configure("centaur",{})
	var centaur_torso: PartVisual = troll_avatar._bones.torso.get_child(0)
	var horse_body: PartVisual = troll_avatar._bones.horse_body.get_child(0)
	assert(centaur_torso.authored_skin, "Centaur humanoid torso lost its painted cutout")
	assert(horse_body.authored_skin, "Centaur horse body still draws procedural anatomy")
	var tail_anatomy: BaseAnatomyVisual = troll_avatar._horse_tail_base
	var body_anatomy: BaseAnatomyVisual = troll_avatar._bones.horse_body.find_child("AuthoredAnatomy",true,false)
	var tail_bounds := _sprite_opaque_global_bounds(tail_anatomy.get_node("Sprite"))
	var body_bounds := _sprite_opaque_global_bounds(body_anatomy.get_node("Sprite"))
	var rump_overlap := tail_bounds.intersection(body_bounds)
	if rump_overlap.size.x < 10.0 or rump_overlap.size.y < 10.0:
		push_error("Centaur tail is detached from the side-view rump: overlap=%s tail=%s body=%s" % [rump_overlap,tail_bounds,body_bounds])
		quit(1)
		return
	var painted_overlap := _sprite_opaque_overlap_count(tail_anatomy.get_node("Sprite"),body_anatomy.get_node("Sprite"))
	if painted_overlap < 20:
		push_error("Centaur tail has no painted-pixel attachment to the side-view rump: opaque overlap=%d" % painted_overlap)
		quit(1)
		return
	for horse_bone in ["horse_neck","horse_leg_0","horse_shin_0"]:
		var equine_part: PartVisual = troll_avatar._bones[horse_bone].get_child(0)
		assert(equine_part.authored_skin, "Centaur %s still draws procedural anatomy" % horse_bone)
	troll_avatar.configure("fae",{})
	assert(Part.STORYBOOK_FAE_WING_RIGHT.get_size() == Vector2(84,80), "Fae right wing lost its authored runtime dimensions")
	assert(Part.STORYBOOK_FAE_WING_LEFT.get_size() == Vector2(84,80), "Fae left wing lost its authored runtime dimensions")
	for wing_texture in [Part.STORYBOOK_FAE_WING_RIGHT,Part.STORYBOOK_FAE_WING_LEFT]:
		var wing_image: Image = wing_texture.get_image()
		assert(wing_image.get_pixel(0,0).a < .02 and wing_image.get_pixel(wing_image.get_width()-1,0).a < .02, "Fae wing canvas corners are not genuinely transparent")
	for wing_id in ["left_wing","right_wing"]:
		var fae_wing: PartVisual = troll_avatar._bones[wing_id]
		assert(absf(fae_wing.size.x) >= 78.0 and fae_wing.size.y >= 76.0, "Fae %s lost its broad reference silhouette" % wing_id)
		assert(fae_wing.color.r > .85 and fae_wing.color.g > .85, "Fae %s is no longer a pale membrane" % wing_id)
		assert(fae_wing.self_modulate.a > .70 and fae_wing.self_modulate.a < .86, "Fae %s lost its translucent membrane treatment" % wing_id)
	assert(is_equal_approx(troll_avatar._bones.left_wing.rotation,-troll_avatar._bones.right_wing.rotation), "Fae authored wing rests are not mirrored")
	assert(absf(troll_avatar._bones.left_wing.rotation_degrees) >= 10.0, "Fae authored wings lost their resting cant")
	troll_avatar.free()

	for part_id in ["hand_open","hand_grip","hand_grip_back","foot","hoof"]:
		var extremity: BaseAnatomyVisual = BaseAnatomy.new().setup("human",part_id,Vector2(30,30))
		assert(extremity.has_sprite(), "%s has no authored base sprite" % part_id)
		extremity.free()

	for part_id in ["torso","upper_arm","forearm","thigh","shin"]:
		var anatomy: BaseAnatomyVisual = BaseAnatomy.new().setup("human",part_id,Vector2(30,50))
		assert(anatomy.has_sprite(), "%s has no authored painted anatomy" % part_id)
		var anatomy_texture: AtlasTexture = anatomy.get_node("Sprite").texture
		assert(anatomy_texture.atlas.resource_path.ends_with("anatomy_%s_storybook_v2.png" % part_id), "%s uses the wrong anatomy source" % part_id)
		var anatomy_material: ShaderMaterial = anatomy.get_node("Sprite").material
		assert(anatomy_material != null, "%s cannot receive lineage skin tint" % part_id)
		assert(anatomy_material.get_shader_parameter("anatomy_tone_range") == BaseAnatomy.SHARED_ANATOMY_TONE_RANGE, "%s lost the modeled skin tone range" % part_id)
		assert("modeled_luminance" in anatomy_material.shader.code, "%s reverted to flat linear skin recoloring" % part_id)
		anatomy.free()

	var sided_avatar := Avatar.new()
	root.add_child(sided_avatar)
	# Shared cutout orientation still applies to other humanoid lineages;
	# humans use continuous surfaces, covered by human_surface_regression.gd.
	sided_avatar.configure("fae",{
		"weapon":"none", "offhand":"none", "armor":"none", "pants":"none",
		"boots":"none", "head":"none", "back":"none", "accessory":"none",
	})
	for segment_pair in [["left_arm","right_arm"],["left_forearm","right_forearm"]]:
		var left_sprite: Sprite2D = sided_avatar._bones[segment_pair[0]].find_child("Sprite",true,false)
		var right_sprite: Sprite2D = sided_avatar._bones[segment_pair[1]].find_child("Sprite",true,false)
		assert(not left_sprite.flip_h, "%s must retain the screen-right source orientation" % segment_pair[0])
		assert(right_sprite.flip_h, "%s must mirror the source so its painted anatomy faces screen-left" % segment_pair[1])
	sided_avatar.free()

	var centaur_tail: BaseAnatomyVisual = BaseAnatomy.new().setup("centaur","horse_tail",Vector2(62,66))
	assert(centaur_tail.has_sprite(), "centaur has no authored horse tail sprite")
	var side_tail_texture: Texture2D = centaur_tail.get_node("Sprite").texture
	centaur_tail.set_back_view(true)
	var climbing_tail_texture: Texture2D = centaur_tail.get_node("Sprite").texture
	assert(side_tail_texture != climbing_tail_texture, "centaur tail does not switch to its rear climbing sprite")
	centaur_tail.free()
	for equine_part_id in ["horse_body","horse_neck"]:
		var equine_view: BaseAnatomyVisual = BaseAnatomy.new().setup("centaur",equine_part_id,Vector2(96,60))
		assert(equine_view.has_sprite(), "Centaur %s has no authored side sprite" % equine_part_id)
		var equine_side_texture: Texture2D = equine_view.get_node("Sprite").texture
		equine_view.set_back_view(true)
		var equine_back_texture: Texture2D = equine_view.get_node("Sprite").texture
		assert(equine_side_texture != equine_back_texture, "Centaur %s does not switch to its climbing-rear sprite" % equine_part_id)
		equine_view.free()
	for equine_limb_id in ["horse_upper_leg","horse_shin"]:
		var equine_limb: BaseAnatomyVisual = BaseAnatomy.new().setup("centaur",equine_limb_id,Vector2(18,34))
		assert(equine_limb.has_sprite(), "Centaur %s has no authored cutout" % equine_limb_id)
		equine_limb.free()

	print("PASS: 8 front/rear heads, painted articulated anatomy, extremities, and centaur tails")
	quit()


func _sprite_opaque_global_bounds(sprite: Sprite2D) -> Rect2:
	var image := sprite.texture.get_image()
	var min_pixel := Vector2i(image.get_width(),image.get_height())
	var max_pixel := Vector2i.ZERO
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x,y).a > .1:
				min_pixel.x = mini(min_pixel.x,x)
				min_pixel.y = mini(min_pixel.y,y)
				max_pixel.x = maxi(max_pixel.x,x+1)
				max_pixel.y = maxi(max_pixel.y,y+1)
	assert(max_pixel.x > min_pixel.x and max_pixel.y > min_pixel.y, "%s has no opaque pixels" % sprite.name)
	var texture_size := sprite.texture.get_size()
	var local_rect := Rect2(Vector2(min_pixel)-texture_size*.5,Vector2(max_pixel-min_pixel))
	var corners := [local_rect.position,Vector2(local_rect.end.x,local_rect.position.y),local_rect.end,Vector2(local_rect.position.x,local_rect.end.y)]
	var first: Vector2 = sprite.global_transform*corners[0]
	var bounds := Rect2(first,Vector2.ZERO)
	for corner in corners.slice(1):
		bounds = bounds.expand(sprite.global_transform*corner)
	return bounds


func _sprite_opaque_overlap_count(first: Sprite2D, second: Sprite2D) -> int:
	var first_image := first.texture.get_image()
	var second_image := second.texture.get_image()
	var first_size := Vector2(first_image.get_size())
	var second_size := Vector2(second_image.get_size())
	var second_inverse := second.global_transform.affine_inverse()
	var overlap := 0
	for y in first_image.get_height():
		for x in first_image.get_width():
			if first_image.get_pixel(x,y).a <= .1:
				continue
			var first_local := Vector2(x+.5,y+.5)-first_size*.5
			var second_local := second_inverse*(first.global_transform*first_local)
			var second_pixel := Vector2i(floor(second_local.x+second_size.x*.5),floor(second_local.y+second_size.y*.5))
			if second_pixel.x >= 0 and second_pixel.y >= 0 and second_pixel.x < second_image.get_width() and second_pixel.y < second_image.get_height() and second_image.get_pixelv(second_pixel).a > .1:
				overlap += 1
	return overlap
