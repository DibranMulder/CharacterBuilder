class_name BaseAnatomyVisual
extends Node2D

# Deep sprite seam for authored identity/anatomy. Character construction asks for
# a race, part, and display size; atlas choice, crop geometry, view switching,
# source-background cleanup, and fallback state remain private to this module.

const EXTREMITY_ATLAS := preload("res://assets/base_sprites/extremities.png")
const BOGKIN_EXTREMITY_ATLAS := preload("res://assets/base_sprites/bogkin_extremities_storybook_v1.png")
const FROST_TROLL_EXTREMITY_ATLAS := preload("res://assets/base_sprites/frost_troll_extremities.png")
const CENTAUR_TAIL_TEXTURE := preload("res://assets/base_sprites/centaur_tail.png")
const CENTAUR_TAIL_BACK_TEXTURE := preload("res://assets/base_sprites/centaur_tail_back.png")
const CENTAUR_TAIL_BACK_REGION := Rect2(350,135,420,1140)

const SHARED_ANATOMY_TEXTURES := {
	"torso": preload("res://assets/base_sprites/anatomy_torso_storybook_v2.png"),
	"upper_arm": preload("res://assets/base_sprites/anatomy_upper_arm_storybook_v2.png"),
	"forearm": preload("res://assets/base_sprites/anatomy_forearm_storybook_v2.png"),
	"thigh": preload("res://assets/base_sprites/anatomy_thigh_storybook_v2.png"),
	"shin": preload("res://assets/base_sprites/anatomy_shin_storybook_v2.png"),
}

const FROST_TROLL_ANATOMY_TEXTURES := {
	"torso": preload("res://assets/base_sprites/frost_troll_anatomy_torso_storybook_v2.png"),
	"upper_arm": preload("res://assets/base_sprites/frost_troll_anatomy_upper_arm_storybook_v2.png"),
	"forearm": preload("res://assets/base_sprites/frost_troll_anatomy_forearm_storybook_v2.png"),
	"thigh": preload("res://assets/base_sprites/frost_troll_anatomy_thigh_storybook_v2.png"),
	"shin": preload("res://assets/base_sprites/frost_troll_anatomy_shin_storybook_v2.png"),
}

const CENTAUR_EQUINE_TEXTURES := {
	"horse_body": preload("res://assets/base_sprites/centaur_horse_body_storybook.png"),
	"horse_body_back": preload("res://assets/base_sprites/centaur_horse_body_back_storybook.png"),
	"horse_neck": preload("res://assets/base_sprites/centaur_horse_neck_storybook.png"),
	"horse_neck_back": preload("res://assets/base_sprites/centaur_horse_neck_back_storybook.png"),
	"horse_upper_leg": preload("res://assets/base_sprites/centaur_horse_upper_leg_storybook.png"),
	"horse_shin": preload("res://assets/base_sprites/centaur_horse_shin_storybook.png"),
}

const HEAD_TEXTURES := {
	"bogkin": preload("res://assets/base_sprites/bogkin_heads.png"),
	"human": preload("res://assets/base_sprites/human_heads.png"),
	"centaur": preload("res://assets/base_sprites/centaur_heads_v2.png"),
	"fae": preload("res://assets/base_sprites/fae_heads.png"),
	"frost_troll": preload("res://assets/base_sprites/frost_troll_heads_v2.png"),
	"goblin": preload("res://assets/base_sprites/goblin_heads.png"),
	"duneborn": preload("res://assets/base_sprites/duneborn_heads_v3.png"),
	"frostling": preload("res://assets/base_sprites/frostling_heads_v3.png"),
}

const HEAD_REGIONS := {
	"bogkin": {"front": Rect2(69,404,530,481), "back": Rect2(691,407,487,482)},
	"human": {"front": Rect2(94,346,504,531), "back": Rect2(663,345,506,531)},
	"centaur": {"front": Rect2(62,306,580,620), "back": Rect2(665,320,535,640)},
	"fae": {"front": Rect2(14,364,605,495), "back": Rect2(672,365,568,515)},
	"frost_troll": {"front": Rect2(65,332,527,592), "back": Rect2(653,325,554,557)},
	"goblin": {"front": Rect2(14,343,606,552), "back": Rect2(647,343,594,545)},
	"duneborn": {"front": Rect2(65,270,555,710), "back": Rect2(675,275,535,710)},
	"frostling": {"front": Rect2(55,285,575,650), "back": Rect2(660,290,555,650)},
}

const EXTREMITY_REGIONS := {
	"hand_open": Rect2(175,320,285,260),
	"hand_grip": Rect2(585,340,260,245),
	"hand_grip_back": Rect2(710,35,300,238),
	"foot": Rect2(980,335,300,255),
	"hoof": Rect2(1380,320,230,280),
}

