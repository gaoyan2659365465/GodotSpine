extends Control


var 绘制数据 = []

var 鼠标进入 = false

signal 更新变换

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered():
	鼠标进入 = true

func _on_mouse_exited():
	鼠标进入 = false
	Global.选择管理器.预选中目标(null)


func 绘制矩形虚线框(rect:Rect2,node):
	绘制数据.append(["矩形虚线框",rect,node])

func 绘制矩形实线框(rect:Rect2,node):
	绘制数据.append(["矩形实线框",rect,node])

func 绘制移动控件(pos:Vector2):
	绘制数据.append(["移动控件",pos])

func 绘制旋转控件(pos:Vector2,rot):
	绘制数据.append(["旋转控件",pos,rot])

func 绘制缩放控件(pos:Vector2):
	绘制数据.append(["缩放控件",pos])

func 绘制骨骼(node):
	绘制数据.append(["骨骼",node])

func _process(delta: float) -> void:
	queue_redraw()


var pressed = false
var mouse_pos = Vector2.ZERO
var node_pos = Vector2.ZERO
func _gui_input(event: InputEvent) -> void:
	if Global.变换模式 == "移动":
		移动逻辑(event)
		更新变换.emit()
	elif Global.变换模式 == "旋转":
		旋转逻辑(event)
		更新变换.emit()
	elif Global.变换模式 == "缩放":
		缩放逻辑(event)
		更新变换.emit()
	elif Global.变换模式 == "倾斜":
		if Global.工具模式 == "创建":
			创建骨骼逻辑(event)
	
