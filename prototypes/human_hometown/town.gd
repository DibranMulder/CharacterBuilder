extends RefCounted
const SPEC := {"id":"wendmere_square","name":"Wendmere Crossroads","width":2400.0,
	"rowan":true,"merchant_x":1600.0,"enemies":[],"platforms":[],
	"art":"res://assets/maps/wendmere/village_square.png","sentries":[245.0,2200.0]}
const LANDMARKS := [
	{"x":300.0,"name":"West Gate","hint":"Walk west through the arch to Market Row."},
	{"x":610.0,"name":"The Hearth Inn","hint":"The village inn. Follow the road east to the square."},
	{"x":1140.0,"name":"Village Square","hint":"Rowan trades by the blue canopy, farther east."},
	{"x":1600.0,"name":"Rowan's Market Stall","hint":"E / Rowan · Trade equipment and potions."},
	{"x":2140.0,"name":"Wardens' Road","hint":"Continue east through the arch to start training."},
]
static func nearest(x: float) -> Dictionary:
	var result: Dictionary = LANDMARKS[0]
	for entry in LANDMARKS:
		if absf(entry.x-x) < absf(result.x-x): result = entry
	return result
