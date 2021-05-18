extends Item
class_name Flashlight

var flashlight_tex := preload("res://items/flashlight.png") as StreamTexture

func get_texture() -> Texture :
	return flashlight_tex

func get_size() -> Vector2 :
	return Vector2(3, 2)
