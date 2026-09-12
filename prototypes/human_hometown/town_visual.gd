extends Node2D
## One cached painted environment; camera movement changes only its transform.
const Town = preload("res://prototypes/human_hometown/town.gd")
var scenery: Sprite2D
var spec: Dictionary = Town.SPEC
func _ready() -> void:
	scenery = Sprite2D.new()
	scenery.texture = load(spec.art)
	scenery.centered = false
	var factor := float(spec.width)/scenery.texture.get_width()
	scenery.scale = Vector2.ONE*factor
	# Match the painted front edge of the stone road to the gameplay floor.
	scenery.position = Vector2(0,480-float(spec.width)/3.0*.73)
	add_child(scenery)
