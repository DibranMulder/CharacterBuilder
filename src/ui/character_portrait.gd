extends Sprite2D
## Cached, circular head-and-shoulders rendering of the actual equipped rig.
const Rig = preload("res://src/modular_character.gd")
var viewport: SubViewport
var character: Node2D
var lineage := ""
var outfit := {}

func _ready() -> void:
	viewport = SubViewport.new()
	viewport.size = Vector2i(256,256)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	character = Rig.new()
	character.process_mode = Node.PROCESS_MODE_DISABLED
	viewport.add_child(character)
	texture = viewport.get_texture()
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; void fragment() { float d = distance(UV,vec2(0.5)); COLOR.a *= 1.0-smoothstep(0.487,0.498,d); }"
	var clipping := ShaderMaterial.new()
	clipping.shader = shader
	material = clipping
	scale = Vector2.ONE * (100.0/256.0)

func configure(race_id: String, loadout: Dictionary) -> void:
	if lineage == race_id and outfit == loadout:
		return
	lineage = race_id
	outfit = loadout.duplicate()
	character.scale = Vector2.ONE
	character.position = Vector2.ZERO
	character.configure(race_id,loadout.duplicate())
	character.set_facing(&"right")
	character.stop_motion()
	# The renderer handles the atlas, hair, dyes and removable head equipment.
	# Only held weapons are hidden to keep the portrait a readable bust.
	character._gear.weapon.visible = false
	character._gear.offhand.visible = false
	var head = character._head_base
	character.scale = Vector2.ONE * minf(210.0/head.target_size.y,230.0/head.target_size.x)
	character.position = Vector2(128,104) - head._sprite.global_position
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
