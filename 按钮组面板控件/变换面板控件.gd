extends PanelContainer


var vbox
var 标题字 = "Transform"
var 模式

var 旋转
var 移动
var 缩放
var 倾斜


func _ready() -> void:
	var mc = MarginContainer.new()
	add_child(mc)
	mc.set("theme_override_constants/margin_left",20)
	mc.set("theme_override_constants/margin_top",5)
	mc.set("theme_override_constants/margin_right",5)
	mc.set("theme_override_constants/margin_bottom",5)
	vbox = VBoxContainer.new()
	mc.add_child(vbox)
	vbox.set("theme_override_constants/separation",2)
	初始化()
	Global.设置轴模式.connect(_on_设置轴模式)
	Global.绘制控件.更新变换.connect(_on_更新变换)


func 创建按钮输入框(value):
	var bt = preload("res://按钮组面板控件/按钮输入框.gd").new()
	vbox.add_child(bt)
	bt.设置文字(value)
	bt.点击按钮.connect(_on_点击按钮)
	bt.文本修改.connect(_on_文本修改)
	return bt

func 初始化():
	z_index = 1
	custom_minimum_size = Vector2(88,88)
	position = Vector2(219,516)
	size = Vector2(233,112)
	旋转 = 创建按钮输入框("旋转")
	移动 = 创建按钮输入框("移动")
	缩放 = 创建按钮输入框("缩放")
	倾斜 = 创建按钮输入框("倾斜")
	移动.选中(true)
	Global.选择管理器.更改选中.connect(_on_更改选中)


func _on_点击按钮(target,toggled_on:bool):
	if toggled_on:
		模式 = target
		if target != 旋转:
			旋转.选中(false)
		if target != 移动:
			移动.选中(false)
		if target != 缩放:
			缩放.选中(false)
		if target != 倾斜:
			倾斜.选中(false)
			
		if target == 旋转:
			Global.变换模式 = "旋转"
		elif target == 移动:
			Global.变换模式 = "移动"
		elif target == 缩放:
			Global.变换模式 = "缩放"
		elif target == 倾斜:
			Global.变换模式 = "倾斜"


func _on_文本修改(target,n,new_text: String):
	if target == 旋转:
		for i:Node2D in Global.选择管理器.选中列表:
			if Global.轴模式 == "本地" or Global.轴模式 == "父级":
				i.rotation_degrees = float(new_text)
			elif Global.轴模式 == "世界":
				i.global_rotation_degrees = float(new_text)
	elif target == 移动:
		for i:Node2D in Global.选择管理器.选中列表:
			if n == 1:
				if Global.轴模式 == "本地" or Global.轴模式 == "父级":
					i.position.x = float(new_text)
				elif Global.轴模式 == "世界":
					i.global_position.x = float(new_text)
			if n == 2:
				if Global.轴模式 == "本地" or Global.轴模式 == "父级":
					i.position.y = float(new_text)
				elif Global.轴模式 == "世界":
					i.global_position.y = float(new_text)
	elif target == 缩放:
		for i:Node2D in Global.选择管理器.选中列表:
			if n == 1:
				i.scale.x = float(new_text)
			if n == 2:
				i.scale.y = float(new_text)
	elif target == 倾斜:
		for i:Node2D in Global.选择管理器.选中列表:
			if n == 1:
				i.skew = float(new_text)
			if n == 2:
				i.skew = float(new_text)



func _on_更改选中():
	for i:Node2D in Global.选择管理器.选中列表:
		if Global.轴模式 == "本地" or Global.轴模式 == "父级":
			旋转.设置值(i.rotation_degrees)
			移动.设置值(i.position)
		elif Global.轴模式 == "世界":
			旋转.设置值(i.global_rotation_degrees)
			移动.设置值(i.global_position)
		缩放.设置值(i.scale)
		倾斜.设置值(i.skew)
	if Global.选择管理器.选中列表 == []:
		旋转.设置值('')
		移动.设置值('')
		缩放.设置值('')
		倾斜.设置值('')

func _on_设置轴模式(value):
	_on_更改选中()

func _on_更新变换():
	_on_更改选中()

func _draw() -> void:
	var default_font = ThemeDB.fallback_font
	var tran:Transform2D
	tran = tran.rotated(deg_to_rad(-90))
	draw_set_transform_matrix(tran)
	var font_lenth = default_font.get_string_size(标题字,HORIZONTAL_ALIGNMENT_CENTER, -1, 10)
	var pos = tran.affine_inverse() * Vector2(15,get_rect().size.y/2+font_lenth.x/2)
	
	draw_string(default_font, pos, 标题字, HORIZONTAL_ALIGNMENT_CENTER, -1, 10,Color("#8ce6ef"))
