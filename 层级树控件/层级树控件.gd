extends Tree




func _ready():
	解析场景()
	await get_tree().process_frame
	Global.选择管理器.更改选中.connect(_on_更改选中)
	Global.添加节点.connect(_on_添加节点)


func 添加节点(node:Node,parent:TreeItem):
	var new_parent = create_item(parent)
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
			new_parent = create_item(parent)
			new_parent.set_text(0, i.name)
			new_parent.set_icon(0,preload("res://资源/姿势.svg"))
			new_parent.set_icon_max_width(0,15)
			new_parent.set_meta("node",i)
			new_parent.set_meta("node_type","Skeleton2D")
		elif i is Bone2D:
			new_parent = create_item(parent)
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
			new_parent = create_item(parent)
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
			new_parent = create_item(parent)
			new_parent.set_text(0, i.name)
			new_parent.set_icon(0,preload("res://资源/通知.svg"))
			new_parent.set_icon_max_width(0,14)
			new_parent.set_meta("node",i)
			new_parent.set_meta("node_type","插槽")
		
		递归所有节点(i,new_parent)

func 解析场景():
	await get_tree().process_frame
	var root = create_item()
	hide_root = true
	递归所有节点(Global.根节点,root)

func 获取单元格框(pos:Vector2):
	var item:TreeItem = get_item_at_position(pos-global_position)
	if item:
		var rect = get_item_area_rect(item)
		var scroll_pos = get_scroll()
		rect.position -= scroll_pos
		var px = rect.position.x
		rect.position.y += position.y
		rect = rect.intersection(get_rect())# 裁剪，不超出tree的高度
		rect.position.x = px
		return rect
	return Rect2(Vector2.ZERO,Vector2.ZERO)

func 获取单元格(pos:Vector2):
	return get_item_at_position(pos-global_position)

func 获取单元格尺寸(item:TreeItem,计算间距=false):
	if item:
		var rect = get_item_area_rect(item)
		var scroll_pos = get_scroll()
		rect.position -= scroll_pos
		rect.position.y += position.y
		if 计算间距:
			rect.size.y += get("theme_override_constants/v_separation")# 加上间距
		return rect
	return Rect2(Vector2.ZERO,Vector2.ZERO)


func 获取选中单元格():
	var items = []
	var select = get_root()
	while select:
		select = get_next_selected(select)
		if select:
			items.append(select)
	return items


func 递归所有单元格(parent:TreeItem,items:Array):
	if parent.get_children().size() == 0:
		items.append(parent)
	for i in parent.get_children():
		items.append(i)
		items = 递归所有单元格(i,items)
	return items

func 获取所有单元格():
	var items = []
	var item = get_root()
	if item:
		items = 递归所有单元格(item,[])
	return items

func 根据节点获取单元格(node):
	var items = 获取所有单元格()
	for i in items:
		if i.get_meta("node") == node:
			return i
	return null

func 选择单元格(node):
	var items = 获取所有单元格()
	for i in items:
		if i.get_meta("node") == node:
			set_selected(i,0)# 根据元数据中的node引用判断选中的哪个
			scroll_to_item(i)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				var item = get_item_at_position(event.position)
				if item:
					item.set_collapsed_recursive(not item.collapsed)# 右键展开


func _on_更改选中():
	# 鼠标在视口中点击选择图片，树列表中也应该同时被选中
	if Global.选择管理器.选中列表.size() == 1:
		选择单元格(Global.选择管理器.选中列表[0])


func _on_添加节点(node:Node2D):
	var 父节点 = node.get_parent()
	var parent = 根据节点获取单元格(父节点)
	添加节点(node,parent)
