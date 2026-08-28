class_name BaseAnatomyVisual
extends Node2D

# Deep sprite seam for authored identity/anatomy. Character construction asks for
# a race, part, and display size; atlas choice, crop geometry, view switching,
# source-background cleanup, and fallback state remain private to this module.

const EXTREMITY_ATLAS := preload("res://assets/base_sprites/extremities.png")

const HEAD_TEXTURES := {
	"bogkin": preload("res://assets/base_sprites/bogkin_heads.png"),
	"human": preload("res://assets/base_sprites/human_heads.png"),
	"centaur": preload("res://assets/base_sprites/centaur_heads.png"),
	"fae": preload("res://assets/base_sprites/fae_heads.png"),
	"frost_troll": preload("res://assets/base_sprites/frost_troll_heads.png"),
	"goblin": preload("res://assets/base_sprites/goblin_heads.png"),
	"duneborn": preload("res://assets/base_sprites/duneborn_heads.png"),
	"frostling": preload("res://assets/base_sprites/frostling_heads.png"),
}

const HEAD_REGIONS := {
	"bogkin": {"front": Rect2(69,404,530,481), "back": Rect2(691,407,487,482)},
	"human": {"front": Rect2(94,346,504,531), "back": Rect2(663,345,506,531)},
	"centaur": {"front": Rect2(62,306,565,605), "back": Rect2(627,333,566,618)},
	"fae": {"front": Rect2(14,364,605,495), "back": Rect2(672,365,568,515)},
	"frost_troll": {"front": Rect2(51,325,560,566), "back": Rect2(663,338,547,581)},
	"goblin": {"front": Rect2(14,343,606,552), "back": Rect2(647,343,594,545)},
	"duneborn": {"front": Rect2(143,321,456,560), "back": Rect2(724,324,402,592)},
	"frostling": {"front": Rect2(80,396,505,466), "back": Rect2(646,396,513,465)},
}

const EXTREMITY_REGIONS := {
	"hand_open": Rect2(175,320,285,260),
	"hand_grip": Rect2(585,340,260,245),
	"foot": Rect2(980,335,300,255),
	"hoof": Rect2(1380,320,230,280),
}

# Image generation followed the requested direction for every race except the
# Bogkin. Keep that source-specific correction inside the atlas adapter so the
# shared rig and facing interface remain uniform.
const FLIPPED_FRONT_HEADS := {"bogkin": true}

var race_id := "human"
var part_id := "head"
var target_size := Vector2(52,52)
var back_view := false
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
	if part_id == "head":
		_build_sprite()


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
	_sprite.flip_h = part_id == "head" and not back_view and FLIPPED_FRONT_HEADS.get(race_id,false)
	var fit := minf(target_size.x / region.size.x, target_size.y / region.size.y)
	_sprite.scale = Vector2.ONE * fit
	_sprite.position = _part_offset()
	var anatomy_tint: Color = CharacterCatalog.race(race_id).skin
	var tint_strength := .72 if part_id in ["hand_open","hand_grip","foot"] else 0.0
	_sprite.material = _key_material(key_mode,anatomy_tint,tint_strength)


func _part_offset() -> Vector2:
	match part_id:
		"head": return Vector2(0,-target_size.y*.32)
		"hand_open", "hand_grip": return Vector2(target_size.x*.12,target_size.y*.08)
		"foot", "hoof": return Vector2(target_size.x*.22,target_size.y*.04)
	return Vector2.ZERO


func _key_material(mode: int, tint: Color, tint_strength: float) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
uniform int key_mode = 0;
uniform vec4 anatomy_tint : source_color = vec4(1.0);
uniform float tint_strength = 0.0;

void fragment() {
	vec4 sample = texture(TEXTURE, UV);
	float alpha = sample.a;
	if (key_mode == 1) {
		vec3 key = vec3(0.925, 0.055, 0.925);
		float distance_from_key = distance(sample.rgb, key);
		alpha *= smoothstep(0.10, 0.24, distance_from_key);
	}
	float luminance = dot(sample.rgb, vec3(0.299, 0.587, 0.114));
	vec3 tinted = anatomy_tint.rgb * mix(0.62, 1.32, luminance);
	COLOR = vec4(mix(sample.rgb, tinted, tint_strength), alpha);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("key_mode", mode)
	material.set_shader_parameter("anatomy_tint", tint)
	material.set_shader_parameter("tint_strength", tint_strength)
	return material
