extends Control

var inv : RSInventory
var rot_box : CheckBox

func _add_ammo() :
	var item = Ammo.new()
	inv.lookup_and_put(item, -1 if rot_box.is_pressed() else 0)
	
func _add_gun() :
	var item = Gun.new()
	inv.lookup_and_put(item, -1 if rot_box.is_pressed() else 0)

func _ready() :
	#$dialog.show()
	
	$add_ammo.connect("pressed", self, "_add_ammo")
	$add_gun.connect("pressed", self, "_add_gun")
	
	inv = $inventory
	rot_box = $rot
	inv.resize(Vector2(15, 8))
	
	var item = Flashlight.new()
	inv.test_and_put(item, Vector2(1, 1), 0)
	
	item = Ammo.new()
	inv.test_and_put(item, Vector2(13, 1), 1)
	item = Ammo.new()
	inv.test_and_put(item, Vector2(9,3), 0)
	item = Gun.new()
	inv.test_and_put(item, Vector2(7,3), 1)
	item = Medkit.new()
	inv.test_and_put(item, Vector2(0,5), 2)
	item = Medkit.new()
	inv.test_and_put(item, Vector2(3,5), 3)
