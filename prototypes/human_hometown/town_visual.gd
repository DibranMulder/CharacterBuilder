extends Node2D
## Painted scenery and collision-aligned architectural landings share world coordinates.
const Town = preload("res://prototypes/human_hometown/town.gd")
const FLOOR_RATIOS := {"wendmere_apothecary":.80,"wendmere_approach":.80,"wendmere_gatehouse":.80,"wendmere_trainers":.76,"wendmere_solar":.69,"wendmere_stair":.90}
var ledge: Texture2D
var scenery: Sprite2D
var spec: Dictionary = Town.SPEC
func _ready() -> void:
	if ResourceLoader.exists("res://assets/maps/wendmere/ledge.png"): ledge = load("res://assets/maps/wendmere/ledge.png")
	scenery = Sprite2D.new()
	var art: String = spec.art
	if not ResourceLoader.exists(art):
		art = "res://assets/maps/wendmere/market_row.png" if spec.get("theme","") == "village" else "res://assets/maps/wendmere/village_square.png"
	scenery.texture = load(art)
	scenery.centered = false
	var factor := float(spec.width)/scenery.texture.get_width()
	var ceiling := -170.0
	for platform in spec.platforms: ceiling = minf(ceiling,platform.position.y-500)
	var ratio: float = FLOOR_RATIOS.get(spec.id,.73)
	factor = maxf(factor,(480-ceiling)/(scenery.texture.get_height()*ratio))
	scenery.scale = Vector2.ONE*factor
	scenery.position = Vector2((spec.width-scenery.texture.get_width()*factor)*.5,480-scenery.texture.get_height()*factor*ratio)
	add_child(scenery)
	var architecture := Node2D.new()
	architecture.draw.connect(func(): _architecture(architecture))
	add_child(architecture)

func _architecture(canvas: Node2D) -> void:
	for platform in spec.platforms:
		if ledge != null:
			canvas.draw_texture_rect_region(ledge,Rect2(platform.position+Vector2(-3,-3),Vector2(platform.size.x+6,clampf(platform.size.x*.25,36,68))),Rect2(0,180,2048,370))
		else:
			canvas.draw_rect(Rect2(platform.position,Vector2(platform.size.x,25)),Color("bbae8c"))
	for climb in spec.get("climbs",[]):
		for x in [climb.position.x,climb.end.x]:
			canvas.draw_line(Vector2(x,climb.position.y-15),Vector2(x,climb.end.y),Color("d1b781"),5,true)
		for y in range(int(climb.position.y),int(climb.end.y),23):
			canvas.draw_line(Vector2(climb.position.x,y),Vector2(climb.end.x,y),Color("ae8a52"),5,true)

func _draw() -> void:
	draw_rect(Rect2(0,-1800,spec.width,2280),Color("8eaaba") if spec.get("theme","") == "village" else Color("383e4c"))
	draw_rect(Rect2(0,480,spec.width,2000),Color("263b32") if spec.get("theme","") == "village" else Color("242831"))
