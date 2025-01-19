@tool
extends Panel

var 行数 = 2
var 装饰板




func _ready() -> void:
	custom_minimum_size.y = 行数 * 27
	size.y = 行数 * 27
	self.size_flags_vertical = Control.SIZE_EXPAND_FILL
	创建装饰板()
	创建文字图标()
	创建CheckBox()
	创建ColorPickerButton()
	创建OptionButton()
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
	l.text = "混合"
	add_child(l)
	l.position = Vector2(28,5)
	l.set("theme_override_colors/font_color",Color("#eeeeee"))
	l.set("theme_override_font_sizes/font_size",12)
	var l4 = Label.new()
	l4.text = "颜色"
	add_child(l4)
	l4.position = Vector2(28,32)
	l4.set("theme_override_colors/font_color",Color("#eeeeee"))
	l4.set("theme_override_font_sizes/font_size",12)
	
	var tex = TextureRect.new()
	tex.texture = preload("res://资源/混合.svg")
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.size = Vector2(15,15)
	tex.position = Vector2(9,6)
	add_child(tex)
	
	var tex4 = TextureRect.new()
	tex4.texture = preload("res://资源/颜色.svg")
	tex4.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex4.size = Vector2(15,15)
	tex4.position = Vector2(9,34)
	add_child(tex4)
	

func 创建CheckBox():
	var 勾选 = CheckBox.new()
	勾选.text = "填入黑色"
	勾选.set("theme_override_constants/h_separation",4)
	勾选.set("theme_override_constants/check_v_offset",1)
	勾选.set("theme_override_font_sizes/font_size",12)
	勾选.focus_mode = Control.FOCUS_NONE
	add_child(勾选)
	勾选.position = Vector2(163,28)
	勾选.size = Vector2(60,25)

	
func 创建ColorPickerButton():
	var 颜色 = ColorPickerButton.new()
	颜色.position = Vector2(82,30)
	颜色.size = Vector2(54,20)
	颜色.focus_mode = Control.FOCUS_NONE
	add_child(颜色)
	await get_tree().process_frame
	if Global.选择管理器.选中列表.size() >=1:
		var 选中 = Global.选择管理器.选中列表[0]
		颜色.color = 选中.self_modulate
	颜色.color_changed.connect(_on_ColorPickerButton_color_changed)

func 创建OptionButton():
	var 选择框 = OptionButton.new()
	选择框.position = Vector2(71,2)
	选择框.size = Vector2(64,25)
	选择框.focus_mode = Control.FOCUS_NONE
	add_child(选择框)
	选择框.add_item("正常",0)
	选择框.add_item("相加",1)
	选择框.add_item("相乘",2)
	选择框.add_item("滤色",3)
	选择框.selected = 0
	选择框.flat = true
	选择框.set("theme_override_font_sizes/font_size",12)


func _on_resized():
	custom_minimum_size.y = 行数 * 27
	size.y = 行数 * 27
	装饰板.size = size
	装饰板.size.x = 70


func _on_ColorPickerButton_color_changed(color: Color):
	if Global.选择管理器.选中列表.size() >=1:
		var 选中 = Global.选择管理器.选中列表[0]
		选中.self_modulate = color


func _draw() -> void:
	for i in range(1,行数):
		draw_line(Vector2(0,i*27),Vector2(size.x,i*27),Color("#6d6d6d"),1.3)
		RenderingServer.canvas_item_add_line(装饰板.get_canvas_item(),Vector2(0,i*27),Vector2(装饰板.size.x,i*27),Color("#6d6d6d"),1.3)
