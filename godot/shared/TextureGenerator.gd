extends Node
class_name TextureGenerator

func create_texture(tile_spec: TileSpec):
	for key in tile_image_filters.keys():
		var image = create_image(tile_image_filters[key])
		var texture = create_image_texture(image)
		tile_textures[key] = texture

func create_image(filters: Array) -> Image:
	var image = Image.new()
	image.create(16, 16, false, Image.FORMAT_RGBA8)
	
	set_pixel_for_filtered(image, Color(0,0,255), filters)
	
	return image

func create_image_texture(image: Image) -> ImageTexture:
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	texture.flags = (
		ImageTexture.FLAG_MIPMAPS
	)
	
	var flag_str = 'flags: %d\n' % texture.flags
	flag_str += "FLAG_MIPMAPS            [%s] %d\n" % [ImageTexture.FLAG_MIPMAPS & texture.flags, ImageTexture.FLAG_MIPMAPS]
	flag_str += "FLAG_REPEAT             [%s] %d\n" % [ImageTexture.FLAG_REPEAT & texture.flags, ImageTexture.FLAG_REPEAT]
	flag_str += "FLAG_FILTER             [%s] %d\n" % [ImageTexture.FLAG_FILTER & texture.flags, ImageTexture.FLAG_FILTER]
	flag_str += "FLAG_ANISOTROPIC_FILTER [%s] %d\n" % [ImageTexture.FLAG_ANISOTROPIC_FILTER & texture.flags, ImageTexture.FLAG_ANISOTROPIC_FILTER]
	flag_str += "FLAG_CONVERT_TO_LINEAR  [%s] %d\n" % [ImageTexture.FLAG_CONVERT_TO_LINEAR & texture.flags, ImageTexture.FLAG_CONVERT_TO_LINEAR]
	flag_str += "FLAG_MIRRORED_REPEAT    [%s] %d\n" % [ImageTexture.FLAG_MIRRORED_REPEAT & texture.flags, ImageTexture.FLAG_MIRRORED_REPEAT]
	flag_str += "FLAG_VIDEO_SURFACE      [%s] %d\n" % [ImageTexture.FLAG_VIDEO_SURFACE & texture.flags, ImageTexture.FLAG_VIDEO_SURFACE]

	return texture

func set_pixel_for_filtered(image : Image, color : Color, filter_funcs : Array):
	image.lock()

	var size : Vector2 = image.get_size()
	for x in range(size.x):
		for y in range(size.y):
			var should_color = false
			for filter in filter_funcs:
				should_color = should_color || filter.call_func(x, y, size)

			if not should_color:
				continue
			image.set_pixel(x, y, color)

	image.unlock()


var eighth = (Vector2.ONE * 16) / 8
var lower_bound = eighth * 3
var upper_bound = eighth * 5

func in_bounds(x: int, lo: int, hi: int) -> bool:
	return lo <= x and x < hi

func x_in_bounds(x: int) -> bool:
	return in_bounds(x, lower_bound.x, upper_bound.x)

func y_in_bounds(y: int) -> bool:
	return in_bounds(y, lower_bound.y, upper_bound.y)

func always_true(_x: int, _y: int, _size: Vector2) -> bool:
	return true

func is_in_center_square(x: int, y: int, _size: Vector2) -> bool:
	if x_in_bounds(x) and y_in_bounds(y):
		return true
	return false

func is_on_vertical_line(x: int, _y: int, _size: Vector2) -> bool:
	return x_in_bounds(x)

func is_on_horizontal_line(_x: int, y: int, _size: Vector2) -> bool:
	return y_in_bounds(y)

func is_on_upper_vertical_line(x: int, y: int, _size: Vector2) -> bool:
	return x_in_bounds(x) and y < upper_bound.y

func is_on_lower_vertical_line(x: int, y: int, _size: Vector2) -> bool:
	return x_in_bounds(x) and y >= lower_bound.y

func is_on_left_horizontal_line(x: int, y: int, _size: Vector2) -> bool:
	return y_in_bounds(y) and x < upper_bound.x

func is_on_right_horizontal_line(x: int, y: int, _size: Vector2) -> bool:
	return y_in_bounds(y) and x > lower_bound.x
