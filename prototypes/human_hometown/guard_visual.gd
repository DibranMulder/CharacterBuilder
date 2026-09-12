extends Node2D
## Dedicated veteran guard sprites; no player avatar rig or per-frame rebuilds.
var variant := 0
var sprite: Sprite2D
func _ready() -> void:
	var source: Texture2D = load("res://assets/npcs/wendmere/guards_keyed.png")
	var half := source.get_width()/2.0
	var atlas := AtlasTexture.new()
	atlas.atlas = source
	atlas.region = Rect2(half*variant,0,half,source.get_height())
	sprite = Sprite2D.new()
	sprite.texture = atlas
	sprite.centered = false
	var factor := 192.0/(source.get_height()*.82)
	sprite.scale = Vector2.ONE*factor
	sprite.position = Vector2(-half*.5,-source.get_height()*.955)*factor
	var key := ShaderMaterial.new()
	key.shader = preload("res://prototypes/training_clearing/pouch_art.gdshader")
	sprite.material = key
	add_child(sprite)
func _draw() -> void:
	draw_set_transform(Vector2(0,-2),0,Vector2(1,.12))
	draw_circle(Vector2.ZERO,61,Color(0,0,0,.22))
