extends Item
class_name Medkit

var medkit_tex := preload("res://items/medkit.png") as StreamTexture

func get_texture() -> Texture :
	return medkit_tex

func get_size() -> Vector2 :
	return Vector2(2, 2)
