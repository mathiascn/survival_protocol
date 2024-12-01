extends Node
class_name Handshake

var major: int = 0
var minor: int = 0
var patch: int = 0
var server_type: String = ""
var player_id: String = ""


func from_bytes(data: PackedByteArray) -> void:
	if data.size() < 3:
		return
	self.major = data[0]
	self.minor = data[1]
	self.patch = data[2]
	
	if data.size() > 3:
		var server_type_size = data.slice(3, 5)
		self.server_type = data.slice(5, server_type_size.decode_u16(0) + 5).get_string_from_utf8()
	
		if data.size() > 7:
			self.player_id = data.slice(server_type_size.decode_u16(0) + 5 + 2).get_string_from_utf8()


static func to_bytes() -> PackedByteArray:
	return PackedByteArray([
		Config.version_major,
		Config.version_minor,
		Config.version_patch
	])
