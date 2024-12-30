extends Node2D

var color = Color.YELLOW
var width = 2
var distance = 1000
var start_position: Vector2
var direction: Vector2
# fade
var elapsed_time = 0.0
var fade_duration = .1

@onready var line = Line2D.new()

func create():
	line.default_color = self.color
	line.width = self.width
	var end_position = self.start_position + self.direction * self.distance
	
	line.add_point(self.start_position)
	line.add_point(end_position)
	get_tree().root.add_child(line)
	set_process(true)


func _ready():
	set_process(false)


func _process(delta: float):
	elapsed_time += delta
	var alpha = 1.0 - (elapsed_time / fade_duration)
	alpha = clamp(alpha, 0.0, 1.0)
	
	var faded_color = line.default_color
	faded_color.a = alpha
	line.default_color = faded_color
	
	# despawn if tracer is transparent
	if alpha <= 0.0:
		queue_free()
