extends PanelContainer


var vbox
var 标题字 = "Axes"
var 模式

var 本地
var 父级
var 世界

signal 切换轴模式(模式)

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


func 创建按钮(value):
	var bt = preload("res://按钮组面板控件/按钮控件/按钮控件.gd").new()
	vbox.add_child(bt)
	bt.点击按钮.connect(_on_点击按钮)
	bt.toggle_mode = true
	bt.设置文字(value)
	return bt

func 初始化():
	z_index = 1
	custom_minimum_size = Vector2(86,85)
	position = Vector2(457,550)
	size = Vector2(86,85)
	本地 = 创建按钮("本地")
	父级 = 创建按钮("父级")
	世界 = 创建按钮("世界")
	世界.button_pressed = true


func _on_点击按钮(target,toggled_on:bool):
	if toggled_on:
		模式 = target
		if target != 本地:
			本地.选中(false)
		if target != 父级:
			父级.选中(false)
		if target != 世界:
			世界.选中(false)
		
		if target == 本地:
			Global.轴模式 = "本地"
		elif target == 父级:
			Global.轴模式 = "父级"
		elif target == 世界:
			Global.轴模式 = "世界"
		切换轴模式.emit(Global.轴模式)


func _draw() -> void:
	var default_font = ThemeDB.fallback_font
	var tran:Transform2D
	tran = tran.rotated(deg_to_rad(-90))
	draw_set_transform_matrix(tran)
	var font_lenth = default_font.get_string_size(标题字,HORIZONTAL_ALIGNMENT_CENTER, -1, 10)
	var pos = tran.affine_inverse() * Vector2(15,get_rect().size.y/2+font_lenth.x/2)
	
	draw_string(default_font, pos, 标题字, HORIZONTAL_ALIGNMENT_CENTER, -1, 10,Color("#8ce6ef"))
