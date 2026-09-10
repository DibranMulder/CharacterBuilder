extends RefCounted
const Fighter = preload("res://prototypes/sparring_arena/fighter.gd")
var fighters: Array = []
var projectiles: Array[Dictionary] = []
var events: Array[Dictionary] = []
var countdown := 2.0
var elapsed := 0.0
var winner := -1
var difficulty := 1
var brain_time := 0.0
var bot_direction := 0.0
var bot_guard := false
var bot_choice := 0
var muzzles := [Vector2.INF,Vector2.INF]

func configure(lineage: String, outfit: Dictionary, opponent: String, level := 1) -> void:
	difficulty = clampi(level,0,2)
	var player = Fighter.new()
	player.configure(lineage,outfit,Vector2(260,470))
	var bot = Fighter.new()
	bot.configure(opponent,CharacterCatalog.reference_loadout(opponent),Vector2(890,470))
	bot.facing = -1
	fighters = [player,bot]

func request(slot: int) -> bool:
	return countdown <= 0 and winner < 0 and fighters[0].request(slot)

func step(delta: float, direction: float, guard: bool, jumping := false) -> void:
	events.clear()
	if winner >= 0: return
	if countdown > 0:
		countdown = maxf(0,countdown-delta)
		return
	elapsed += delta
	if jumping: fighters[0].jump()
	brain_time -= delta
	if brain_time <= 0:
		_think()
		brain_time = [.32,.22,.14][difficulty]
	var releases := []
	for i in 2:
		if fighters[i].advance(delta,direction if i == 0 else bot_direction,guard if i == 0 else bot_guard): releases.append(i)
	# Resolve simultaneous releases before declaring the round, so trades count.
	for i in releases: _release(i)
	for shot in projectiles:
		var old: Vector2 = shot.position
		shot.position += shot.velocity*delta
		shot.life -= delta
		var target = fighters[1-shot.owner]
		var box := Rect2(target.position+Vector2(-22,-120),Vector2(44,120))
		if _segment_hits(old,shot.position,box):
			_hit(shot.owner,shot.power,shot.kind,old.x)
			shot.life = 0
	projectiles = projectiles.filter(func(shot): return shot.life > 0 and shot.position.x > 0 and shot.position.x < 1152)
	if fighters[0].health <= 0 or fighters[1].health <= 0:
		winner = 2 if fighters[0].health <= 0 and fighters[1].health <= 0 else (1 if fighters[0].health <= 0 else 0)
		projectiles.clear()

func _think() -> void:
	var bot = fighters[1]
	var player = fighters[0]
	var distance: float = absf(player.position.x-bot.position.x)
	var toward: float = signf(player.position.x-bot.position.x)
	if bot.action.is_empty(): bot.facing = toward
	var ranged: bool = bot.basic().kind == "bolt"
	var preferred := 300.0 if ranged else 95.0
	bot_direction = toward if distance > preferred+20 else (-toward if distance < preferred-45 else 0.0)
	bot_guard = false
	var threat: bool = not player.action.is_empty() and not player.released and player.action_time >= [.65,.38,.22][difficulty] and distance < 240
	if threat:
		bot_guard = bot.can_guard()
		bot_direction = 0
		if not bot_guard and difficulty > 0: bot.jump()
		return
	if not bot.action.is_empty(): return
	for offset in 4:
		var index := (bot_choice+offset)%4
		var skill: Dictionary = bot.skills[index]
		var useful: bool = distance < skill.reach and distance > 40
		match skill.kind:
			"heal": useful = bot.health < 60
			"ward": useful = bot.ward <= 0 and distance < 340
			"retreat": useful = distance < 150
			"dash": useful = distance > 145 and distance < skill.reach
		if useful and bot.request(index):
			bot_choice = (index+1)%4
			return
	if distance < bot.basic().reach-10: bot.request(-1)

