extends Node
class_name TextureGenerator

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
