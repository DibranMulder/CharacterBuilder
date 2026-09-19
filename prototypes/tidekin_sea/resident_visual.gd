extends Node2D
## One shared painted atlas; animation only changes this sprite's transform.
const ATLAS = preload("res://assets/npcs/tidekin/residents.png")
const RECTS := [Rect2(96,200,212,228),Rect2(424,173,278,258),Rect2(800,104,236,332),Rect2(1165,85,310,351),Rect2(79,599,230,280),Rect2(430,599,252,280),Rect2(790,606,262,273),Rect2(1146,579,324,300)]
const HEIGHTS := [135.0,155.0,180.0,205.0,155.0,165.0,155.0,280.0]
const KEY_SHADER = preload("res://prototypes/tidekin_sea/resident_key.gdshader")
var resident: Dictionary
var sprite: Sprite2D
var base_scale := 1.0

func _ready() -> void:
	var kind: int = resident.portrait
	var texture := AtlasTexture.new()
	texture.atlas = ATLAS
	texture.region = RECTS[kind]
	sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.offset = Vector2(-RECTS[kind].size.x*.5,-RECTS[kind].size.y)
	base_scale = HEIGHTS[kind]/RECTS[kind].size.y
	sprite.scale = Vector2.ONE*base_scale
	var key := ShaderMaterial.new()
	key.shader = KEY_SHADER
	sprite.material = key
	add_child(sprite)

func refresh_pose(clock: float) -> void:
	if not visible or sprite == null: return
	var phase: float = clock*2.2+resident.phase
	var walking: bool = resident.get("moving",false)
	var breath := sin(phase)*.009
	sprite.scale = Vector2(base_scale*(1-breath),base_scale*(1+breath))
	sprite.position.y = -absf(sin(clock*8))*3 if walking else 0.0
	sprite.rotation = sin(clock*8)*.025 if walking else sin(phase*.5)*.007
	sprite.scale.x *= resident.get("facing",1.0)*(-1 if resident.portrait==7 else 1)
