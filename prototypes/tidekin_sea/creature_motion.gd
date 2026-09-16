extends RefCounted
## Transform-only animation: reuse the creature texture without rebuilding meshes.
static func pose(time: float, phase: float, floating: bool, moving: bool, state: String, remaining: float, timing: Dictionary) -> Transform2D:
	var wave := sin(time*3+phase)
	var offset := Vector2(0,-5-4*wave) if floating else Vector2.ZERO
	var stretch := Vector2(1-wave*.025,1+wave*.035)
	var tilt := 0.0
	if moving:
		var stride := sin(time*12+phase)
		offset.y -= absf(stride)*5
		tilt = stride*.06
	if state == "windup":
		var progress := clampf(1-remaining/maxf(.01,timing.tell),0,1)
		offset.x -= 12*progress
		stretch = Vector2(1+.18*progress,1-.18*progress)
		tilt -= .12*progress
	elif state == "strike":
		var progress := clampf(1-remaining/maxf(.01,timing.active),0,1)
		var thrust := sin(progress*PI)
		offset.x += 38*thrust
		offset.y -= 12*thrust
		stretch = Vector2(1+.25*thrust,1-.12*thrust)
		tilt += .18*thrust
	elif state == "recover":
		var recoil := clampf(remaining/maxf(.01,timing.recovery),0,1)
		stretch = Vector2(1-.07*recoil,1+.07*recoil)
	return Transform2D(tilt,stretch,0,offset)
