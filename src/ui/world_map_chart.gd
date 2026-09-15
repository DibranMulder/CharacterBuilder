extends Control
## Retained chart painting; controls and navigation belong to WorldMap.
const Catalog = preload("res://src/world/world_catalog.gd")
const RegionArt = preload("res://src/world/region_art.gd")
const Chronicle = preload("res://src/ui/chronicle_theme.gd")
const ART = preload("res://designs/design-0015-world-map-v2-kids.png")
var region_id := ""
var current := ""
var explored: Array = []
var selected := ""
var selected_node := ""
var points := {}

func _draw() -> void:
	if region_id.is_empty():
		draw_texture_rect(ART,Rect2(0,0,1000,563),false)
		for road in Catalog.data().routes:
			var a := Vector2(Catalog.region(road.a).position[0],Catalog.region(road.a).position[1])*Vector2(1000,563)
			var b := Vector2(Catalog.region(road.b).position[0],Catalog.region(road.b).position[1])*Vector2(1000,563)
			var active: bool = selected in [road.a,road.b]
			draw_line(a,b,Color("493d2bb0"),5,true)
			draw_line(a,b,Color("ffe0a1") if active else Color("ddc189"),2.5 if active else 1.4,true)
		return
	var spec := Catalog.region(region_id)
	var bounds := Rect2(Vector2.ZERO,Catalog.REGION_SIZE)
	draw_texture_rect(RegionArt.background(region_id),bounds,false)
	# Paths lie on the terrain. Only real catalog connections are painted.
	for edge in spec.edges:
		var a: Vector2 = points[edge.a]
		var b: Vector2 = points[edge.b]
		var discovered: bool = (edge.a == current or edge.a in explored) and (edge.b == current or edge.b in explored)
		var active: bool = selected_node in [edge.a,edge.b]
		var route := _route(a,b)
		var color := Color("ffe7a0") if active else (RegionArt.accent(region_id) if discovered else Color("c4d2c3"))
		if edge.kind == "return portal":
			for i in range(0,route.size()-1,3): draw_line(route[i],route[i+1],Color(color,.5),2,true)
		else:
			draw_polyline(route,Color("18322f80"),7 if active else 4,true)
			draw_polyline(route,Color(color,.95 if active else (.65 if discovered else .3)),3 if active else 2,true)
	# Small pools of mist mark unexplored sites without veiling the landscape.
	for entry in spec.nodes:
		if entry.id == current or entry.id in explored: continue
		var at: Vector2 = points[entry.id]
		for ring in range(3,0,-1): draw_circle(at,12+ring*7,Color(.10,.18,.23,.07))

func _route(a: Vector2, b: Vector2) -> PackedVector2Array:
	var path := PackedVector2Array()
	var normal := (b-a).orthogonal().normalized()
	var bend := minf(a.distance_to(b)*.12,45)
	for i in 17:
		var t := i/16.0
		path.append(a.lerp(b,t)+normal*sin(t*PI)*bend)
	return path
