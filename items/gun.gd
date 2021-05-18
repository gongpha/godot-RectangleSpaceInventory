extends Item
class_name Gun

# AK-47 เวอร์ชันเด็กป.3 555+
var gun_tex := preload("res://items/gun.png") as StreamTexture

func get_texture() -> Texture :
	return gun_tex

func get_size() -> Vector2 :
	return Vector2(5, 2)
