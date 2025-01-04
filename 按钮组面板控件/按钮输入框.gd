extends Panel

var 按钮
var hbox
var 输入框 = []

signal 点击按钮(target,toggled_on:bool)
signal 文本修改(target,n,new_text: String)# n指定哪个框1和2


func _ready() -> void:
	custom_minimum_size = Vector2(208,27)
	
	hbox = HBoxContainer.new()
	add_child(hbox)
	hbox.set("theme_override_constants/separation",1)
	
	按钮 = preload("res://按钮组面板控件/按钮控件/按钮控件.gd").new()
	hbox.add_child(按钮)
	按钮.设置文字("旋转")
	按钮.取消圆角()
	按钮.toggle_mode = true
	按钮.toggled.connect(_on_button_toggled)


func 设置文字(value):
	按钮.设置文字(value)
	if value == "旋转":
		按钮.icon = preload("res://资源/旋转.svg")
		创建输入框(1)
	elif value == "移动":
		按钮.icon = preload("res://资源/移动.svg")
		创建输入框(2)
	elif value == "缩放":
		按钮.icon = preload("res://资源/缩放.svg")
		创建输入框(2)
	elif value == "倾斜":
		按钮.icon = preload("res://资源/倾斜.svg")
		创建输入框(2)

func 设置值(value):
	if str(value) == "":# 按空格后清空内容
		for i in 输入框:
			i.text = value
		return
		
	if 按钮.text == "旋转":
		输入框[0].text = String.num(value,3)
	if 按钮.text == "移动":
		输入框[0].text = String.num(value.x,3)
		输入框[1].text = String.num(value.y,3)
	if 按钮.text == "缩放":
		输入框[0].text = String.num(value.x,4)
		输入框[1].text = String.num(value.y,4)
	if 按钮.text == "倾斜":
		输入框[0].text = String.num(value,3)
		输入框[1].text = String.num(value,3)


func 创建输入框(n=1):
	if n == 1:
		var 输入框1 = preload("res://按钮组面板控件/输入框控件/输入框控件.gd").new()
		hbox.add_child(输入框1)
		输入框1.text_changed.connect(_on_输入框_text_changed)
		输入框.append(输入框1)
		
	elif n == 2:
		var 输入框1 = preload("res://按钮组面板控件/输入框控件/输入框控件.gd").new()
		hbox.add_child(输入框1)
		输入框1.text_changed.connect(_on_输入框_text_changed)
		输入框1.custom_minimum_size = Vector2(60,23)
		var 输入框2 = preload("res://按钮组面板控件/输入框控件/输入框控件.gd").new()
		hbox.add_child(输入框2)
		输入框2.text_changed.connect(_on_输入框2_text_changed)
		输入框2.custom_minimum_size = Vector2(60,23)
		输入框.append(输入框1)
		输入框.append(输入框2)


func 选中(value):
	按钮.选中(value)

func _on_button_toggled(toggled_on: bool) -> void:
	# 按钮切换
	点击按钮.emit(self,toggled_on)

func _on_输入框_text_changed(new_text: String):
	文本修改.emit(self,1,new_text)

func _on_输入框2_text_changed(new_text: String):
	文本修改.emit(self,2,new_text)


func _draw() -> void:
	var tex = preload("res://资源/钥匙.svg")
	draw_texture_rect(tex,Rect2(Vector2(120+64+1,1),Vector2(22,22)),false,Color(0.254, 0.254, 0.254))
