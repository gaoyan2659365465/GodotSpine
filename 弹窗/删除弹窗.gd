extends PanelContainer

var hbox
var 确定
var 取消
var 标题字 = "确认删除"

func _ready() -> void:
	var mc = MarginContainer.new()
	add_child(mc)
	mc.set("theme_override_constants/margin_top",73)
	mc.set("theme_override_constants/margin_bottom",11)
	hbox = HBoxContainer.new()
	mc.add_child(hbox)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	初始化()


func 创建按钮(value):
	var bt = preload("res://按钮组面板控件/按钮控件/按钮控件.gd").new()
	hbox.add_child(bt)
	bt.点击按钮2.connect(_on_按钮按下)
	bt.设置文字(value)
	return bt


func 初始化():
	size = Vector2(227,100)
	position = Vector2(322,252)
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#494849")
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color("#000000")
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	style.shadow_color = Color("#2967958b")
	style.shadow_size = 9
	set("theme_override_styles/panel",style)
	
	确定 = 创建按钮("确定")
	确定.icon = preload("res://资源/确定.svg")
	取消 = 创建按钮("取消")
	取消.icon = preload("res://资源/取消.svg")


func _on_按钮按下(target):
	if 取消 == target:
		queue_free()
	if 确定 == target:
		if Global.选择管理器.选中列表.size() >= 1:
			var node = Global.选择管理器.选中列表[0]
			Global.选择管理器.设置选中列表([])
			Global.删除节点.emit(node)
			node.queue_free()
		queue_free()


func _draw() -> void:
	var points = [Vector2(1,1),Vector2(100,1),Vector2(85,28),Vector2(1,28)]
	draw_colored_polygon(points,Color("#296795"))
	
	draw_rect(Rect2(Vector2(1,28),Vector2(get_rect().size.x-2,35)),Color("#373737"))
	
	var default_font = ThemeDB.fallback_font
	draw_string(default_font, Vector2(10,20), 标题字, HORIZONTAL_ALIGNMENT_CENTER, -1, 14,Color(1, 1, 1))
	draw_string(default_font, Vector2(10,50), "确定要删除此骨骼和所有子骨骼？", HORIZONTAL_ALIGNMENT_CENTER, -1, 13,Color(1, 1, 1))
	
	
