extends Node2D
## Target-space presentation only. Never deals damage or changes collision/status.
const LIMIT := 24
const GOLD := Color("efbd62")
const IVORY := Color("fff1c9")
var effects: Array[Dictionary] = []
var camera := Vector2.ZERO
var reduced_effects := false

static func profile(weapon: String, empowered: bool, level: int, skill: Dictionary = {}) -> Dictionary:
	var tier := 0 if level < 30 else (1 if level < 75 else 2)
	if not empowered: tier = mini(tier,1)
	var kind := "slash"
	match weapon:
		"axe": kind = "earth"
		"crossbow", "bow": kind = "rain"
		"staff", "branch_staff": kind = "arcane"
	var lineage: String = skill.get("lineage","")
	if not skill.is_empty():
		match lineage:
			"frost_troll": kind = "earth"
			"frostling": kind = "ice"
			"centaur", "bogkin": kind = "vines"
			"fae": kind = "wind"
			"human", "duneborn": kind = "slash"
			"goblin": kind = "rain"
			_:
				if skill.get("kind","") in ["bolt","slowbolt","rootbolt","drain"]: kind = "arcane"
	if skill.get("name","") == "Crosscut": kind = "crosscut"
	return {"effect":kind,"tier":tier}

func push(event: Dictionary) -> void:
	if not event.has("effect") or event.get("kind","") not in ["dealt","power"]: return
	var item := event.duplicate(true)
	item.age = 0.0
	item.tier = clampi(int(item.get("tier",0)),0,2)
	item.foot = item.get("foot",item.get("impact",Vector2.ZERO)+Vector2(0,40))
	item.direction = -1.0 if float(item.get("direction",1.0)) < 0 else 1.0
	item.duration = .7 if item.tier == 0 else (1.05 if item.tier == 1 else 1.35)
	if effects.size() >= LIMIT: effects.pop_front()
	effects.append(item)
	queue_redraw()

func advance(delta: float) -> void:
	for effect in effects: effect.age += maxf(0.0,delta)
	effects = effects.filter(func(effect): return effect.age < effect.duration)
	queue_redraw()

func reset() -> void:
	effects.clear()
	queue_redraw()

func _draw() -> void:
	for effect in effects:
		draw_set_transform(effect.foot-camera,0,Vector2(effect.direction,1))
		var tier: int = 0 if reduced_effects else effect.tier
		var age: float = effect.age
		var fade := 1.0-smoothstep(effect.duration*.65,effect.duration,age)
		var color: Color = {"ice":Color("a7e8ff"),"vines":Color("a9cc77"),"wind":Color("b4eee3"),"arcane":Color("bcb1f5")}.get(effect.effect,GOLD)
		# A compact contact mark appears immediately; secondary shapes are aftermath.
		if age < .24:
			_star(Vector2(0,-40),18+tier*7,Color(IVORY,(1-age/.24)*.8))
		match effect.effect:
			"earth": _earth(age,tier,fade)
			"rain": _rain(age,tier,fade)
			"ice": _ice(age,tier,fade)
			"vines", "wind", "arcane": _spiral(age,tier,fade,color,effect.effect)
			_: _slash(age,tier,fade,effect.effect=="crosscut")
		draw_set_transform(Vector2.ZERO)

func _star(at: Vector2, radius: float, color: Color) -> void:
	var points := PackedVector2Array()
	for i in 8:
		points.append(at+Vector2.from_angle(i*PI/4)*(radius if i%2 == 0 else radius*.19))
	draw_colored_polygon(points,color)

func _ellipse(at: Vector2, radius: Vector2, color: Color, width := 2.0) -> void:
	var points := PackedVector2Array()
	for i in 49: points.append(at+Vector2.from_angle(i*TAU/48)*radius)
	draw_polyline(points,color,width,true)

func _chips(age: float, count: int, spread: float, color: Color) -> void:
	for i in count:
		var flight := clampf(age-(i%3)*.025,0,1)
		var axis := Vector2.from_angle(-PI*.92+i*2.39996)
		var p := Vector2(axis.x*spread*flight,-14-absf(axis.y)*120*flight+115*flight*flight)
		var r := (2+i%3)*(1-flight*.5)
		draw_colored_polygon(PackedVector2Array([p+Vector2(-r,0),p+Vector2(0,-r*1.4),p+Vector2(r,0),p+Vector2(1,r)]),color)

