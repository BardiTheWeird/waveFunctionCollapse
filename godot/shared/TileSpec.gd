class_name TileSpec
var key : String
var texture_filters : Array # array of funcrefs
var color : Color

func _init(key_: String, texture_filters_: Array, color_: Color = Color(255,255,255)):
	key = key_
	texture_filters = texture_filters_
	color = color_
