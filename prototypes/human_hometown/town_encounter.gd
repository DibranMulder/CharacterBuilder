extends "res://prototypes/training_clearing/encounter.gd"
## Climbing belongs to simulation, so rendering and input never move the hero directly.
var climbs: Array = []
var climb_axis := 0.0
var climbing := false
func configure_map(spec: Dictionary) -> void:
	super.configure_map(spec)
	climbs = spec.get("climbs",[]).duplicate()
	loot.clear()
	var lookout: Dictionary = spec.get("lookout",{})
	if not lookout.is_empty():
		loot.append({"position":lookout.position,"collected":false,"reward":{"coins":20,"hp":1,"mana":0,"items":[]},"label":lookout.name+" · +20 coins · remedy"})
func can_climb() -> bool:
	if health <= 0 or attack_time > 0: return false
	for climb in climbs:
		if climb.grow(25).has_point(position): return true
	return false
func step(delta: float, direction: float, guard_held: bool, muzzle := Vector2.INF) -> void:
	super.step(delta,direction,guard_held,muzzle)
	climbing = false
	if climb_axis == 0 or not can_climb(): return
	for climb in climbs:
		if climb.grow(25).has_point(position):
			position.y = clampf(position.y+climb_axis*190*delta,climb.position.y,climb.end.y)
			velocity.y = 0
			grounded = true
			climbing = true
			return
