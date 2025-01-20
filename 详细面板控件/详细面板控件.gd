@tool
extends VBoxContainer

var 标题字 = ""

var vbox


func _ready() -> void:
	创建子项()
	await get_tree().process_frame
	Global.选择管理器.更改选中.connect(_on_更改选中)
	Global.重命名节点.connect(_on_重命名节点)
	resized.connect(_on_resized)
	_on_resized()
	_on_更改选中()# 因为该界面生成就是由于选中触发的，所以直接调用
	


func 创建子项():
	var hbox = HBoxContainer.new()
	add_child(hbox)
	hbox.custom_minimum_size = Vector2(0,25)
	hbox.alignment = BoxContainer.ALIGNMENT_END
	
	var bt1 = Button.new()
	bt1.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bt1.icon = preload("res://资源/复制.svg")
	bt1.expand_icon = true
	bt1.focus_mode = Control.FOCUS_NONE
	bt1.set("theme_override_constants/icon_max_width",15)
	bt1.set("theme_override_styles/focus",StyleBoxEmpty.new())
	bt1.pressed.connect(_on_bt1_pressed)
	
	var style1 = StyleBoxFlat.new()
	style1.bg_color = Color("#666666")
	style1.corner_radius_top_left = 5
	style1.corner_radius_top_right = 5
	style1.corner_radius_bottom_right = 5
	style1.corner_radius_bottom_left = 5
	bt1.set("theme_override_styles/normal",style1)
	var style2 = StyleBoxFlat.new()
	style2.bg_color = Color("#28a9c7")
	style2.corner_radius_top_left = 5
	style2.corner_radius_top_right = 5
	style2.corner_radius_bottom_right = 5
	style2.corner_radius_bottom_left = 5
	bt1.set("theme_override_styles/pressed",style2)
	var style3 = StyleBoxFlat.new()
	style3.bg_color = Color("#c9c9c9")
	style3.corner_radius_top_left = 5
	style3.corner_radius_top_right = 5
	style3.corner_radius_bottom_right = 5
	style3.corner_radius_bottom_left = 5
	bt1.set("theme_override_styles/hover",style3)
	bt1.custom_minimum_size = Vector2(28,0)
	hbox.add_child(bt1)
	
	var bt2 = Button.new()
	bt2.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bt2.icon = preload("res://资源/重命名.svg")
	bt2.expand_icon = true
	bt2.focus_mode = Control.FOCUS_NONE
	bt2.set("theme_override_constants/icon_max_width",19)
	bt2.set("theme_override_styles/focus",StyleBoxEmpty.new())
	bt2.set("theme_override_styles/normal",style1)
	bt2.set("theme_override_styles/pressed",style2)
	bt2.set("theme_override_styles/hover",style3)
	bt2.custom_minimum_size = Vector2(28,0)
	hbox.add_child(bt2)
	bt2.pressed.connect(_on_bt2_pressed)
	
	var bt3 = Button.new()
	bt3.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bt3.icon = preload("res://资源/关闭.svg")
	bt3.expand_icon = true
	bt3.focus_mode = Control.FOCUS_NONE
	bt3.set("theme_override_constants/icon_max_width",24)
	bt3.set("theme_override_styles/focus",StyleBoxEmpty.new())
	bt3.set("theme_override_styles/normal",style1)
	bt3.set("theme_override_styles/pressed",style2)
	bt3.set("theme_override_styles/hover",style3)
	bt3.custom_minimum_size = Vector2(28,0)
	hbox.add_child(bt3)
	bt3.pressed.connect(_on_bt3_pressed)
	
	if Global.选择管理器.选中列表.size() >=1:
		var 选中 = Global.选择管理器.选中列表[0]
		if 选中 as Bone2D:
			var p = preload("res://详细面板控件/骨骼详细面板.gd").new()
			add_child(p)
		elif 选中 as Sprite2D:
			var p = preload("res://详细面板控件/区域详细面板.gd").new()
			add_child(p)
		elif 选中 as Polygon2D:
			var p = preload("res://详细面板控件/区域详细面板.gd").new()
			add_child(p)
		elif 选中 as Node2D:
			var p = preload("res://详细面板控件/插槽详细面板.gd").new()
			add_child(p)


func _on_resized():
	pass
	

func _on_更改选中():
	if Global.选择管理器.选中列表.size() >=1:
		var 选中 = Global.选择管理器.选中列表[0]
		if 选中 is Sprite2D:
			标题字 = "区域："+选中.name
		elif 选中 is Bone2D:
			标题字 = "骨骼："+选中.name
		elif 选中 is Polygon2D:
			标题字 = "网格："+选中.name
		elif 选中 is Node2D:
			标题字 = "插槽："+选中.name
	queue_redraw()


func _on_重命名节点(node):
	_on_更改选中()


func _on_bt1_pressed():
	if Global.选择管理器.选中列表.size() >= 1:
		var node:Node2D = Global.选择管理器.选中列表[0]
		var new_node = node.duplicate()
		node.get_parent().add_child(new_node)
		node.get_parent().move_child(new_node,node.get_index()+1)
		Global.复制节点.emit(node,new_node)

func _on_bt2_pressed():
	Global.绘制控件.绘制弹窗()

func _on_bt3_pressed():
	Global.绘制控件.绘制删除弹窗()


func _draw() -> void:
	var default_font = ThemeDB.fallback_font
	draw_string(default_font, Vector2(2,17), 标题字, HORIZONTAL_ALIGNMENT_CENTER, -1, 13,Color("#8ce6ef"))
