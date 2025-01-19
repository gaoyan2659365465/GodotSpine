extends Control

var 背景
var 子面板
var tree:Tree

var 悬浮子项 = null
var 进入眼睛区域 = false


func _ready() -> void:
	创建背景()
	创建子面板()
	创建树()
	await get_tree().process_frame
	Global.选择管理器.更改预选中.connect(_on_更改预选中)
	Global.选择管理器.更改选中.connect(_on_更改选中)
	Global.添加节点.connect(_on_添加节点)
	Global.重命名节点.connect(_on_重命名节点)
	Global.删除节点.connect(_on_删除节点)
	Global.复制节点.connect(_on_复制节点)
	递归所有节点(Global.根节点,tree.create_item())
	
	resized.connect(_on_resized)
	_on_resized()


func 创建背景():
	背景 = Panel.new()
	add_child(背景)
	背景.show_behind_parent = true
	背景.size = size
	背景.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var n_style = StyleBoxFlat.new()
	n_style.bg_color = Color("#585858")
	n_style.border_width_left = 1
	n_style.border_width_top = 1
	n_style.border_width_right = 1
	n_style.border_width_bottom = 1
	n_style.border_color = Color("#6d6d6d")
	n_style.corner_radius_top_left = 5
	n_style.corner_radius_top_right = 5
	n_style.corner_radius_bottom_right = 5
	n_style.corner_radius_bottom_left = 5
	背景.set("theme_override_styles/panel",n_style)

func 绘制背景线条():
	var 眼睛 = preload("res://资源/眼睛.svg")
	var 钥匙 = preload("res://资源/钥匙.svg")
	draw_texture_rect(眼睛,Rect2(Vector2(5,5),Vector2(15,15)),false)
	draw_texture_rect(钥匙,Rect2(Vector2(5+23,5),Vector2(15,15)),false)
	
	var default_font = ThemeDB.fallback_font
	draw_string(default_font, Vector2(23*2+4,15), "Hierarchy", HORIZONTAL_ALIGNMENT_CENTER, -1, 13,Color("#c3c3c3"))
	
	draw_line(Vector2(0,23), Vector2(get_rect().size.x,23), Color("#6d6d6d"),-1)
	draw_line(Vector2(23,0), Vector2(23,get_rect().size.y), Color("#6d6d6d"),-1)
	draw_line(Vector2(23*2,0), Vector2(23*2,get_rect().size.y), Color("#6d6d6d"),-1)


func 创建子面板():
	子面板 = Control.new()
	add_child(子面板)
	子面板.clip_contents = true
	子面板.size = size
	子面板.size.y -= 23
	子面板.position = Vector2(0,23)
	子面板.mouse_exited.connect(_on_子面板_mouse_exited)
	子面板.gui_input.connect(_on_子面板_gui_input)

func 创建树():
	tree = Tree.new()
	子面板.add_child(tree)
	tree.size = 子面板.size
	tree.size.x -= 46
	tree.position = Vector2(46,0)
	tree.focus_mode = Control.FOCUS_NONE
	tree.mouse_filter = Control.MOUSE_FILTER_PASS
	tree.hide_root = true
	tree.select_mode = Tree.SELECT_MULTI
	tree.set("theme_override_colors/guide_color",Color("#00000000"))
	tree.set("theme_override_colors/font_color",Color("#ffffff"))
	tree.set("theme_override_constants/v_separation",2)
	tree.set("theme_override_constants/h_separation",1)
	tree.set("theme_override_font_sizes/font_size",13)
	tree.set("theme_override_styles/selected",StyleBoxEmpty.new())
	tree.set("theme_override_styles/cursor_unfocused",StyleBoxEmpty.new())
	var flat = StyleBoxFlat.new()
	flat.bg_color = Color("#58585800")
	flat.border_color = Color("#6d6d6d")
	tree.set("theme_override_styles/panel",flat)
	tree.gui_input.connect(_on_tree_gui_input)
	tree.item_activated.connect(_on_tree_item_activated)

func 添加节点(node:Node,parent:TreeItem):
	var new_parent = tree.create_item(parent)
	new_parent.set_text(0, node.name)
	new_parent.set_icon(0,preload("res://资源/准星十字.svg"))
	new_parent.set_icon_max_width(0,15)
	new_parent.set_meta("node",node)
	new_parent.set_meta("node_type","Bone2D")
	node.set_script(preload("res://骨骼.gd"))
	node._ready()
	node.set_process_input(true)
	node.set_process(true)


