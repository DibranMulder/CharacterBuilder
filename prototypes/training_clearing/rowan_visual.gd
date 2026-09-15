extends Node2D
const ART = preload("res://assets/npcs/elder_rowan.png")
var clock := 0.0
var stride := 0.0
var facing := -1.0
var surface: MeshInstance2D

func _ready() -> void:
	var keyed := ShaderMaterial.new()
	keyed.shader = preload("res://prototypes/training_clearing/pouch_art.gdshader")
	surface = MeshInstance2D.new()
	surface.texture = ART
	surface.material = keyed
	add_child(surface)
	_rebuild_surface()

func advance(delta: float, walking: bool, direction: float) -> void:
	if delta == 0 and direction == facing and (walking or stride == 0):
		return
	clock += delta
	stride = move_toward(stride,1.0,delta*5) if walking else 0.0
	facing = direction
	if is_visible_in_tree(): _rebuild_surface()

func _draw() -> void:
	# Contact shadow stays on the floor, independent of the breathing mesh.
	draw_set_transform(Vector2(0,-1),0,Vector2(1,.16))
	draw_circle(Vector2.ZERO,43,Color(0.04,0.08,0.04,.23))
	draw_set_transform(Vector2.ZERO)

func source_to_local(point: Vector2) -> Vector2:
	var local := Vector2(-56,-210)+(point-Vector2(180,120))*Vector2(112.0/690,210.0/1290)
	# The illustration uses perspective: staff, far boot and near boot end at
	# different heights. Ground each contact, fading the correction into the robe.
	var sole := lerpf(1350,1370,smoothstep(310,330,point.x))
	sole = lerpf(sole,1407,smoothstep(500,585,point.x))
	var lower := smoothstep(1000,sole,point.y)
	local.y += (1410-sole)*210.0/1290*lower
	var upper := 1.0-smoothstep(700,1300,point.y)
	local.y += sin(clock*1.8)*.8*upper
	local.x += sin(clock*.9)*.6*upper
	var foot := smoothstep(1050,1350,point.y)
	var phase := clock*5.0+(PI if point.x > 550 else 0.0)
	local.x += sin(phase)*3.0*foot*stride
	local.y -= maxf(0,sin(phase))*2.8*foot*stride
	local.x *= -facing # Painted facing left.
	return local

func _rebuild_surface() -> void:
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	const COLS := 32
	const ROWS := 64
	for y in range(ROWS+1):
		for x in range(COLS+1):
			var source := Vector2(180+x*690.0/COLS,120+y*1290.0/ROWS)
			var point := source_to_local(source)
			vertices.append(Vector3(point.x,point.y,0))
			uvs.append(source/Vector2(1024,1536))
	for y in ROWS:
		for x in COLS:
			var a := y*(COLS+1)+x
			indices.append_array(PackedInt32Array([a,a+1,a+COLS+1,a+1,a+COLS+2,a+COLS+1]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	surface.mesh = mesh
