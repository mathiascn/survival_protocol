extends CharacterBody2D

@export var speed = 400
@onready var shoot_component = $ShootComponent

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot_component.shoot(get_global_mouse_position())


func get_input():
	look_at(get_global_mouse_position())
	var input_direction = Input.get_vector("left", "right", "up", "down")
	self.velocity = input_direction * speed


func _physics_process(_delta):
	get_input()
	move_and_slide()
