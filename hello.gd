extends Node
var host = "localhost"
var port = 8080
var udp_peer: PacketPeerUDP
var is_connected = false

func _on_connect_button_pressed():
	if is_connected:
		print("UDP connection is already set up.")
		return
		
	print("Setting up UDP connection...")
	udp_peer = PacketPeerUDP.new()
	var bind_error = udp_peer.bind(0)
	if bind_error != OK:
		print("Failed to set up UDP! Error code:", bind_error)
		return
	print("UDP connection setup successful. Ready to send/recieve")
	
	var adr_error = udp_peer.set_dest_address(host, port)
	if adr_error != OK:
		print("Error setting destination address:", adr_error)
		return
	
	is_connected = true
	print("Connected to %s:%d via UDP." % [host, port])


func _on_disconnect_button_pressed():
	if not is_connected:
		print("UDP conenction already closed.")
		return
	print("Closing UDP connection...")
	udp_peer.close()
	is_connected = false
	print("UDP connection closed.")


func _on_write_button_pressed():
	if not is_connected:
		print("You must connect before sending messages.")
		return
	
	var message = "hello server!"
	
	var send_error = udp_peer.put_packet(message.to_utf8_buffer())
	if send_error != OK:
		print("Error sending data:", send_error)
		return
	print("Message sent to server: %s" % message)


func _process(delta):
	if not is_connected:
		return
	
	var status = udp_peer.get_available_packet_count()
	if status == 0:
		return
	
	var packet = udp_peer.get_packet()
	print("Received from server: %s" % packet.get_string_from_utf8())

func _ready():
	var connect_button = $Connect
	var disconnect_button = $Disconnect
	var write_button = $Write
	connect_button.connect("pressed", _on_connect_button_pressed)
	disconnect_button.connect("pressed", _on_disconnect_button_pressed)
	write_button.connect("pressed", _on_write_button_pressed)
