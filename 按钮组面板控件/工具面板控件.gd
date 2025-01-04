extends PanelContainer

var vbox
var 标题字 = "Tools"
var 模式

var 姿势
var 权重
var 创建


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
	custom_minimum_size = Vector2(88,85)
	position = Vector2(125,550)
	size = Vector2(88,85)
	姿势 = 创建按钮("姿势")
	权重 = 创建按钮("权重")
	创建 = 创建按钮("创建")

func _on_点击按钮(target,toggled_on:bool):
	if toggled_on:
		模式 = target
		if target != 姿势:
			姿势.选中(false)
		if target != 权重:
			权重.选中(false)
		if target != 创建:
			创建.选中(false)
		Global.变换模式 = "倾斜"# 暂时未做倾斜功能，留空
		
		if target == 姿势:
			Global.工具模式 = "姿势"
		elif target == 权重:
			Global.工具模式 = "权重"
		elif target == 创建:
			Global.工具模式 = "创建"



func _draw() -> void:
	var default_font = ThemeDB.fallback_font
	var tran:Transform2D
	tran = tran.rotated(deg_to_rad(-90))
	draw_set_transform_matrix(tran)
	var font_lenth = default_font.get_string_size(标题字,HORIZONTAL_ALIGNMENT_CENTER, -1, 10)
	var pos = tran.affine_inverse() * Vector2(15,get_rect().size.y/2+font_lenth.x/2)
	
	draw_string(default_font, pos, 标题字, HORIZONTAL_ALIGNMENT_CENTER, -1, 10,Color("#8ce6ef"))
