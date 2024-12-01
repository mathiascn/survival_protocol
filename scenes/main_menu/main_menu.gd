extends Node

@onready var connect_button = $Standard/ConnectButton
@onready var host_input = $Standard/HostInput
@onready var game_name_label = $Standard/GameNameLabel

func _on_connect_button_pressed():
	ConnectionManager.setup(host_input.text)
	ConnectionManager.establish_connection()

func _ready():
	connect_button.connect("pressed", _on_connect_button_pressed)
	host_input.text = Config.host + ":" + str(Config.port)
	game_name_label.text = Config.game_name
