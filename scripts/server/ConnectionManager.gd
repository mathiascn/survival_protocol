extends Node

var udp_peer: PacketPeerUDP
enum ConnectionStatus {
	DISCONNECTED = 0,
	READY = 1,
	ESTABLISHING = 2,
	CONNECTED = 3
}
var current_status = ConnectionStatus.DISCONNECTED

func setup(host):
	if self.current_status > ConnectionStatus.DISCONNECTED:
		print("Error: udp already setup")
		return
	var parts = host.split(":")
	if len(parts) != 2:
		print("Error: expected host:port format, but got:", host)
		return
	if current_status == ConnectionStatus.ESTABLISHING:
		print("Error: UDP connection is establishing.")
		return
	if current_status == ConnectionStatus.CONNECTED:
		print("Error: UDP connection is already set up.")
		return
		
	print("Setting up UDP connection...")
	udp_peer = PacketPeerUDP.new()
	var bind_error = udp_peer.bind(0)
	if bind_error != OK:
		print("Failed to set up UDP! Error code:", bind_error)
		return
	print("UDP connection setup successful. Ready to send/receive.")
	
	var adr_error = udp_peer.set_dest_address(parts[0], int(parts[1]))
	if adr_error != OK:
		print("Error setting destination address:", adr_error)
		return
	
	self.current_status = ConnectionStatus.READY
	print("Setup to %s:%s via UDP." % [parts[0], parts[1]])


func establish_connection():
	if self.current_status != ConnectionStatus.READY:
		print("Error: You must setup UDP before you attempt to establish connection.")
		return
	
	self.current_status = ConnectionStatus.ESTABLISHING
	Events.emit_signal("conn_establishing")
	
	var packet = Packet.encode_packet(
		Packet.MessageType.Handshake,
		Handshake.to_bytes()
	)
	
	var send_error = udp_peer.put_packet(packet)
	if send_error != OK:
		print("Error sending data:", send_error)
		return
	print("Handshake sent to server: %s" % Handshake.to_bytes())


func _process(_delta):
	if self.current_status != ConnectionStatus.ESTABLISHING:
		return
	
	var status = udp_peer.get_available_packet_count()
	if status == 0:
		return
	print("received a packet")
	
	var udp_packet = udp_peer.get_packet()
	var decoded_data = Packet.decode_packet(udp_packet)
	if not decoded_data:
		return

	var message_type = decoded_data.get("message_type")
	print("udp: '%s' | serial: %d, error: %d" % [
		Utils.enum_key_for_value(Packet.MessageType, message_type),
		decoded_data.get("serial"),
		decoded_data.get("error_flag")
	])
	
	var payload = decoded_data.get("payload")
	var error_flag = decoded_data.get("error_flag")
	
	if not payload:
		print("Error: missing payload")
		return
	
	if error_flag == 1:
		print("Error in packet")
		self.current_status = ConnectionStatus.DISCONNECTED
		return
	print("packet type received: ", Packet.MessageType.Handshake)
	match message_type:
		Packet.MessageType.Handshake:
			var hs = Handshake.new()
			hs.from_bytes(decoded_data.get("payload"))
			print("pid: %s" % hs.player_id)
			print("server_type: %s" % hs.server_type)
			self.current_status = ConnectionStatus.CONNECTED
			Events.emit_signal("conn_connected")
		_:
			print("Unknown message type")
