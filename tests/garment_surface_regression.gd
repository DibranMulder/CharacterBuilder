extends SceneTree

const Surface := preload("res://src/garment_surface.gd")


func _initialize() -> void:
	var rig := Node2D.new()
	root.add_child(rig)
	var hip := Node2D.new()
	rig.add_child(hip)
	var chest := Node2D.new()
	hip.add_child(chest)
	var garment := Node2D.new()
	garment.position.y = -60
	chest.add_child(garment)
	var left := Node2D.new()
	left.position = Vector2(12, 8)
	hip.add_child(left)
	var right := Node2D.new()
	right.position = Vector2(-12, 8)
	hip.add_child(right)
	var surface := Surface.new()
	surface.bind(garment, hip, left, right)
	var size := Vector2(82, 90)
	var belt := Vector2(0, 68.4)
	var hem := Vector2(22, 90)
	assert(surface.deform(hem, size).is_equal_approx(hem))
	assert(absf(surface.deform(Vector2(35, 10), size).x) < 26, "Human chest fitting must bring the shared garment openings inside the shoulder envelope")
	var rest_belt := garment.to_global(belt)
	chest.rotation = .3
	assert(garment.to_global(surface.deform(belt, size)).is_equal_approx(rest_belt), "Belt must stay on pelvis when chest leans")
	assert(surface.deform(Vector2(0, 12), size).is_equal_approx(Vector2(0, 12)), "Neckline must follow chest")
	var resting_hem := surface.deform(hem, size)
	left.rotation = -.9
	assert(surface.deform(hem, size).distance_to(resting_hem) > 5, "Hem must respond to leading thigh")
	var posed_hem := surface.deform(hem, size)
	rig.scale = Vector2(-2, 2)
	rig.position = Vector2(320, 100)
	assert(surface.deform(hem, size).is_equal_approx(posed_hem), "Facing, scale and translation must not alter local deformation")
	assert(surface.mesh(size).get_surface_count() == 1)
	var cached := surface.mesh(size)
	assert(surface.mesh(size) == cached, "Unchanged pose must reuse its garment mesh")
	left.rotation += .1
	assert(surface.mesh(size) != cached, "Pose changes must invalidate the garment mesh")
	print("PASS: garment chest, pelvis, thigh and mirrored bind contracts")
	quit()
