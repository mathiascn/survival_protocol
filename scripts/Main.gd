extends Node

@onready var map_1 = preload("res://scenes/maps/map_1.tscn")
@onready var map_2 = preload("res://scenes/maps/map_2.tscn")

func _on_connect():
	get_tree().change_scene_to_packed(map_2)

func _ready():
	Events.connect("conn_connected", _on_connect)
