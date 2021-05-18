extends Control
class_name RSInventory

class AllocatedItem :
	var position : Vector2 # Point2i
	var item : Item # Ref<Item>
	var rot : int
	
	func get_size() -> Vector2 :
		var s := item.get_size()
		if rot % 2 != 0 :
			var _temp := s.x
			s.x = s.y
			s.y = _temp
		return s
	
var inv_size : Vector2 # Size2i
var items := [] # List<AllocatedItem>
var slot_image_size : int = 32
var dragging : AllocatedItem
var mouse_pos : Vector2
var mouse_relative : Vector2
var invalid_position := false

func _draw_item(i : AllocatedItem, is_dragging : bool = false) :
	var stex := i.item.get_texture()
	var pos : Vector2
	var ss := i.item.get_size() * slot_image_size
	var s := i.get_size() * slot_image_size
	
	if is_dragging :
		pos = mouse_pos - mouse_relative
		draw_rect(Rect2(pos + Vector2(8, 8), s - Vector2(8, 8)), Color(.25, .25, .25, .75))
	else :
		pos = i.position * slot_image_size
		
	draw_rect(Rect2(pos + Vector2(4, 4), s - Vector2(8, 8)), Color(.5, .5, .5, .5 if is_dragging else 1) if not (invalid_position and is_dragging) else Color(1, .25, .25, .75))
	
	draw_set_transform(pos + s/2, PI / 2 * i.rot, Vector2(1, 1))
	draw_texture(stex, Vector2() - ss/2, Color(1, 1, 1, 0.5 if is_dragging else 1))
	draw_set_transform(Vector2(), 0, Vector2(1, 1))

func _draw() -> void :
	if inv_size.x * inv_size.y == 0 :
		return
	
	var slots : Array
	slots.resize(inv_size.x *inv_size.y)
	
	for i in items :
		var s := i.get_size() as Vector2 # Size2
		for y in s.y :
			for x in s.x :
				var plot : Vector2 = i.position + Vector2(x, y)
				slots[plot.y * inv_size.x + plot.x] = true # Set to anything for tell it's not NULL
		_draw_item(i)
		
	if dragging and not invalid_position :
		var s := dragging.get_size()
		draw_rect(Rect2(dragging.position * slot_image_size + Vector2(4, 4), s * slot_image_size - Vector2(8, 8)), Color(.5, 1, .5, .25))
		for y in s.y :
			for x in s.x :
				var plot : Vector2 = dragging.position + Vector2(x, y)
				slots[plot.y * inv_size.x + plot.x] = true # Set to anything for tell it's not NULL
	
	var idx : int = 0
	for s in slots :
		if not s :
			var x : int
			var y : int
			
			x = (idx % int(inv_size.x)) * slot_image_size
			y = (idx / int(inv_size.x)) * slot_image_size
			
			var center := Vector2(
				x + slot_image_size / 2.0,
				y + slot_image_size / 2.0
			)
			
			# Sprites are available !
			draw_rect(Rect2(center - Vector2(5, 5), Vector2(10, 10)), Color.darkgray)
		idx += 1
		
	if dragging :
		_draw_item(dragging, true)
		
func resize(new_size : Vector2) -> bool :
	var test_inv_size = new_size
	var inv_r := Rect2(Vector2(), test_inv_size)
	
	
	for i in items :
		var s := i.get_size() as Vector2
		var r := Rect2(i.position, s)
		if not inv_r.encloses(r) :
			return false
			
	inv_size = test_inv_size
	update()
	return true
	
func remove(idx : int) :
	items.remove(idx)
	update()
	
func erase(item : AllocatedItem) :
	items.erase(item)
	update()
	
func _test(item : AllocatedItem) -> bool :
	var my_r := Rect2(item.position, item.get_size())
	var inv_r := Rect2(Vector2(), inv_size)
	if not inv_r.encloses(my_r) :
		return false
	
	for i in items :
		var s := i.get_size() as Vector2
		var r := Rect2(i.position, s)
		
		if my_r.intersects(r) :
			return false
			
	return true
	
func _update_dragging() :
	if dragging :
		dragging.position = Vector2((mouse_pos - mouse_relative) / 32).round()
		invalid_position = !_test(dragging)
	
func test_and_put(in_item : Item, selected_position : Vector2, rot : int) -> bool :
	var a := AllocatedItem.new()
	a.position = selected_position
	a.item = in_item
	a.rot = rot
	
	if not _test(a) :
		return false
	
	items.push_back(a)
	update()
	return true
	
func _input(event) :		
	if event is InputEventMouseButton :
		if event.button_index == BUTTON_LEFT :
			var event_ := make_input_local(event)
			if event.is_pressed() :
				if not dragging :
					for i in items :
						var ii : Item = i.item
						var s := ii.get_size() * slot_image_size
						if i.rot % 2 != 0 :
							var _temp := s.x
							s.x = s.y
							s.y = _temp
						var r := Rect2(
							i.position * slot_image_size,
							s
						)
						
						if r.has_point(event_.position) :
							# Pick up
							mouse_pos = event_.position
							mouse_relative = event_.position - Vector2(i.position.x * slot_image_size, i.position.y * slot_image_size)
							dragging = i
							erase(i)
							break
				else :
					if not invalid_position :
						if test_and_put(dragging.item, dragging.position, dragging.rot) :
							dragging = null
					update()
					
	if dragging :
		if event is InputEventMouseMotion :
			var event_ := make_input_local(event)
			mouse_pos = event_.position
			if dragging.position != Vector2((mouse_pos - mouse_relative) / 32).round() :
				_update_dragging()
			update()
		if Input.is_action_just_pressed("rotate") :
			dragging.rot = dragging.rot + 1 % 4
			var _temp := mouse_relative.x
			mouse_relative.x = mouse_relative.y
			mouse_relative.y = _temp
			_update_dragging()
			update()

func lookup_for_space(size : Vector2) : # bool (Vector2& size)
	# (!) This is a simple method for lookup an entire space.
	#     You can use a higher performance algorithm like rectangle packing.
	
	for y in inv_size.y :
		for x in inv_size.x :
			var my_r := Rect2(Vector2(x, y), size)
			var failed := false
			
			var inv_r := Rect2(Vector2(), inv_size)
			if not inv_r.encloses(my_r) :
				failed = true
				break
				
			for i in items :
				var s := i.get_size() as Vector2
				var r := Rect2(i.position, s)
				
				if my_r.intersects(r) :
					failed = true
					break
			if not failed :
				return Vector2(x, y)
	return null

func lookup_and_put(in_item : Item, rot : int) -> bool :
	var a := AllocatedItem.new()
	a.item = in_item
	a.rot = 0 if rot < 0 else rot
	
	var ret = lookup_for_space(a.get_size())
	if ret == null :
		if rot < 0 :
			a.rot += 1
			ret = lookup_for_space(a.get_size())
	if ret == null :
		return false
		
	a.position = ret
		
	items.push_back(a)
	update()
	return true