func 递归所有节点(target:Node,parent:TreeItem):
	for i in target.get_children():
		var new_parent
		if i is Skeleton2D:
			new_parent = tree.create_item(parent)
			new_parent.set_text(0, i.name)
			new_parent.set_icon(0,preload("res://资源/姿势.svg"))
			new_parent.set_icon_max_width(0,15)
			new_parent.set_meta("node",i)
			new_parent.set_meta("node_type","Skeleton2D")
		elif i is Bone2D:
			new_parent = tree.create_item(parent)
			new_parent.set_text(0, i.name)
			new_parent.set_icon(0,preload("res://资源/准星十字.svg"))
			new_parent.set_icon_max_width(0,15)
			new_parent.set_meta("node",i)
			new_parent.set_meta("node_type","Bone2D")
			i.set_script(preload("res://骨骼.gd"))
			i._ready()
			i.set_process_input(true)
			i.set_process(true)
		elif i is Sprite2D:
			new_parent = tree.create_item(parent)
			new_parent.set_text(0, i.name)
			new_parent.set_icon(0,preload("res://资源/矩形.svg"))
			new_parent.set_icon_max_width(0,14)
			new_parent.set_meta("node",i)
			new_parent.set_meta("node_type","Sprite2D")
			i.set_script(preload("res://图片.gd"))
			i._ready()
			i.set_process_input(true)
			i.set_process(true)
		elif i is Node2D:
			new_parent = tree.create_item(parent)
			new_parent.set_text(0, i.name)
			new_parent.set_icon(0,preload("res://资源/通知.svg"))
			new_parent.set_icon_max_width(0,14)
			new_parent.set_meta("node",i)
			new_parent.set_meta("node_type","插槽")
		
		递归所有节点(i,new_parent)

func 递归所有单元格(parent:TreeItem,items:Array):
	if parent == null:
		return []
	if parent.get_children().size() == 0:
		items.append(parent)
	for i in parent.get_children():
		items.append(i)
		items = 递归所有单元格(i,items)
	return items

func 选择单元格(node):
	tree.deselect_all()
	var items = 递归所有单元格(tree.get_root(),[])
	for i in items:
		if i.get_meta("node") == node:
			tree.set_selected(i,0)# 根据元数据中的node引用判断选中的哪个
			tree.scroll_to_item(i)

func 获取选中单元格():
	var items = []
	var select = tree.get_root()
	while select:
		select = tree.get_next_selected(select)
		if select:
			items.append(select)
	return items

func 根据节点获取单元格(node):
	var items = 递归所有单元格(tree.get_root(),[])
	for i in items:
		if i.get_meta("node") == node:
			return i
	return null

func 获取单元格尺寸(item:TreeItem,计算间距=false):
	if item:
		var rect = tree.get_item_area_rect(item)
		var scroll_pos = tree.get_scroll()
		rect.position -= scroll_pos
		rect.position.y += position.y
		if 计算间距:
			rect.size.y += tree.get("theme_override_constants/v_separation")# 加上间距
		return rect
	return Rect2(Vector2.ZERO,Vector2.ZERO)

func 获取单元格(pos:Vector2):
	return tree.get_item_at_position(pos-tree.global_position)


func _on_更改预选中():
	悬浮子项 = 根据节点获取单元格(Global.选择管理器.预选中)
	queue_redraw()

func _on_更改选中():
	# 鼠标在视口中点击选择图片，树列表中也应该同时被选中
	if Global.选择管理器.选中列表.size() == 1:
		选择单元格(Global.选择管理器.选中列表[0])
	elif Global.选择管理器.选中列表.size() == 0:
		选择单元格(null)
	queue_redraw()

func _on_添加节点(node:Node2D):
	var 父节点 = node.get_parent()
	var parent = 根据节点获取单元格(父节点)
	添加节点(node,parent)

func _on_重命名节点(node:Node2D):
	var parent:TreeItem = 根据节点获取单元格(node)
	parent.set_text(0,node.name)

func _on_删除节点(node:Node2D):
	var item:TreeItem = 根据节点获取单元格(node)
	var parent = item.get_parent()
	parent.remove_child(item)

