extends TextureRect
## Runtime atlas regions preserve the supplied design's painted icon language.
const BOARD = preload("res://designs/disciplines-talent-tree.png")
const CENTERS := {
	"attack":Vector2(61,309),"strength":Vector2(61,349),"defense":Vector2(61,389),
	"agility":Vector2(61,431),"stamina":Vector2(61,472),"focus":Vector2(61,554),
	"willpower":Vector2(61,591),"arcana":Vector2(61,630),"survival":Vector2(61,697),
	"gathering":Vector2(61,736),"crafting":Vector2(61,776),"exploration":Vector2(61,816),
	"health":Vector2(1267,130),"mana":Vector2(1545,129),
}

func _init() -> void:
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mask := Shader.new()
	mask.code = "shader_type canvas_item; uniform vec2 uv_origin; uniform vec2 uv_size; void fragment(){vec2 local_uv=(UV-uv_origin)/uv_size; COLOR=texture(TEXTURE,UV)*COLOR; COLOR.a*=1.0-smoothstep(0.47,0.5,distance(local_uv,vec2(0.5)));}"
	var paint := ShaderMaterial.new()
	paint.shader = mask
	material = paint

func discipline(id: String) -> void:
	var atlas := AtlasTexture.new()
	atlas.atlas = BOARD
	atlas.region = Rect2(CENTERS.get(id,CENTERS.attack)-Vector2(22,22),Vector2(44,44))
	texture = atlas
	_set_region(atlas)

func ability(skill: Dictionary) -> void:
	var tile = preload("res://src/ui/skill_tile.gd")
	var atlas := AtlasTexture.new()
	atlas.atlas = preload("res://assets/ui/skill_icons.png")
	atlas.region = tile.REGIONS[tile.ICONS.get(skill.kind,11)]
	texture = atlas
	_set_region(atlas)

func _set_region(atlas: AtlasTexture) -> void:
	material.set_shader_parameter("uv_origin",atlas.region.position/atlas.atlas.get_size())
	material.set_shader_parameter("uv_size",atlas.region.size/atlas.atlas.get_size())
