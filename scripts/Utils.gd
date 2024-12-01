extends Node

func enum_key_for_value(enum_type: Dictionary, value: int) -> String:
	for key in enum_type.keys():
		if enum_type[key] == value:
			return key
	return "Unknown"
