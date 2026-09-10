extends RefCounted
## Visual-only recoil; never moves colliders or cancels a committed attack.
var remaining := 0.0
var kind := ""
var direction := 1.0
const DURATION := .22

func receive(event: Dictionary) -> void:
	if event.get("kind","") not in ["taken","dealt","power","blocked","ward","heal"]: return
	kind = event.kind
	direction = event.get("direction",1.0)
	remaining = DURATION

func advance(delta: float) -> void:
	remaining = maxf(0,remaining-delta)

func offset() -> Vector2:
	if kind not in ["taken","dealt","power"]: return Vector2.ZERO
	return Vector2(direction*8*sin((1-remaining/DURATION)*PI),0) if remaining > 0 else Vector2.ZERO

func tint() -> Color:
	if remaining <= 0: return Color.WHITE
	var color: Color = {"blocked":Color("72d6e5"),"ward":Color("b9abf2"),"heal":Color("b6e8a1")}.get(kind,Color("ff987f"))
	return Color.WHITE.lerp(color,remaining/DURATION)
