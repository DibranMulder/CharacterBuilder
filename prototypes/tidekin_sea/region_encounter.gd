extends "res://prototypes/training_clearing/encounter.gd"
const Region = preload("res://prototypes/tidekin_sea/region.gd")
var spec: Dictionary
var fixtures := [false,false,false]
var job_cooldown := 0.0
var wildlife: Array[Dictionary] = []
var boss_active := false
var boss_completed := false
var active_time := 0.0
var climb_axis := 0.0
var climbing := false
const RESPAWN_SECONDS := 30.0
const SPAWN_CLEARANCE := 240.0

func configure_region(entry: Dictionary) -> void:
	spec = entry
	configure_map({"id":entry.id,"width":entry.width,"platforms":[],"rowan":false,"enemies":[]})
	recovery_anchor = Vector2(entry.recovery_point[0],entry.recovery_point[1])
	position = recovery_anchor
	platforms.clear()
	for box in entry.platforms: platforms.append(Rect2(box[0],box[1],box[2],box[3]))
	wildlife.clear()
	fixtures = [false,false,false]
	for species in entry.species:
		var info := Region.creature(species)
		if info.disposition == "benevolent":
			for i in 3: wildlife.append({"species":species,"x":650.0+i*430,"level":int(entry.level)+i})
		else:
			var boss: bool = species == "undertow_regent"
			for i in (1 if boss else 6):
				var spawn_x: float = entry.width*.875 if boss else lerpf(650,entry.width-480,float(i)/5)
				_spawn_enemy(spawn_x,false)
				var enemy: Dictionary = enemies.back()
				enemy.merge({"species":species,"level":120 if boss else mini(int(entry.level_max),int(entry.level)+i%3),"provoked":info.disposition != "neutral","respawn":RESPAWN_SECONDS,"spawn_warning":0.0,"boss":boss,"phase":1,"cycle":0,"target_x":0.0,"attack_origin":0.0})
				enemy.max_hp = 90*info.health*(1+.03*(enemy.level-1))
				enemy.hp = enemy.max_hp

func step(delta: float, direction: float, guard_held: bool, muzzle := Vector2.INF) -> void:
	active_time += delta
	if health <= 0: boss_active = false
	job_cooldown = maxf(0,job_cooldown-delta)
	var before := position
	super.step(delta,direction,guard_held,muzzle)
	_advance_climb(delta,before)
	if job_cooldown == 0 and fixtures.all(func(value): return value): fixtures = [false,false,false]

func fixture_point(index: int) -> Vector2: return Vector2(spec.fixture_points[index][0],spec.fixture_points[index][1])
func work(index: int) -> bool:
	if index < 0 or index > 2 or fixtures[index] or health <= 0: return false
	if position.distance_to(fixture_point(index)) > 85: return false
	fixtures[index] = true
	# Authored jobs pay once after three spatially distinct tasks.
	if fixtures.all(func(value): return value):
		award_xp(180+int(spec.level)*20)
		inventory.grant({"coins":18,"hp":1,"mana":1})
		job_cooldown = 90
		events.append({"kind":"level","text":"Water-care complete · +18 coins","position":position+Vector2(0,-170)})
	return true

func _damage_enemy(enemy: Dictionary, power: bool, explicit_damage := -1.0, presentation: Dictionary = {}) -> void:
	if enemy.boss and not boss_active: return
	if enemy.hp <= 0: return
	enemy.provoked = true
	var amount: float = explicit_damage if explicit_damage >= 0 else weapon_feel().damage*(2.1 if power else 1)
	amount *= 1+.03*(adventure_level-1)
	# The recommended five-level cohort stays approachable. Beyond it, armor
	# resistance grows until an enemy 25 levels above the hero is out of reach.
	var gap := maxi(0,int(enemy.level)-adventure_level-5)
	var effectiveness := pow(maxf(0,1-float(gap)/20),2)
	amount *= effectiveness
	if roundi(amount) <= 0:
		events.append({"kind":"dealt","text":"Outmatched","position":Vector2(enemy.x,350)})
		return
	if explicit_damage < 0 and progression != null:
		progression.train_hit(minf(enemy.hp,amount),weapon in ["staff","branch_staff"],power)
	super._damage_enemy(enemy,power,amount,presentation)
	if enemy.hp <= 0:
		award_xp(maxi(0,int(enemy.level)-1)*20)
		enemy.respawn = RESPAWN_SECONDS
		enemy.spawn_warning = 0.0
		if enemy.boss:
			boss_completed = true
			boss_active = false
			inventory.grant({"coins":120})

