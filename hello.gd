extends Node
var host = "localhost"
var port = 8080
var udp_peer: PacketPeerUDP
var is_connected = false

enum MessageType {
	Handshake = 0,
	Ping = 1,
	Pong = 2,
	Move = 3,
	Shoot = 4,
	Chat = 5
}

func enum_key_for_value(enum_type: Dictionary, value: int) -> String:
	for key in enum_type.keys():
		if enum_type[key] == value:
			return key
	return "Unknown"

func encode_packet(message_type: MessageType, payload: String) -> PackedByteArray:
	if message_type < 0 or message_type > 255:
		print("Error: Message type must be a valid byte")
		return PackedByteArray()
	
	var payload_bytes = payload.to_utf8_buffer()
	var payload_length = len(payload_bytes)
	
	# Create header: message type + size (big-endian uint32)
	var header = PackedByteArray()
	header.append(message_type)
	header.append_array([
		(payload_length >> 24) & 0xFF,
		(payload_length >> 16) & 0xFF,
		(payload_length >> 8) & 0xFF,
		payload_length & 0xFF
	])
	
	# Combine header and payload
	var packet = header
	packet.append_array(payload_bytes)
	return packet


func decode_packet(packet: PackedByteArray) -> Array:
	if len(packet) < 5:
		print("Invalid packet size")
		return []
	
	# Extracts the message header
	var message_type = packet[0]
	
	# Extracts the size bytes
	var size_bytes = packet.slice(1, 5)
	# Reverse the size bytes as decode_u32 uses little-endian
	# https://en.wikipedia.org/wiki/Endianness
	size_bytes.reverse()
	var size = PackedByteArray(size_bytes).decode_u32(0)
	var payload = packet.slice(5)
	payload = payload.get_string_from_utf8()
	if len(payload) != size:
		print("Corrupt packet: Payload size does not match header size.")
		return []
	return [message_type, payload]

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
	
	var message = "ping"
	var packet = encode_packet(MessageType.Ping, message)
	
	var send_error = udp_peer.put_packet(packet)
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
	
	var udp_packet = udp_peer.get_packet()
	var decoded_data = decode_packet(udp_packet)
	if not decoded_data:
		return

	var message_type = decoded_data[0]
	var payload = decoded_data[1]
	print("Received '%s' from server: '%s'" % [
		enum_key_for_value(MessageType, message_type),
		payload
	])

func _ready():
	var connect_button = $Connect
	var disconnect_button = $Disconnect
	var write_button = $Write
	connect_button.connect("pressed", _on_connect_button_pressed)
	disconnect_button.connect("pressed", _on_disconnect_button_pressed)
	write_button.connect("pressed", _on_write_button_pressed)