func _release(owner: int) -> void:
	var actor = fighters[owner]
	var target = fighters[1-owner]
	var action: Dictionary = actor.action
	var origin: Vector2 = actor.position
	var direction: float = action.facing
	events.append({"kind":"effect","owner":owner,"position":origin+Vector2(0,-65),"effect":action.kind,"name":action.name})
	match action.kind:
		"heal":
			var amount: float = minf(action.power,100-actor.health)
			actor.health += amount
			_note(owner,"+%d HP"%amount,"heal")
		"ward":
			actor.ward = action.power
			actor.ward_time = 5
			_note(owner,"WARD %d"%action.power,"ward")
		"retreat":
			actor.position.x = clampf(origin.x-direction*action.reach,65,1087)
		"bolt","slowbolt","rootbolt","drain":
			var start: Vector2 = origin+Vector2(direction*32,-75)
			if muzzles[owner].is_finite():
				start = muzzles[owner]
			var aim: Vector2 = (target.position+Vector2(0,-70)-start).normalized()
			# A facing-locked shot never fires backwards after an opponent crosses.
			if aim.x*direction <= 0: aim = Vector2(direction,0)
			projectiles.append({"owner":owner,"position":start,"velocity":aim*470,"power":action.power,"kind":action.kind,"life":action.reach/470.0})
		_:
			var dx: float = target.position.x-origin.x
			var in_front: bool = dx*direction >= -15 or action.kind == "pulse"
			if absf(dx) <= action.reach and absf(target.position.y-origin.y) < 95 and in_front:
				_hit(owner,action.power,action.kind,origin.x)
			if action.kind == "dash": actor.position.x = clampf(origin.x+direction*minf(action.reach,180),65,1087)

func _hit(owner: int, power: float, kind: String, source_x: float) -> void:
	var target = fighters[1-owner]
	var source = fighters[owner]
	var blocked: bool = target.guarding and (source_x-target.position.x)*target.facing >= 0 and target.stamina >= 15
	if blocked:
		power *= .25
		target.stamina = maxf(0,target.stamina-20)
	var absorbed: float = minf(target.ward,power)
	target.ward -= absorbed
	var damage: float = minf(target.health,power-absorbed)
	target.health = maxf(0,target.health-damage)
	target.received += damage
	source.dealt += damage
	target.flash = .18 if damage > 0 and not blocked else 0.0
	if not blocked and damage > 0:
		if kind == "slowbolt": target.slow = 2
		if kind == "rootbolt": target.rooted = .8
		if kind == "pulse": target.position.x = clampf(target.position.x+signf(target.position.x-source_x)*50,65,1087)
	if kind == "drain":
		var restored: float = minf(100-source.health,damage*.5)
		source.health += restored
		if restored > 0: _note(owner,"+%d HP"%restored,"heal")
	if absorbed > 0:
		_note(1-owner,"ABSORB %d"%absorbed,"ward")
	if blocked or damage > 0:
		var category := "blocked" if blocked else ("taken" if owner == 1 else "dealt")
		events.append({"kind":category,"text":("BLOCK · " if blocked else "")+str(ceili(damage)),"target":1-owner,"direction":signf(target.position.x-source_x),"position":target.position+Vector2(0,-130),"impact":target.position+Vector2(0,-65)})

func _note(owner: int, value: String, kind: String) -> void:
	events.append({"kind":kind,"text":value,"target":owner,"position":fighters[owner].position+Vector2(0,-140),"impact":fighters[owner].position+Vector2(0,-65)})

static func _segment_hits(a: Vector2, b: Vector2, box: Rect2) -> bool:
	if box.has_point(a) or box.has_point(b): return true
	var corners := [box.position,Vector2(box.end.x,box.position.y),box.end,Vector2(box.position.x,box.end.y)]
	for i in 4:
		if Geometry2D.segment_intersects_segment(a,b,corners[i],corners[(i+1)%4]) != null: return true
	return false