const FROST_TROLL_EXTREMITY_REGIONS := {
	"hand_open": Rect2(20,470,405,310),
	"hand_grip": Rect2(455,480,335,300),
	"hand_grip_back": Rect2(425,35,405,392),
	# Crop through the upright ankle below the generated oval opening. The top
	# edge becomes a flat 2D shin seam instead of presenting a hollow 3D socket.
	"foot": Rect2(810,535,425,260),
}

const BOGKIN_EXTREMITY_REGIONS := {
	"hand_open": Rect2(100,10,580,500),
	"hand_grip": Rect2(820,90,470,400),
	"hand_grip_back": Rect2(140,515,480,410),
	"foot": Rect2(820,540,650,460),
}

# Image generation followed the requested direction for every race except the
# Bogkin. Keep that source-specific correction inside the atlas adapter so the
# shared rig and facing interface remain uniform.
const FLIPPED_FRONT_HEADS := {"bogkin": true}
# Source crops do not all end at the same anatomical point. The centaur sheet's
# painted neck ends slightly high, so lower it enough to overlap the torso seam.
const HEAD_VERTICAL_ADJUSTMENTS := {"centaur": 3.0}
const SHARED_ANATOMY_TONE_RANGE := Vector2(0.42,1.12)

var race_id := "human"
var part_id := "head"
var target_size := Vector2(52,52)
var back_view := false
var horizontal_flip := false
var _sprite: Sprite2D
var _available := false


func setup(p_race_id: String, p_part_id: String, p_target_size: Vector2, p_back_view := false) -> BaseAnatomyVisual:
	race_id = p_race_id
	part_id = p_part_id
	target_size = p_target_size
	back_view = p_back_view
	_build_sprite()
	return self


func has_sprite() -> bool:
	return _available


func set_back_view(enabled: bool) -> void:
	if back_view == enabled:
		return
	back_view = enabled
	if part_id in ["head","horse_tail","horse_body","horse_neck"]:
		_build_sprite()


func set_part(p_part_id: String) -> void:
	if part_id == p_part_id:
		return
	part_id = p_part_id
	_build_sprite()


func set_horizontal_flip(enabled: bool) -> void:
	horizontal_flip = enabled
	if _sprite:
		_sprite.flip_h = horizontal_flip or (part_id == "head" and not back_view and FLIPPED_FRONT_HEADS.get(race_id,false))


func _build_sprite() -> void:
	if _sprite:
		remove_child(_sprite)
		_sprite.queue_free()
	_sprite = Sprite2D.new()
	_sprite.name = "Sprite"
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	add_child(_sprite)

	var source: Texture2D
	var region := Rect2()
	var key_mode := 0
	if part_id == "head":
		var view := "back" if back_view else "front"
		if HEAD_TEXTURES.has(race_id):
			source = HEAD_TEXTURES[race_id]
			region = HEAD_REGIONS[race_id][view]
			key_mode = 1
	elif part_id == "horse_tail":
		source = CENTAUR_TAIL_BACK_TEXTURE if back_view else CENTAUR_TAIL_TEXTURE
		region = CENTAUR_TAIL_BACK_REGION if back_view else Rect2(Vector2.ZERO,source.get_size())
		key_mode = 1 if back_view else 0
	elif race_id == "centaur" and part_id in ["horse_body","horse_neck"]:
		var equine_view_id := "%s_back" % part_id if back_view else part_id
		source = CENTAUR_EQUINE_TEXTURES[equine_view_id]
		region = Rect2(Vector2.ZERO,source.get_size())
	elif race_id == "centaur" and CENTAUR_EQUINE_TEXTURES.has(part_id):
		source = CENTAUR_EQUINE_TEXTURES[part_id]
		region = Rect2(Vector2.ZERO,source.get_size())
	elif race_id == "frost_troll" and FROST_TROLL_ANATOMY_TEXTURES.has(part_id):
		source = FROST_TROLL_ANATOMY_TEXTURES[part_id]
		region = Rect2(Vector2.ZERO,source.get_size())
		key_mode = 1
	elif SHARED_ANATOMY_TEXTURES.has(part_id):
		source = SHARED_ANATOMY_TEXTURES[part_id]
		region = Rect2(Vector2.ZERO,source.get_size())
	else:
		if race_id == "bogkin" and BOGKIN_EXTREMITY_REGIONS.has(part_id):
			source = BOGKIN_EXTREMITY_ATLAS
			region = BOGKIN_EXTREMITY_REGIONS[part_id]
		elif race_id == "frost_troll" and FROST_TROLL_EXTREMITY_REGIONS.has(part_id):
			source = FROST_TROLL_EXTREMITY_ATLAS
			region = FROST_TROLL_EXTREMITY_REGIONS[part_id]
			key_mode = 1
		else:
			source = EXTREMITY_ATLAS
			region = EXTREMITY_REGIONS.get(part_id, Rect2())
			key_mode = 1

	_available = source != null and region.size.x > 0.0 and region.size.y > 0.0
	visible = _available
	if not _available:
		return

	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = region
	_sprite.texture = atlas
	_sprite.flip_h = horizontal_flip or (part_id == "head" and not back_view and FLIPPED_FRONT_HEADS.get(race_id,false))
	var fitted_anatomy := SHARED_ANATOMY_TEXTURES.has(part_id) or (race_id == "frost_troll" and FROST_TROLL_ANATOMY_TEXTURES.has(part_id)) or (race_id == "centaur" and CENTAUR_EQUINE_TEXTURES.has(part_id))
	if fitted_anatomy:
		# Cutout segments must fill their existing bone contract in both axes so
		# every race retains its authored silhouette and joint positions.
		var fitted_size := target_size
		if part_id == "horse_body" and back_view:
			# The climbing view is foreshortened down the spine; it must stack under
			# the humanoid torso rather than retain the side body's barrel width.
			fitted_size.x = target_size.y*1.08
		_sprite.scale = fitted_size / region.size
	else:
		var fit := minf(target_size.x / region.size.x, target_size.y / region.size.y)
		if part_id == "horse_tail" and back_view:
			fit *= 1.18
		_sprite.scale = Vector2.ONE * fit
	_sprite.position = _part_offset()
	var anatomy_tint: Color = CharacterCatalog.race(race_id).skin
	var authored_troll_extremity := race_id == "frost_troll" and FROST_TROLL_EXTREMITY_REGIONS.has(part_id)
	var authored_bogkin_extremity := race_id == "bogkin" and BOGKIN_EXTREMITY_REGIONS.has(part_id)
	var tint_strength := .92 if SHARED_ANATOMY_TEXTURES.has(part_id) and race_id != "frost_troll" else (.72 if part_id in ["hand_open","hand_grip","hand_grip_back","foot"] and not authored_troll_extremity and not authored_bogkin_extremity else 0.0)
	_sprite.material = _key_material(key_mode,anatomy_tint,tint_strength)


