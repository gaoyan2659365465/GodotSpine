extends Control

@onready var tree: Tree = $Tree

signal 悬浮(target)
signal 选中(target)
signal 切换显示(target,value)

var 悬浮子项
var 进入眼睛区域 = false

func _ready() -> void:
	clip_contents = true# 裁剪
	mouse_exited.connect(_on_mouse_exited)
	await get_tree().process_frame
	Global.选择管理器.更改预选中.connect(_on_更改预选中)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:# 点击眼睛
				if event.position.x < 23 && 悬浮子项:# 鼠标悬浮到眼睛
					self.切换显示.emit(悬浮子项)
					var node = 悬浮子项.get_meta("node")
					node.visible = not node.visible
			
			var 选中列表 = []
			for i in tree.获取选中单元格():
				选中列表.append(i.get_meta("node"))
			Global.选择管理器.设置选中列表(选中列表)
			
	if event is InputEventMouseMotion:
		# 获取鼠标指向的TreeItem
		var mouse_pos = get_global_mouse_position()
		悬浮子项 = tree.获取单元格(mouse_pos)
		if 悬浮子项:
			self.悬浮.emit(悬浮子项)
			var node = 悬浮子项.get_meta("node")
			if 悬浮子项.get_meta("node_type") == "插槽":
				if node.get_child_count() > 1:
					printerr("层级数：插槽中存在多个子项，无法选中")
				node = node.get_child(0)# BUG 此处有隐患，插槽中未必有精灵图片节点
			Global.选择管理器.预选中目标(node)
		else:
			Global.选择管理器.预选中目标(null)
		if event.position.x < 23:# 鼠标悬浮到眼睛
			进入眼睛区域 = true
		else:
			进入眼睛区域 = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE:
			Global.选择管理器.设置选中列表([])
	queue_redraw()

func _on_mouse_exited():
	悬浮子项 = null
	Global.选择管理器.预选中目标(null)
	进入眼睛区域 = false
	queue_redraw()

func _on_更改预选中():
	悬浮子项 = tree.根据节点获取单元格(Global.选择管理器.预选中)
	queue_redraw()


func _draw() -> void:
	
	# 绘制鼠标悬浮矩形
	if 悬浮子项:
		var xuanfu_rect = tree.获取单元格尺寸(悬浮子项)
		xuanfu_rect.size.x = get_rect().size.x# 保证足够长
		draw_rect(xuanfu_rect,Color("#646464"))
	
	for i in tree.获取选中单元格():
		var rect = tree.获取单元格尺寸(i,true)
		rect.size.x = get_rect().size.x# 保证足够长
		draw_rect(rect,Color("#728181"))
	
	# 绘制圆点
	for item in tree.获取所有单元格():
		var node = item.get_meta("node")
		var rect = tree.获取单元格尺寸(item,true)
		var color = Color("#b1b1b1")
		if node.visible:
			color = Color("#b1b1b1")
		else:
			color = Color(0.426, 0.426, 0.426)
		draw_circle(rect.position+Vector2(10,10),3,color,true,-1,true)


	if 进入眼睛区域 && 悬浮子项:
		var node = 悬浮子项.get_meta("node")
		var xuanfu_rect = tree.获取单元格尺寸(悬浮子项)
		var color = Color(1, 1, 1)
		if node.visible:
			color = Color(1, 1, 1)
		else:
			color = Color(1, 1, 1, 0)
		draw_circle(xuanfu_rect.position+Vector2(10,10),3,color,true,-1,true)
	
	
	# 绘制线条
	draw_line(Vector2(23,0), Vector2(23,get_rect().size.y), Color("#6d6d6d"),-1)
	draw_line(Vector2(23*2,0), Vector2(23*2,get_rect().size.y), Color("#6d6d6d"),-1)
	
