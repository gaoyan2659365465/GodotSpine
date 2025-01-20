extends Bone2D

var 颜色 = Color(0.668, 0.668, 0.668)

func _ready() -> void:
	self_modulate = Color(0.668, 0.668, 0.668)


func _process(delta: float) -> void:
	Global.绘制控件.绘制骨骼(self)


func get_rect() -> Rect2:
	var 宽度 = 5
	var pos = Vector2.ZERO
	pos.y -= 宽度
	var size = Vector2(get_length(),宽度*2)
	return Rect2(pos,size)

func _input(event: InputEvent) -> void:
	queue_redraw()
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var rect = get_rect()
				var tran:Transform2D
				tran = tran.rotated(get_bone_angle()).affine_inverse()
				var local_mouse_pos = tran * get_local_mouse_position()
				if rect.has_point(local_mouse_pos):
					Global.选择管理器.设置选中列表([self])
	if event is InputEventMouseMotion:
		var rect = get_rect()
		var tran:Transform2D
		tran = tran.rotated(get_bone_angle()).affine_inverse()
		var local_mouse_pos = tran * get_local_mouse_position()
		if rect.has_point(local_mouse_pos):
			颜色 = Color(1, 1, 1)
			Global.选择管理器.预选中目标(self)
		else:
			颜色 = self_modulate
			if Global.选择管理器.预选中 == self:
				Global.选择管理器.预选中目标(null)
	# 让选中的骨骼保持蓝色
	if Global.选择管理器.选中列表.size() >= 1:
		if Global.选择管理器.选中列表[0] == self:
			颜色 = Color(0, 1, 1)