func 移动逻辑(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pressed = event.pressed
			# BUG 只能移动单个，不能同时移动多个
			for i in Global.选择管理器.选中列表:
				mouse_pos = event.position
				node_pos = i.global_position
	if event is InputEventMouseMotion:
		# 鼠标进入变换控件区域后变成白色
		if pressed:# 左键拖拽
			# BUG 只能移动单个，不能同时移动多个
			for i in Global.选择管理器.选中列表:
				var tran = i.get_canvas_transform().affine_inverse()
				i.global_position = node_pos - (tran * mouse_pos-tran * event.position)

var initial_angle = 0.0  # 新增变量用于存储初始角度
var node_rot = 0.0  # 新增变量用于存储旋转角度
func 旋转逻辑(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pressed = event.pressed
			# BUG 只能移动单个，不能同时移动多个
			for i in Global.选择管理器.选中列表:
				var tran = i.get_canvas_transform().affine_inverse()
				mouse_pos = event.position
				initial_angle = i.global_position - tran * mouse_pos
				node_rot = i.rotation_degrees
	if event is InputEventMouseMotion:
		# 鼠标进入变换控件区域后变成白色
		if pressed:# 左键拖拽
			# BUG 只能移动单个，不能同时移动多个
			for i in Global.选择管理器.选中列表:
				var tran = i.get_canvas_transform().affine_inverse()
				var new_angle = initial_angle.angle_to(i.global_position - tran * event.position)
				# 更新节点的旋转角度
				i.rotation_degrees = node_rot + rad_to_deg(new_angle)

var node_scale = Vector2.ONE
func 缩放逻辑(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pressed = event.pressed
			# BUG 只能移动单个，不能同时移动多个
			for i in Global.选择管理器.选中列表:
				mouse_pos = event.position
				node_scale = i.scale
	if event is InputEventMouseMotion:
		# 鼠标进入变换控件区域后变成白色
		if pressed:# 左键拖拽
			# BUG 只能移动单个，不能同时移动多个
			for i in Global.选择管理器.选中列表:
				var tran = i.get_canvas_transform().affine_inverse()
				var s = mouse_pos.y-event.position.y
				i.scale = node_scale + Vector2(s,s)*0.01

var 拖拽一次 = false
var 选中骨骼
func 创建骨骼逻辑(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pressed = event.pressed
			if pressed:
				拖拽一次 = true# 按下时候拖拽一次，生成骨骼
			if not pressed:
				if mouse_pos == event.position:# 松开鼠标说明没有拖拽，原地生成骨骼
					# 判断当前选中骨骼是否是之前选中骨骼，如果切换选中则不生成新骨骼
					if Global.选择管理器.选中列表.size() >= 1:
						var 选中项 = Global.选择管理器.选中列表[0]
						if 选中项 == 选中骨骼:
							# 创建骨骼如果选中项不是骨骼就取消选中
							var 新骨 = Bone2D.new()
							选中项.add_child(新骨)
							新骨.set_autocalculate_length_and_angle(false)
							新骨.global_position = 新骨.get_global_mouse_position()
							新骨.rest = Transform2D(新骨.rotation, Vector2(新骨.position.x, 新骨.position.y))
							Global.添加节点.emit(新骨)
							Global.选择管理器.设置选中列表([新骨])
					
			mouse_pos = event.position
	if event is InputEventMouseMotion:
		if Global.选择管理器.选中列表.size() >= 1:
			选中骨骼 = Global.选择管理器.选中列表[0]
		if pressed:# 左键拖拽
			if 拖拽一次:
				if Global.选择管理器.选中列表.size() >= 1:
					var 选中项 = Global.选择管理器.选中列表[0]
					# 创建骨骼如果选中项不是骨骼就取消选中
					var 新骨 = Bone2D.new()
					选中项.add_child(新骨)
					新骨.set_autocalculate_length_and_angle(false)
					新骨.global_position = 新骨.get_global_mouse_position()
					新骨.rest = Transform2D(新骨.rotation, Vector2(新骨.position.x, 新骨.position.y))
					Global.添加节点.emit(新骨)
					Global.选择管理器.设置选中列表([新骨])
					拖拽一次 = false
			if Global.选择管理器.选中列表.size() >= 1:
				var 选中项:Bone2D = Global.选择管理器.选中列表[0]
				var 新位置 = 选中项.get_global_mouse_position()
				选中项.set_length(新位置.distance_to(选中项.global_position))
				选中项.set_bone_angle(选中项.global_position.angle_to_point(新位置))


# BUG 绘制框不会随着旋转而旋转
func _draw() -> void:
	for data in 绘制数据:
		if data[0] == "矩形虚线框":
			var rect = data[1]
			var node = data[2]
			var size = rect.size
			var pos = rect.position
			var tran:Transform2D
			tran = tran.rotated(deg_to_rad(node.global_rotation_degrees))
			draw_set_transform_matrix(tran)
			var 左上角 = pos
			var 右上角 = Vector2(pos.x+size.x,pos.y)
			var 左下角 = Vector2(pos.x,pos.y+size.y)
			var 右下角 = Vector2(pos.x+size.x,pos.y+size.y)
			draw_dashed_line(左上角,右上角,Color.WHITE,-1,5.0)
			draw_dashed_line(左上角,左下角,Color.WHITE,-1,5.0)
			draw_dashed_line(右上角,右下角,Color.WHITE,-1,5.0)
			draw_dashed_line(左下角,右下角,Color.WHITE,-1,5.0)
			draw_set_transform(Vector2.ZERO)
		elif data[0] == "矩形实线框":
			var rect = data[1]
			var node = data[2]
			var size = rect.size
			var pos = rect.position
			var tran:Transform2D
			tran = tran.rotated(deg_to_rad(node.global_rotation_degrees))
			draw_set_transform_matrix(tran)
			var 左上角 = pos
			var 右上角 = Vector2(pos.x+size.x,pos.y)
			var 左下角 = Vector2(pos.x,pos.y+size.y)
			var 右下角 = Vector2(pos.x+size.x,pos.y+size.y)
			draw_line(左上角,右上角,Color("#0ce6e6"),-1,5.0)
			draw_line(左上角,左下角,Color("#0ce6e6"),-1,5.0)
			draw_line(右上角,右下角,Color("#0ce6e6"),-1,5.0)
			draw_line(左下角,右下角,Color("#0ce6e6"),-1,5.0)
			var offset = 20.0
			var points = [左上角+Vector2(0,offset),左上角,
							左上角+Vector2(offset,0),左上角,
							右上角+Vector2(0,offset),右上角,
							右上角+Vector2(-offset,0),右上角,
							左下角+Vector2(offset,0),左下角,
							左下角+Vector2(0,-offset),左下角,
							右下角+Vector2(-offset,0),右下角,
							右下角+Vector2(0,-offset),右下角]
			draw_multiline(points,Color("#01fdfd"),2.0)
			draw_set_transform(Vector2.ZERO)
		elif data[0] == "移动控件":
			var pos = data[1]
			var 箭头 = preload("res://资源/箭头.svg")
			var tran:Transform2D
			tran = tran.rotated(deg_to_rad(-90))
			draw_set_transform_matrix(tran)
			draw_texture_rect(箭头,Rect2(tran.affine_inverse() * (pos+Vector2(3,23)),Vector2(46,33)),false,Color(0, 0, 0, 0.431))
			draw_texture_rect(箭头,Rect2(tran.affine_inverse() * (pos+Vector2(7,20)),Vector2(40,28)),false,Color(1, 0, 0))
			tran = tran.rotated(deg_to_rad(-90))
			draw_set_transform_matrix(tran)
			draw_texture_rect(箭头,Rect2(tran.affine_inverse() * (pos+Vector2(23,-6)),Vector2(46,33)),false,Color(0, 0, 0, 0.431))
			draw_texture_rect(箭头,Rect2(tran.affine_inverse() * (pos+Vector2(20,-10)),Vector2(40,28)),false,Color(0, 1, 0))
			draw_set_transform(Vector2.ZERO)
		elif data[0] == "旋转控件":
			var pos = data[1]
			var rot = data[2]
			var 旋转 = preload("res://资源/旋转图标.png")
			var tran:Transform2D
			tran = tran.rotated(deg_to_rad(rot))
			var 尺寸 = Vector2(256,256)*0.21
			draw_set_transform_matrix(tran)
			draw_texture_rect(旋转,tran.affine_inverse() * Rect2(pos-尺寸/2,尺寸),false,Color(1, 1, 1))
			draw_set_transform(Vector2.ZERO)
		elif data[0] == "缩放控件":
			var pos = data[1]
			var 缩放 = preload("res://资源/缩放图标.png")
			var tran:Transform2D
			tran = tran.rotated(deg_to_rad(-90))
			draw_set_transform_matrix(tran)
			draw_texture_rect(缩放,Rect2(tran.affine_inverse() * (pos+Vector2(7,15)),Vector2(30,30)),false,Color(1, 0, 0))
			tran = tran.rotated(deg_to_rad(-90))
			draw_set_transform_matrix(tran)
			draw_texture_rect(缩放,Rect2(tran.affine_inverse() * (pos+Vector2(15,-10)),Vector2(30,30)),false,Color(0, 1, 0))
			draw_set_transform(Vector2.ZERO)
		elif data[0] == "骨骼":
			var node:Bone2D = data[1]
			var 颜色 = node.颜色
			var tran = node.get_canvas_transform()
			draw_set_transform_matrix(tran)
			var 骨骼坐标 = node.global_position
			draw_circle(骨骼坐标,3,颜色,false,1,true)
			draw_set_transform_matrix(node.get_global_transform_with_canvas())
			var 终点 = Vector2(node.get_length(),0).rotated(node.get_bone_angle())
			var 半径 = clamp(remap(终点.length(),0,500,2,3),2,3)
			var 起点 = Vector2(半径+3,0).rotated(终点.angle())
			var 右点 = Vector2(半径*2+3,半径).rotated(终点.angle())
			var 左点 = Vector2(半径*2+3,-半径).rotated(终点.angle())
			var pos:PackedVector2Array = [起点,左点,终点,右点,起点]
			if 终点!=Vector2.ZERO:
				draw_colored_polygon(pos,颜色,pos)
				draw_polyline(pos,颜色,3,true)
			draw_set_transform(Vector2.ZERO)

	绘制数据.clear()
