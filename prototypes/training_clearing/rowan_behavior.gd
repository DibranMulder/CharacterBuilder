extends RefCounted
## Small deterministic stall routine. Trading uses this same world position.
const HOME := Vector2(330,480)
const STOPS := [-24.0,16.0,0.0]
const LINES := ["The grove is waking up.","Fresh supplies, whenever you need them.","Even old roots enjoy a little sunshine."]
var position := HOME
var facing := -1.0
var walking := false
var conversing := false
var wait_time := 5.0
var stop_index := 0
var speech_wait := 2.0
var speech_time := 0.0
var speech_index := 0
var speech := ""

func begin_conversation(player: Vector2) -> void:
	conversing = true
	walking = false
	speech = ""
	speech_time = 0
	face_player(player)

func end_conversation() -> void:
	conversing = false
	wait_time = 4
	speech_wait = 10

func face_player(player: Vector2) -> void:
	if absf(player.x-position.x) > 8:
		facing = signf(player.x-position.x)

func step(delta: float, player: Vector2, peaceful: bool) -> void:
	if conversing:
		return
	var nearby := position.distance_to(player) < 100
	walking = false
	if nearby or not peaceful:
		face_player(player)
	elif wait_time > 0:
		wait_time = maxf(0,wait_time-delta)
	else:
		var target: float = HOME.x+STOPS[stop_index]
		facing = signf(target-position.x) if target != position.x else facing
		position.x = move_toward(position.x,target,delta*10)
		walking = position.x != target
		if not walking:
			stop_index = (stop_index+1)%STOPS.size()
			wait_time = 5
	if not peaceful or position.distance_to(player) > 340:
		speech = ""
		speech_time = 0
		speech_wait = maxf(speech_wait,4)
		return
	if speech_time > 0:
		speech_time = maxf(0,speech_time-delta)
		if speech_time == 0: speech = ""
	else:
		speech_wait -= delta
		if speech_wait <= 0:
			speech = LINES[speech_index]
			speech_index = (speech_index+1)%LINES.size()
			speech_time = 3.5
			speech_wait = 13
