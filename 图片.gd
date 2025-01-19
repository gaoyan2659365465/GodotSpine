extends Sprite2D



func _ready() -> void:
	material = ShaderMaterial.new()
	material.shader = preload("res://资源/边缘高亮.gdshader")
	material.set("shader_parameter/OUTLINE_COLOR",Color(1, 1, 1, 0))
	material.resource_local_to_scene = true
	
	if not Global.选择管理器.更改预选中.is_connected(_on_更改预选中):
		Global.选择管理器.更改预选中.connect(_on_更改预选中)


func 显示边缘():
	var tween = create_tween()
	if Global.选择管理器.当前选中 == self:
		tween.tween_property(material,"shader_parameter/OUTLINE_COLOR",Color(0.067, 0.933, 0.925),0.1)
		return
	if Global.选择管理器.预选中 == self:
		tween.tween_property(material,"shader_parameter/OUTLINE_COLOR",Color.WHITE,0.1)
	else:
		tween.tween_property(material,"shader_parameter/OUTLINE_COLOR",Color(1, 1, 1, 0),0.1)


func _input(event: InputEvent) -> void:
	if not Global.绘制控件.鼠标进入:
		return
	if event is InputEventMouseButton:
		if not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var tran = get_global_transform()#仅受缩放影响，不受相机影响
			var rect = tran * get_rect()
			if rect.has_point(get_global_mouse_position()):
				Global.选择管理器.设置选中列表([self])
				# BUG选择的其实是图片的父控件插槽
	if event is InputEventMouseMotion:
		if not Global.绘制控件.鼠标进入:
		#Global.选择管理器.预选中目标(null)
			return
		var tran = get_global_transform()#仅受缩放影响，不受相机影响
		var rect = tran * get_rect()
		
		if rect.has_point(get_global_mouse_position()):
			if Global.选择管理器.预选中 != self:
				if visible:# BUG 只有显示的图片才能被预选到，实际上预选规则需要更复杂
					Global.选择管理器.预选中目标(self)
		else:
			if Global.选择管理器.预选中 == self:
				Global.选择管理器.预选中目标(null)


func _on_更改预选中():
	显示边缘()
