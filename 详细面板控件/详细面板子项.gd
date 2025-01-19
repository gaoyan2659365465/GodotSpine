@tool
extends Panel

var 行数 = 4
var 装饰板




func _ready() -> void:
	custom_minimum_size.y = 行数 * 27
	size.y = 行数 * 27
	self.size_flags_vertical = Control.SIZE_EXPAND_FILL
	创建装饰板()
	创建文字图标()
	创建CheckBox()
	创建LineEdit()
	创建ColorPickerButton()
	resized.connect(_on_resized)
	await get_tree().process_frame
	queue_redraw()

func 创建装饰板():
	var flat0 = StyleBoxFlat.new()
	flat0.bg_color = Color("#414141")
	flat0.border_width_left = 1
	flat0.border_width_top = 1
	flat0.border_width_right = 1
	flat0.border_width_bottom = 1
	flat0.border_color = Color("#6d6d6d")
	flat0.corner_radius_top_left = 5
	flat0.corner_radius_top_right = 5
	flat0.corner_radius_bottom_right = 5
	flat0.corner_radius_bottom_left = 5
	self.set("theme_override_styles/panel",flat0)
	
	装饰板 = Panel.new()
	add_child(装饰板)
	装饰板.size = size
	装饰板.size.x = 70
	var flat = StyleBoxFlat.new()
	flat.bg_color = Color("#585858")
	flat.border_width_left = 1
	flat.border_width_top = 1
	flat.border_width_right = 1
	flat.border_width_bottom = 1
	flat.corner_radius_top_left = 5
	flat.corner_radius_bottom_left = 5
	flat.border_color = Color("#6d6d6d")
	装饰板.set("theme_override_styles/panel",flat)


func 创建文字图标():
	var l = Label.new()
	l.text = "继承"
	add_child(l)
	l.position = Vector2(28,5)
	l.set("theme_override_colors/font_color",Color("#eeeeee"))
	l.set("theme_override_font_sizes/font_size",12)
	var l2 = Label.new()
	l2.text = "长度"
	add_child(l2)
	l2.position = Vector2(28,32)
	l2.set("theme_override_colors/font_color",Color("#eeeeee"))
	l2.set("theme_override_font_sizes/font_size",12)
	var l3 = Label.new()
	l3.text = "图片"
	add_child(l3)
	l3.position = Vector2(28,59)
	l3.set("theme_override_colors/font_color",Color("#eeeeee"))
	l3.set("theme_override_font_sizes/font_size",12)
	var l4 = Label.new()
	l4.text = "颜色"
	add_child(l4)
	l4.position = Vector2(28,86)
	l4.set("theme_override_colors/font_color",Color("#eeeeee"))
	l4.set("theme_override_font_sizes/font_size",12)
	
	var tex = TextureRect.new()
	tex.texture = preload("res://资源/继承.svg")
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.size = Vector2(15,15)
	tex.position = Vector2(9,6)
	add_child(tex)
	
	var tex2 = TextureRect.new()
	tex2.texture = preload("res://资源/管线长度.svg")
	tex2.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex2.size = Vector2(15,15)
	tex2.position = Vector2(9,34)
	add_child(tex2)
	
	var tex3 = TextureRect.new()
	tex3.texture = preload("res://资源/版本信息提示.svg")
	tex3.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex3.size = Vector2(15,15)
	tex3.position = Vector2(9,61)
	add_child(tex3)
	
	var tex4 = TextureRect.new()
	tex4.texture = preload("res://资源/颜色.svg")
	tex4.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex4.size = Vector2(15,15)
	tex4.position = Vector2(9,87)
	add_child(tex4)
	

func 创建CheckBox():
	var 勾选 = CheckBox.new()
	勾选.text = "旋转"
	勾选.set("theme_override_constants/h_separation",4)
	勾选.set("theme_override_constants/check_v_offset",1)
	勾选.set("theme_override_font_sizes/font_size",12)
	勾选.focus_mode = Control.FOCUS_NONE
	add_child(勾选)
	勾选.position = Vector2(81,2)
	勾选.size = Vector2(60,25)
	

func 创建LineEdit():
	var 文本编辑 = LineEdit.new()
	文本编辑.text = ""
	await get_tree().process_frame
	if Global.选择管理器.选中列表.size() >=1:
		var 选中 = Global.选择管理器.选中列表[0]
		if 选中 is Bone2D:
			文本编辑.text = String.num(选中.get_length(),3)
	文本编辑.flat = true
	文本编辑.position = Vector2(71,28)
	文本编辑.size = Vector2(205,26)
	文本编辑.set("theme_override_styles/focus",StyleBoxEmpty.new())
	文本编辑.set("theme_override_font_sizes/font_size",13)
	add_child(文本编辑)
	文本编辑.text_changed.connect(_on_LineEdit_text_changed)
	
func 创建ColorPickerButton():
	var 颜色 = ColorPickerButton.new()
	颜色.position = Vector2(82,86)
	颜色.size = Vector2(54,20)
	颜色.focus_mode = Control.FOCUS_NONE
	add_child(颜色)
	await get_tree().process_frame
	if Global.选择管理器.选中列表.size() >=1:
		var 选中 = Global.选择管理器.选中列表[0]
		颜色.color = 选中.self_modulate
	颜色.color_changed.connect(_on_ColorPickerButton_color_changed)
	


func _on_resized():
	custom_minimum_size.y = 行数 * 27
	size.y = 行数 * 27
	装饰板.size = size
	装饰板.size.x = 70

func _on_LineEdit_text_changed(new_text: String):
	if Global.选择管理器.选中列表.size() >=1:
		var 选中 = Global.选择管理器.选中列表[0]
		if 选中 is Bone2D:
			选中.set_length(float(new_text))

func _on_ColorPickerButton_color_changed(color: Color):
	if Global.选择管理器.选中列表.size() >=1:
		var 选中 = Global.选择管理器.选中列表[0]
		选中.self_modulate = color


func _draw() -> void:
	for i in range(1,行数):
		draw_line(Vector2(0,i*27),Vector2(size.x,i*27),Color("#6d6d6d"),1.3)
		RenderingServer.canvas_item_add_line(装饰板.get_canvas_item(),Vector2(0,i*27),Vector2(装饰板.size.x,i*27),Color("#6d6d6d"),1.3)
