extends Camera2D


signal 滚轮缩放

# 鼠标按下时的位置
var pressed_mouse_pos = Vector2.ZERO
var camera_pos = Vector2.ZERO
var is_press

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			self.pressed_mouse_pos = event.position
			self.camera_pos = self.global_position
			is_press = event.is_pressed()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			相机缩放插值(clamp(zoom - Vector2(0.1,0.1),Vector2(0.1,0.1),Vector2(20,20)))
			滚轮缩放.emit()
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			相机缩放插值(zoom+Vector2(0.1,0.1))
			滚轮缩放.emit()
	if event is InputEventMouse:
		if is_press:
			var mouse_offset = event.position - self.pressed_mouse_pos
			var tran = get_canvas_transform().affine_inverse()
			self.global_position = self.camera_pos - Vector2(tran.x[0],tran.y[1]) * mouse_offset

func 相机缩放插值(value):
	var tween = create_tween()
	tween.tween_property(self,"zoom",value,0.2)

func 设置缩放(value):
	var _z = 1.0
	if value <= 0.5:
		_z = remap(value,0,0.5,0.1,1)
	else:
		_z = remap(value,0.5,1.0,1,20)
	相机缩放插值(Vector2(_z,_z))
