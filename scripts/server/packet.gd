extends Node
class_name Packet

static var serial_counter = 0
enum MessageType {
	Handshake = 0,
	Ping = 1,
	Pong = 2,
	Move = 3,
	Shoot = 4,
	Chat = 5
}

static func encode_packet(message_type: MessageType, payload: PackedByteArray, error_flag: int = 0) -> PackedByteArray:
	if message_type < 0 or message_type > 255:
		print("Error: Message type must be a valid byte")
		return PackedByteArray()
	
	var payload_length = len(payload)
	
	var header = PackedByteArray()
	header.append(message_type)
	header.append_array([
		payload_length & 0xFF,
		(payload_length >> 8) & 0xFF,
		(payload_length >> 16) & 0xFF,
		(payload_length >> 24) & 0xFF
	])
	header.append(error_flag)
	header.append(serial_counter % 256)
	serial_counter += 1
	
	var timestamp = int(Time.get_unix_time_from_system() * 1000)
	header.append_array([
		timestamp & 0xFF,
		(timestamp >> 8) & 0xFF,
		(timestamp >> 16) & 0xFF,
		(timestamp >> 24) & 0xFF,
		(timestamp >> 32) & 0xFF,
		(timestamp >> 40) & 0xFF,
		(timestamp >> 48) & 0xFF,
		(timestamp >> 56) & 0xFF
	])
	
	var packet = header
	packet.append_array(payload)
	return packet

static func decode_packet(packet: PackedByteArray) -> Dictionary:
	if len(packet) < 15:
		print("Invalid packet size")
		return {}
	
	var message_type = packet[0]
	var size_bytes = packet.slice(1, 5)
	var size = PackedByteArray(size_bytes).decode_u32(0)
	var error_flag = packet[5]
	var serial = packet[6]
	var timestamp_bytes = packet.slice(7, 15)
	var timestamp = PackedByteArray(timestamp_bytes).decode_u64(0)
	
	var payload = packet.slice(15)
	if len(payload) != size:
		print("Corrupt packet: Payload size(%s) does not match header size(%s)." % [len(payload), size])
		return {}
	
	return {
		"message_type": message_type,
		"size": size,
		"error_flag": error_flag,
		"serial": serial,
		"timestamp": timestamp,
		"payload": payload
	}
