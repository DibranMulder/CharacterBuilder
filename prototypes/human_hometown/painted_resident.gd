extends Node2D
## Dedicated construct and ambient wildlife sprites, cropped non-destructively by the atlas.
var kind := "guardian"
var home := 0.0
var home_y := 480.0
var elapsed := 0.0
var sprite: Sprite2D
func _ready() -> void:
	var texture: Texture2D = load("res://assets/npcs/wendmere/"+(kind if kind in ["guardian","gargoyle"] else "wildlife")+".png")
	var region := Rect2i(Vector2i.ZERO,texture.get_size())
	if kind in ["puffkin","otter"]:
		region.size.x /= 2
		if kind == "otter": region.position.x = region.size.x
	var bounds := texture.get_image().get_region(region).get_used_rect()
	bounds.position += region.position
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = bounds
	sprite = Sprite2D.new()
	sprite.texture = atlas
	sprite.centered = false
	var height := 270.0 if kind == "guardian" else (95.0 if kind == "gargoyle" else 62.0)
	sprite.scale = Vector2.ONE*height/bounds.size.y
	sprite.position = Vector2(-bounds.size.x*.5,-bounds.size.y)*sprite.scale.x
	add_child(sprite)
	z_index = 90
func present(camera: Vector2, delta: float) -> void:
	elapsed += delta
	position = Vector2(home+(0 if kind == "gargoyle" else sin(elapsed*.4)*45),home_y)-camera
	if kind == "puffkin": sprite.position.y = -62+sin(elapsed*2)*1.5
func _draw() -> void:
	draw_set_transform(Vector2(0,-2),0,Vector2(1,.18))
	draw_circle(Vector2.ZERO,55 if kind == "guardian" else 28,Color(0,0,0,.22))
