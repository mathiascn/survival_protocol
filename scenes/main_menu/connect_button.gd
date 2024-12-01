extends Node

@onready var connect_button := $ConnectButton
@onready var status_label := $Status
@onready var timeout_timer = Timer.new()

func _on_timer_timeout():
	status_label.visible = true
	connect_button.disabled = false
	connect_button.text = "Connect"

func _on_conn_establishing():
	status_label.visible = false
	connect_button.disabled = true
	connect_button.text = "Connecting..."
	timeout_timer.start()

func _on_conn_connected():
	connect_button.disabled = false
	connect_button.text = "Disconnect"

func _ready() -> void:
	Events.connect("conn_connected", _on_conn_connected)
	Events.connect("conn_establishing", _on_conn_establishing)
	timeout_timer.wait_time = Config.connection_timeout
	add_child(timeout_timer)
	timeout_timer.connect("timeout", _on_timer_timeout)