func _part_offset() -> Vector2:
	match part_id:
		"head": return Vector2(0,-target_size.y*.32+HEAD_VERTICAL_ADJUSTMENTS.get(race_id,0.0))
		# The side-tail sheet is right-edge rooted; its node placement performs
		# that alignment. The rear sheet is centered and needs to cancel it.
		"horse_tail": return Vector2(target_size.x*.46,target_size.y*.30) if back_view else Vector2.ZERO
		"hand_open", "hand_grip", "hand_grip_back": return Vector2(target_size.x*.12,target_size.y*.08)
		"foot", "hoof": return Vector2(target_size.x*.22,target_size.y*.04)
	return Vector2.ZERO


func _key_material(mode: int, tint: Color, tint_strength: float) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform int key_mode = 0;
uniform vec4 anatomy_tint : source_color = vec4(1.0);
uniform float tint_strength = 0.0;
uniform vec2 anatomy_tone_range = vec2(0.42, 1.12);

void fragment() {
	vec4 sample = texture(TEXTURE, UV);
	float alpha = sample.a;
	if (key_mode == 1) {
		// Generated atlases contain several antialiased blends between the
		// painted edge and their magenta field, not one exact key color. Measure
		// magenta dominance so all those bands contribute fractional coverage.
		float magenta_spill = max(min(sample.r,sample.b)-sample.g,0.0);
		float red_blue_balance = 1.0-abs(sample.r-sample.b);
		float key_strength = magenta_spill*red_blue_balance;
		float coverage = 1.0-smoothstep(0.08,0.34,key_strength);
		alpha *= coverage;
		// Remove the key contribution from surviving antialiased edge pixels.
		// Warm-brown ink, skin, hair, and blue cloth have little balanced R+B
		// dominance and therefore retain their authored color.
		float despill = smoothstep(0.025,0.30,key_strength)*0.94;
		sample.r = max(sample.r-magenta_spill*despill,0.0);
		sample.b = max(sample.b-magenta_spill*despill,0.0);
	}
	float luminance = dot(sample.rgb, vec3(0.299, 0.587, 0.114));
	// The neutral source is deliberately pale so it can accept every lineage
	// hue, but a linear bright remap compressed its soft painted shadows into a
	// flat mannequin tone. Expand the useful midrange into deeper occlusion and
	// restrained highlights before applying skin color.
	float modeled_luminance = smoothstep(0.35, 0.98, luminance);
	vec3 tinted = anatomy_tint.rgb * mix(anatomy_tone_range.x, anatomy_tone_range.y, modeled_luminance);
	// Keep the generated warm-brown ink intact while recoloring the painted
	// interior. This avoids skin-colored outlines on saturated lineages.
	float interior_mix = tint_strength * smoothstep(0.18, 0.48, luminance);
	COLOR = vec4(mix(sample.rgb, tinted, interior_mix), alpha);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("key_mode", mode)
	material.set_shader_parameter("anatomy_tint", tint)
	material.set_shader_parameter("tint_strength", tint_strength)
	material.set_shader_parameter("anatomy_tone_range",SHARED_ANATOMY_TONE_RANGE)
	return material
