extends RayCast2D

var max_distance = 1000
var bullet_component = preload("res://components/Bullet.tscn")

func create_bullet(pos, dot_product, distance):
	var bullet = bullet_component.instantiate()
	bullet.distance = distance
	bullet.start_position = pos
	bullet.direction = dot_product
	get_tree().root.add_child(bullet)
	bullet.create()

func shoot(direction_to: Vector2):
	print("shoot")
	var distance = max_distance
	var dot_product = global_position.direction_to(direction_to)
	var space_state = get_world_2d().direct_space_state
	var pos = global_position
	var query = PhysicsRayQueryParameters2D.create(pos, pos + dot_product * max_distance)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)

	if result:
		print("Hit at point: ", result.rid)
		distance = pos.distance_to(result.position)

	create_bullet(pos, dot_product, distance)
