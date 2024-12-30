extends RayCast2D

var scene = preload("res://scenes/player/enemy.tscn") 

func instantiate_object(position: Vector2):
	var instance = scene.instantiate()
	instance.global_position = position
	get_tree().current_scene.add_child(instance)


func shoot():
	print("shoot")
	var dot_product = global_position.direction_to(get_global_mouse_position())
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position + dot_product * 1000)
	query.exclude = [self]
	
	#instantiate_object(global_position + dot_product * 1000)
	
	var result = space_state.intersect_ray(query)

	if result:
		print("Hit at point: ", result.rid)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()