func _earth(age: float, tier: int, fade: float) -> void:
	_ellipse(Vector2(0,2),Vector2(28+age*(45+tier*20),5+age*10),Color(GOLD,fade*.38),2.5)
	if tier > 0:
		var count := 3 if tier == 1 else 5
		for i in count:
			var t := clampf((age-i*.055)/.2,0,1)
			var settle := 1.0-smoothstep(.5,1.25,age)
			var middle := i == count/2
			var height := (17 if middle else 32+(i%2)*19+tier*15)*sin(t*PI*.5)*settle
			if height < 10: continue
			var x := (i-(count-1)*.5)*31.0
			x += signf(x)*15 # Frame the silhouette; keep the monster's face open.
			var base := Vector2(x,4)
			var top := base+Vector2(5,-height)
			var front := PackedVector2Array([base+Vector2(-13,0),top+Vector2(-12,0),top+Vector2(10,3),base+Vector2(13,0)])
			draw_colored_polygon(front,Color(.37,.29,.22,fade*.86))
			draw_colored_polygon(PackedVector2Array([top+Vector2(-12,0),top+Vector2(-4,-9),top+Vector2(20,-5),top+Vector2(10,3)]),Color(.69,.53,.34,fade))
			draw_colored_polygon(PackedVector2Array([top+Vector2(10,3),top+Vector2(20,-5),base+Vector2(20,-5),base+Vector2(13,0)]),Color(.24,.22,.19,fade*.85))
			draw_polyline(PackedVector2Array([base+Vector2(-4,-2),top.lerp(base,.45)+Vector2(2,0),top]),Color(GOLD,fade*.85),2,true)
	_chips(age,6+tier*8,70+tier*40,Color(GOLD,fade*.8))

func _rain(age: float, tier: int, fade: float) -> void:
	if tier == 0:
		_chips(age,6,45,Color(IVORY,fade*.8))
		return
	var count := 5 if tier == 1 else 11
	for i in count:
		var t := (age-.035*i)/.32
		if t < 0 or t > 2.1: continue
		var landing := Vector2(((i*7)%count-(count-1)*.5)*(14 if tier == 2 else 20),-8-(i%3)*8)
		var start := landing+Vector2(-62,-205-tier*30)
		var at := start.lerp(landing,clampf(t,0,1))
		var axis := (landing-start).normalized()
		var opacity := fade*(1.0-smoothstep(1.0,2.1,t))
		if t < 1:
			draw_line(at-axis*72,at,Color(GOLD,opacity*.16),7,true)
			draw_line(at-axis*52,at,Color(IVORY,opacity*.7),1.4,true)
		draw_line(at-axis*26,at,Color(.69,.46,.23,opacity),3,true)
		var normal := axis.orthogonal()
		draw_colored_polygon(PackedVector2Array([at+axis*4,at-axis*8+normal*4,at-axis*8-normal*4]),Color(IVORY,opacity))
		for side in [-1,1]: draw_line(at-axis*24,at-axis*31+normal*side*5,Color(GOLD,opacity),2,true)
		if t >= 1:
			_ellipse(landing+Vector2(0,8),Vector2(9+(t-1)*20,3+(t-1)*5),Color(GOLD,opacity*.6),1.5)
			_star(landing,7,Color(IVORY,opacity*.7))

func _slash(age: float, tier: int, fade: float, crosscut := false) -> void:
	for i in (2 if crosscut else 1+tier):
		var t := age-i*.08
		if t < 0: continue
		var angle := -.7 if i%2 == 0 else .7
		var axis := Vector2.from_angle(angle)
		var normal := axis.orthogonal()
		var at := Vector2((i-1)*9,-42-i*5)
		var length := (34+tier*20)*(1+minf(t,.4))
		var color := Color(GOLD,fade*.5)
		draw_colored_polygon(PackedVector2Array([at-axis*length,at+normal*(5+tier*2),at+axis*length,at-normal*(5+tier*2)]),color)
		draw_line(at-axis*length*.85,at+axis*length*.85,Color(IVORY,fade*.9),2,true)
	_chips(age,4+tier*5,55+tier*25,Color(GOLD,fade*.6))
	if tier == 2 and not crosscut: _ellipse(Vector2(0,-40),Vector2(25+age*70,35+age*40),Color(GOLD,fade*.25))

func _ice(age: float, tier: int, fade: float) -> void:
	for i in 3+tier*2:
		var x := (i-(2+tier*2)*.5)*19
		var height := (22+(i%3)*13+tier*11)*smoothstep(0,.17,age)
		var tip := Vector2(x+x*.2,-height)
		draw_colored_polygon(PackedVector2Array([Vector2(x-9,0),tip,Vector2(x+9,0)]),Color(.32,.65,.82,fade*.45))
		draw_polyline(PackedVector2Array([Vector2(x-9,0),tip,Vector2(x+9,0)]),Color(.76,.94,1,fade*.9),2,true)
	_ellipse(Vector2.ZERO,Vector2(37+tier*23,8),Color(.6,.87,1,fade*.5))
	_chips(age,6+tier*6,70,Color(.73,.94,1,fade*.8))

func _spiral(age: float, tier: int, fade: float, color: Color, kind: String) -> void:
	for i in 2+tier:
		var points := PackedVector2Array()
		for j in 40:
			var t := j/39.0
			var angle := t*TAU+age*3+i*PI
			points.append(Vector2(cos(angle)*(27+tier*15),-t*(75+tier*16)+sin(angle)*8))
		draw_polyline(points,Color(color,fade*.12),8,true)
		draw_polyline(points,Color(color,fade*.7),2,true)
		if kind == "vines":
			for j in [8,18,28]:
				var p: Vector2 = points[j]
				draw_colored_polygon(PackedVector2Array([p,p+Vector2(-5,-8),p+Vector2(2,-16),p+Vector2(5,-5)]),Color(color,fade*.8))
	_chips(age,5+tier*5,60,Color(color,fade*.75))
