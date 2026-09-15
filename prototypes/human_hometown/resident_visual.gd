extends Node2D
const Art = preload("res://prototypes/human_hometown/resident_art.gd")
var resident_id := ""
var sprite: Sprite2D
func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = Art.texture(resident_id)
	sprite.material = Art.material()
	sprite.centered = false
	var dimensions := sprite.texture.get_size()
	var factor := Art.height(resident_id)/dimensions.y
	sprite.scale = Vector2.ONE*factor
	sprite.position = Vector2(-dimensions.x*.5,-dimensions.y*.98)*factor
	add_child(sprite)
func _draw() -> void:
	draw_set_transform(Vector2(0,-2),0,Vector2(1,.15))
	draw_circle(Vector2.ZERO,32,Color(0,0,0,.28))