func _update_enemy(enemy: Dictionary, delta: float) -> void:
	var previous_x: float = enemy.x
	_advance_enemy(enemy,delta)
	enemy["moving"] = absf(enemy.x-previous_x) > .01
	if enemy.hp <= 0 or health <= 0 or invulnerable > 0: return
	if not enemy.provoked or (enemy.boss and not boss_active): return
	# Contact uses bodies, not the telegraphed attack range. Raised platforms and
	# jumps clear this volume; the shared immunity also prevents stacked hits.
	var body := Rect2(enemy.x-30,412,60,68)
	var hero := Rect2(position-Vector2(14,65),Vector2(28,65))
	if body.intersects(hero):
		_hurt(enemy,Region.creature(enemy.species).damage*.6)
		invulnerable = .65

func _hit_lineage_skill(enemy: Dictionary, skill: Dictionary) -> void:
	# An ineffective hit must not apply a root, slow or displacement afterward.
	if int(enemy.level)-adventure_level >= 25:
		_damage_enemy(enemy,true,skill.power)
		return
	super._hit_lineage_skill(enemy,skill)

func _patrol(enemy: Dictionary, delta: float) -> void:
	if enemy.boss or enemy.get("rooted",0.0) > 0: return
	var direction: float = enemy.get("patrol_direction",1.0)
	if enemy.x >= enemy.home+70: direction = -1
	elif enemy.x <= enemy.home-70: direction = 1
	enemy["patrol_direction"] = direction
	enemy.facing = direction
	enemy.x += direction*delta*30*(.55 if enemy.get("slowed",0.0)>0 else 1)
	enemy.x = clampf(enemy.x,enemy.home-70,enemy.home+70)

func _advance_enemy(enemy: Dictionary, delta: float) -> void:
	var info := Region.creature(enemy.species)
	enemy.flash = maxf(0,enemy.flash-delta)
	enemy.rooted = maxf(0,enemy.get("rooted",0.0)-delta)
	enemy.slowed = maxf(0,enemy.get("slowed",0.0)-delta)
	if enemy.hp <= 0:
		if enemy.boss: return
		advance_spawn(enemy,delta,true)
		return
	if health <= 0:
		if enemy.boss:
			boss_active = false
			enemy.hp = enemy.max_hp
		return
	if enemy.boss and not boss_active: return
	if not enemy.provoked:
		_patrol(enemy,delta)
		return
	if absf(position.x-enemy.home)>420 or position.x < 300:
		enemy.state = "idle"
		if absf(enemy.x-enemy.home)>75:
			if enemy.rooted <= 0: enemy.x = move_toward(enemy.x,enemy.home,delta*100)
		else: _patrol(enemy,delta)
		enemy.hp = minf(enemy.max_hp,enemy.hp+delta*15)
		return
	enemy.phase = 3 if enemy.hp/enemy.max_hp <= .35 else (2 if enemy.hp/enemy.max_hp <= .7 else 1)
	var dx: float = position.x-enemy.x
	var reach := 260.0 if info.attack in ["shard","steam","beam","pulse","pull","regent"] else 110.0
	if enemy.state == "idle":
		enemy.facing = signf(dx) if dx != 0 else 1.0
		if absf(dx) < reach and absf(position.y-480)<100:
			enemy.state = "windup"
			enemy.timer = info.tell
			enemy.target_x = position.x
			enemy.attack_origin = enemy.x
		elif absf(dx)<300 and enemy.get("rooted",0.0)<=0:
			enemy.x += signf(dx)*delta*(50 if enemy.boss else 75)*(.55 if enemy.get("slowed",0.0)>0 else 1)
		else: _patrol(enemy,delta)
		return
	enemy.timer -= delta
	if enemy.timer > 0: return
	if enemy.state == "windup":
		enemy.state = "strike"
		enemy.timer = info.active
		if attack_hits(enemy): _hurt(enemy,info.damage)
		if info.attack == "pull" and absf(position.x-enemy.target_x)<80:
			position.x = clampf(move_toward(position.x,enemy.x,45),300,world_width-250)
	elif enemy.state == "strike":
		enemy.state = "recover"
		enemy.timer = 2.0 if enemy.boss and enemy.phase == 3 else info.recovery
		enemy.cycle += 1
	else: enemy.state = "idle"

