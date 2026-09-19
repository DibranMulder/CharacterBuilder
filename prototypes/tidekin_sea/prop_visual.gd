extends Node2D
## Retained atlas stamps: one map owns these commands until it is left.
const ATLAS = preload("res://assets/maps/tidekin/props.png")
const KEY_SHADER = preload("res://prototypes/tidekin_sea/resident_key.gdshader")
const SOURCES := {
	"sea-crate":Rect2(25,38,237,216),"sea-basket":Rect2(301,40,241,218),
	"sea-chest":Rect2(575,62,258,186),"sea-seat":Rect2(848,99,269,147),
	"sea-table":Rect2(1136,35,250,225),"sea-scrolls":Rect2(28,278,216,278),
	"sea-shell":Rect2(286,307,251,229),"sea-net":Rect2(568,303,268,239),
	"sea-buoy":Rect2(873,283,213,266),"sea-kelp":Rect2(1169,278,178,283),
	"sea-bottles":Rect2(22,578,252,253),"sea-banner":Rect2(314,555,209,280),
	"sea-pearl":Rect2(577,609,231,207),"sea-gong":Rect2(848,577,266,253),
	"sea-valve":Rect2(1140,580,239,252),"sea-gauge":Rect2(48,834,183,270),
	"sea-lantern":Rect2(328,832,148,274)
}
const CONTACT := {"sea-crate":.07,"sea-basket":.26,"sea-chest":.05,"sea-seat":.08,"sea-table":.05,"sea-scrolls":.06,"sea-shell":.05}
const DECK := Rect2(500,907,447,153)
var spec: Dictionary

func _ready() -> void:
	var key := ShaderMaterial.new()
	key.shader = KEY_SHADER
	material = key

func _draw() -> void:
	var landing_count: int = spec.climbs.size()
	var decks: Array = spec.platforms.slice(0,landing_count)
	decks.append(spec.floor_rect)
	for deck in decks:
		var x: float = deck[0]
		var end: float = x+deck[2]
		while x<end:
			var width := minf(210,end-x)
			draw_texture_rect_region(ATLAS,Rect2(x,deck[1],width,72),Rect2(DECK.position,Vector2(DECK.size.x*width/210,DECK.size.y)))
			x += width
	var platform_index := landing_count
	for object in spec.objects:
		var box := Rect2(object.rect[0],object.rect[1],object.rect[2],object.rect[3])
		var foot := box.end.y+7.2
		if object.jumpable:
			var collision_y: float = spec.platforms[platform_index][1]
			var height: float = (foot-collision_y)/(1.0-CONTACT[object.type])
			box.position.y = foot-height
			box.size.y = height
			platform_index += 1
		else: box.position.y += 7.2
		draw_texture_rect_region(ATLAS,box,SOURCES[object.type])