func _on_复制节点(old_node:Node2D,new_node:Node2D):
	tree.clear()
	递归所有节点(Global.根节点,tree.create_item())
	queue_redraw()


func _on_子面板_mouse_exited():
	悬浮子项 = null
	Global.选择管理器.预选中目标(null)
	进入眼睛区域 = false
	queue_redraw()

func _on_子面板_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and event.position.x < 23 && 悬浮子项:# 点击眼睛
				# 鼠标悬浮到眼睛
				var node = 悬浮子项.get_meta("node")
				node.visible = not node.visible
			
			var 选中列表 = []
			for i in 获取选中单元格():
				选中列表.append(i.get_meta("node"))
			Global.选择管理器.设置选中列表(选中列表)
			
	if event is InputEventMouseMotion:
		# 获取鼠标指向的TreeItem
		var mouse_pos = get_global_mouse_position()
		悬浮子项 = 获取单元格(mouse_pos)
		if 悬浮子项:
			var node = 悬浮子项.get_meta("node")
			#if 悬浮子项.get_meta("node_type") == "插槽":
			#	if node.get_child_count() > 1:
			#		printerr("层级数：插槽中存在多个子项，无法选中")
			#	node = node.get_child(0)# BUG 此处有隐患，插槽中未必有精灵图片节点
			#Global.选择管理器.预选中目标(node)
		else:
			Global.选择管理器.预选中目标(null)
		if event.position.x < 23:# 鼠标悬浮到眼睛
			进入眼睛区域 = true
		else:
			进入眼睛区域 = false

func _on_tree_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				var item = tree.get_item_at_position(event.position)
				if item:
					item.set_collapsed_recursive(not item.collapsed)# 右键展开

func _on_tree_item_activated():
	# 双击触发重命名
	Global.绘制控件.绘制弹窗()



func _on_resized():
	背景.size = size
	子面板.size = size
	子面板.size.y -= 23
	tree.size = 子面板.size
	tree.size.x -= 46
	
	

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	绘制背景线条()
	
	RenderingServer.canvas_item_clear(子面板.get_canvas_item())
	RenderingServer.canvas_item_set_clip(子面板.get_canvas_item(),true)
	RenderingServer.canvas_item_set_custom_rect(get_canvas_item(),true,子面板.get_rect())

	# 绘制鼠标悬浮矩形
	if 悬浮子项:
		var xuanfu_rect = 获取单元格尺寸(悬浮子项)
		xuanfu_rect.size.x = 子面板.get_rect().size.x# 保证足够长
		RenderingServer.canvas_item_add_rect(子面板.get_canvas_item(),xuanfu_rect,Color("#646464"))
	
	for i in 获取选中单元格():
		var rect = 获取单元格尺寸(i,true)
		rect.size.x = 子面板.get_rect().size.x# 保证足够长
		RenderingServer.canvas_item_add_rect(子面板.get_canvas_item(),rect,Color("#728181"))
	
	# 绘制圆点
	for item in 递归所有单元格(tree.get_root(),[]):
		var node = item.get_meta("node")
		var rect = 获取单元格尺寸(item,true)
		var color = Color("#b1b1b1")
		if not node.visible:
			color = Color(0.426, 0.426, 0.426)
		RenderingServer.canvas_item_add_circle(子面板.get_canvas_item(),rect.position+Vector2(10,10),3,color,true)


	if 进入眼睛区域 && 悬浮子项:
		var node = 悬浮子项.get_meta("node")
		var xuanfu_rect = 获取单元格尺寸(悬浮子项)
		var color = Color(1, 1, 1)
		if not node.visible:
			color = Color(1, 1, 1, 0)
		RenderingServer.canvas_item_add_circle(子面板.get_canvas_item(),xuanfu_rect.position+Vector2(10,10),3,color,true)
	
	# 绘制线条
	RenderingServer.canvas_item_add_line(子面板.get_canvas_item(),Vector2(23,0), Vector2(23,get_rect().size.y), Color("#6d6d6d"),-1)
	RenderingServer.canvas_item_add_line(子面板.get_canvas_item(),Vector2(23*2,0), Vector2(23*2,get_rect().size.y), Color("#6d6d6d"),-1)
	