func attack_zone(enemy: Dictionary) -> Rect2:
	var kind: String = Region.creature(enemy.species).attack
	if kind in ["snap","pulse","pull","regent"]:
		return Rect2(enemy.target_x-55,400 if kind == "snap" else 445,110,80 if kind == "snap" else 35)
	var length := 250.0 if kind in ["shard","steam","beam"] else 140.0
	return Rect2(enemy.attack_origin if enemy.facing>0 else enemy.attack_origin-length,415,length,65)

func attack_hits(enemy: Dictionary) -> bool:
	if invulnerable>0: return false
	return attack_zone(enemy).has_point(position+Vector2(0,-25))

func _hurt(enemy: Dictionary, multiplier: float) -> void:
	var gap := maxi(0,int(enemy.level)-adventure_level-5)
	var scaling := clampf((1+.03*(enemy.level-1))/(1+.03*(adventure_level-1)),.5,3) * (1+float(gap)*.14)
	var damage := 10*multiplier*scaling
	var blocked: bool = guarding and (enemy.x-position.x)*facing>0 and stamina>=18
	if blocked:
		stamina -= 18
		damage *= .2
		blocks += 1
	var absorbed := minf(ward,damage)
	ward -= absorbed
	damage -= absorbed
	health = maxf(0,health-damage)
	invulnerable = .3
	events.append({"kind":"blocked" if blocked else "taken","text":"−%d HP"%damage,"position":position+Vector2(0,-150),"direction":signf(position.x-enemy.x),"impact":position+Vector2(0,-70)})
	if health <= 0:
		death_time = 2
		attack_time = 0
		projectiles.clear()
		guarding = false

func start_boss() -> bool:
	if spec.level != 116 or boss_completed or health<=0 or position.x<world_width*.765625: return false
	boss_active = true
	return true

# Advance only population timers while a visited map is inactive: no offscreen combat.
func advance_population(delta: float, occupied: bool) -> void:
	for enemy in enemies:
		if enemy.hp <= 0 and not enemy.boss: advance_spawn(enemy,delta,occupied)

func advance_spawn(enemy: Dictionary, delta: float, occupied: bool) -> void:
	enemy.respawn = maxf(0,enemy.respawn-delta)
	if enemy.respawn > 0: return
	if occupied and position.distance_to(Vector2(enemy.home,480)) < SPAWN_CLEARANCE:
		enemy.spawn_warning = 0.0
		return
	if occupied:
		enemy.spawn_warning += delta
		if enemy.spawn_warning < 2: return
	enemy.hp = enemy.max_hp
	enemy.x = enemy.home
	enemy.state = "idle"
	enemy.timer = 0.0
	enemy.rooted = 0.0
	enemy.slowed = 0.0
	enemy.provoked = Region.creature(enemy.species).disposition != "neutral"
	enemy.respawn = RESPAWN_SECONDS
	enemy.spawn_warning = 0.0

func can_climb() -> bool:
	return health>0 and attack_time<=0 and not _nearby_climb().is_empty()

func _nearby_climb() -> Dictionary:
	var closest := {}
	var distance := 40.0
	for route in spec.climbs:
		var top := Vector2(route.top[0],route.top[1])
		var bottom := Vector2(route.bottom[0],route.bottom[1])
		# At a shared landing, prefer the connector continuing in the requested
		# direction rather than latching back onto the one just completed.
		if climb_axis<0 and position.y<=top.y+.01: continue
		if climb_axis>0 and position.y>=bottom.y-.01: continue
		var fraction := clampf((position.y-top.y)/(bottom.y-top.y),0,1)
		var x := lerpf(top.x,bottom.x,fraction)
		if absf(position.x-x)<distance and position.y>=top.y-12 and position.y<=bottom.y+12:
			distance = absf(position.x-x)
			closest = route
	return closest

func _advance_climb(delta: float, before: Vector2) -> void:
	climbing = false
	if climb_axis == 0 or health<=0 or attack_time>0: return
	var after_physics := position
	position = before
	var route := _nearby_climb()
	position = after_physics
	if route.is_empty(): return
	var top := Vector2(route.top[0],route.top[1])
	var bottom := Vector2(route.bottom[0],route.bottom[1])
	position.y = clampf(before.y+climb_axis*190*delta,top.y,bottom.y)
	position.x = lerpf(top.x,bottom.x,(position.y-top.y)/(bottom.y-top.y))
	velocity = Vector2.ZERO
	grounded = true
	climbing = true
