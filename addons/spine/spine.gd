@tool
extends EditorPlugin

var node_2d: Node2D

var 图片路径 = ""
var json路径 = ""

var popup_menu = null

func _enter_tree():
	var fs_dock: = get_editor_interface().get_file_system_dock()

	var popup_menus = []
	for n in fs_dock.get_children():
		if n is PopupMenu:
			popup_menus.push_back(n)
	
	self.popup_menu = popup_menus[-1]
	self.popup_menu.connect("menu_changed", Callable(self, "on_context_menu_changed"))
	self.popup_menu.connect("id_pressed", Callable(self, "on_context_menu_id_pressed"))


func on_context_menu_changed():
	if self.popup_menu.item_count == 0:
		return
	var name = self.popup_menu.get_item_text(self.popup_menu.item_count - 1)
	#print(name)
	var cur_path:String = get_editor_interface().get_current_path()
	if not cur_path: return
	
	var ext = cur_path.get_extension()
	if name == "打开":
		if ext == "json":
			self.popup_menu.add_separator()
			self.popup_menu.add_item("Spine转换")


func on_context_menu_id_pressed(id:int):
	var cur_path:String = get_editor_interface().get_current_path()
	var ext = cur_path.get_extension()
	if ext != "json":
		return
	if id != 2:
		return
	
	json路径 = cur_path
	
	var viewport = EditorInterface.get_editor_main_screen() 
	var 选择路径Dialog = EditorFileDialog.new()
	viewport.add_child(选择路径Dialog)
	选择路径Dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	选择路径Dialog.popup(Rect2i(200, 200, 1000, 500))
	选择路径Dialog.connect("dir_selected", on_选择路径_dir_selected)
	选择路径Dialog.set_title("选择图片目录")
	
	
	

func _exit_tree():
	# Clean-up of the plugin goes here.
	pass


func on_选择路径_dir_selected(path: String):
	图片路径 = path + "/"
	print(path)
	
	node_2d = Node2D.new()
	node_2d.name = "Node2D"

	var json = load(json路径)
	var g = 生成骨骼(json)
	var c = 生成插槽(json,g[0],g[1])
	创建动画(json,g[0],g[1],c)
	
	var viewport = EditorInterface.get_editor_main_screen() 
	var fileDialog = EditorFileDialog.new()
	viewport.add_child(fileDialog)
	fileDialog.popup(Rect2i(200, 200, 1000, 500))
	fileDialog.connect("file_selected", on_file_selected)

func on_file_selected(path: String):
	var scene = PackedScene.new()
	scene.pack(node_2d)
	var 导出名 = path.get_file().get_basename()
	var 目录 = path.get_base_dir()
	ResourceSaver.save(scene,目录+"/"+导出名+".tscn")



"""
注意事项：
spine项目图片不要存在子文件夹，找不到路径，直接全堆在一起(已解决)
同名骨骼处理（已解决）
插槽的位置（已解决）
保证生成图片的变换正确（已解决）
只显示插槽中一个（已解决）
区分外部点和内部点（已解决）
优化：骨骼信息为0的不加入数据，减少尺寸（已解决）
优化：解决网格在骨骼中不参与变换的问题，调整Z顺序（已解决）
欧拉角逆向旋转BUG，修改线性插值模式（已解决）
插槽的叠加模式，需要图片或网格的材质来做，不方便实现（已解决）
图像不受插槽颜色改变（已解决）
皮肤导入（已解决）
不继承旋转的骨骼导致网格畸形（已解决）
缺少顶点动画的导入（已解决）
缺少显示顺序帧
缺少曲线
缺少倾斜，godot的倾斜只有左右没有上下
缺少遮罩
"""
func sort_ascending(a, b):
	var _a = 0
	var _b = 0
	if a.has("order"):
		_a = a["order"]
	if b.has("order"):
		_b = b["order"]
	if _a < _b:
		return true
	return false

func 生成骨骼(json):
	var k = Skeleton2D.new()
	k.name = "Skeleton2D"
	node_2d.add_child(k)
	k.owner = node_2d
	
	var s:Dictionary = {}
	for i in json.data["bones"]:
		var b = Bone2D.new()
		b.set_autocalculate_length_and_angle(false)
		b.rest = Transform2D(Vector2(1.0, 0.0), Vector2(0.0, 1.0), Vector2(0, 0))
		s[i['name']] = b
		b.name = i['name']
		
		if i.has('parent'):
			s[i['parent']].add_child(b)
		else:
			k.add_child(b)#说明是root骨骼
		
		if i.has('length'):
			b.set_length(i['length'])
		
		if i.has("rotation"):
			b.rotation_degrees = i['rotation']*-1# 此处未处理不继承旋转的骨骼
		
		if i.has('transform'):
			if i['transform'] == "noRotationOrReflection":
				if i.has("rotation"):
					b.global_rotation_degrees = i['rotation']*-1# 此处处理不继承旋转的骨骼
			
		
		var pos = Vector2.ZERO
		if i.has("x"):
			pos.x = i['x']
		if i.has("y"):
			pos.y = i['y']*-1
		b.position = pos
		b.rest = Transform2D(b.rotation, Vector2(b.position.x, b.position.y))
		
		var sca = Vector2.ONE
		if i.has("scaleX"):
			sca.x = i['scaleX']
		if i.has("scaleY"):
			sca.y = i['scaleY']
		b.scale = sca
		b.owner = node_2d
	
	# 生成IK
	if json.data.has("ik"):
		if json.data["ik"].size() > 0:
			var msk = SkeletonModificationStack2D.new()
			msk.enabled = true
			k.set_modification_stack(msk)
			var ik列表 = json.data["ik"]
			ik列表.sort_custom(sort_ascending)
			for i in ik列表:
				if i.has('bones'):
					var IK骨骼 = i['bones']
					if IK骨骼.size() == 1:
						var lookat = SkeletonModification2DLookAt.new()
						lookat.bone2d_node = k.get_path_to(s[IK骨骼[0]])
						if i.has('target'):
							var IK目标 = i['target']
							lookat.target_nodepath = k.get_path_to(s[IK目标])
						msk.add_modification(lookat)
					elif IK骨骼.size() == 2:
						# 只导入两根骨骼的ik
						var towik = SkeletonModification2DTwoBoneIK.new()
						
						towik.set_joint_one_bone2d_node(k.get_path_to(s[IK骨骼[0]]))
						towik.set_joint_two_bone2d_node(k.get_path_to(s[IK骨骼[1]]))
						var IK名 = i['name']# 没啥用
						if i.has('target'):
							var IK目标 = i['target']
							towik.target_nodepath = k.get_path_to(s[IK目标])
						if i.has('bendPositive'):
							var IK正反 = i['bendPositive']
							towik.flip_bend_direction = IK正反
						else:
							towik.flip_bend_direction = true
						msk.add_modification(towik)
			
	
	return [s,k]

func parse_weights(data: Array) -> Array:
	var result = []
	var i = 0

	while i < data.size():
		var num_bones = data[i]  # 当前点参与的骨骼数量
		var bones_and_weights = []
		i += 1  # 移动到骨骼号

		# 遍历每个骨骼号和对应的权重
		for _i in range(num_bones):
			var bone_id = data[i]
			var x = data[i + 1]
			var y = data[i + 2]
			var weight = data[i + 3]
			bones_and_weights.append({"bone_id": bone_id,"x": x,"y": y, "weight": weight})
			i += 4  # 每个骨骼号和权重占用4个位置

		# 将解析后的骨骼和权重加入结果
		result.append(bones_and_weights)
	return result

func 生成插槽(json,s,k):
	var c:Dictionary = {}
	var z = 0
	for i in json.data["slots"]:
		var _c = 插槽.new()#用于切换子项
		_c.name = i["name"]
		var p = i["bone"]# 父级
		s[p].add_child(_c)
		_c.owner = node_2d
		_c.z_index = z
		_c.z_as_relative = false#由于层级不同，所以采用全局z顺序
		z+=1# 显示顺序，最大4096
		c[i['name']] = _c
		if i.has("color"):
			_c.modulate = Color(i["color"])
	
	# 判断有没有皮肤
	var 皮肤 = [0]
	if json.data["skins"].size() > 1:
		皮肤 = [0,1]
	
	for _p in 皮肤:
		var attachments = json.data["skins"][_p]["attachments"]
		for i in attachments:# 拿到插槽名字
			var _c = c[i]# 获取刚生成的插槽节点
			for i2 in attachments[i]:# 拿到网格或图片名字
				var a = attachments[i][i2]
				var _item# 网格或图片引用
				
				if a.has("type"):# 如果有类型说明是网格
					if a["type"] == "mesh":
						# 加载图片
						var 图片名 = i2
						if a.has('name'):
							图片名 = a['name']
						if a.has("path"):# 有路径说明改名字了
							图片名 = a["path"]
						var _poly = Polygon2D.new()
						_item = _poly
						_poly.texture = load(图片路径+ 图片名 +".png")
						_poly.name = i2
						_c.add_child(_poly)
						_poly.owner = node_2d
						#_poly.z_index = _c.z_index# 控制显示顺序
						
						
						var uvs:PackedVector2Array = []
						var _uvs = a["uvs"]
						var _uvw = a["width"]
						var _uvh = a["height"]
						for _i in range(0, _uvs.size(), 2):
							uvs.append(Vector2(_uvs[_i]*_uvw,_uvs[_i+1]*_uvh))
						_poly.uv = uvs
						
						# 获取插槽的父骨骼
						var 插槽骨名 = ""
						for _i in json.data["slots"]:
							if i == _i["name"]:
								插槽骨名 = _i["bone"]
						var points:PackedVector2Array = []
						var _ver = a["vertices"]
						# 如果UV数据比顶点数据多，说明有权重信息
						if _uvs.size() < _ver.size():
							var _weights = parse_weights(_ver)
							for _i in _weights:
								var 骨骼号 = _i[0]["bone_id"]
								var 骨骼数据 = json.data["bones"][骨骼号]
								var 最终坐标 = Vector2(_i[0]["x"],_i[0]["y"])
								while true:
									var 旋转值 = 0
									if 骨骼数据.has("rotation"):
										旋转值 = 骨骼数据['rotation']#计算顶点不需要*-1
									if 骨骼数据.has("transform"):# 如果骨骼不继承父骨骼的旋转，通常是IK的脚
										if 骨骼数据["transform"] == "noRotationOrReflection":
											旋转值 = s[插槽骨名].rotation_degrees*-1# 获取已经生成骨骼的旋转并还原-1
											print("遇到一个不继承旋转的骨骼")
									var pos = Vector2.ZERO
									if 骨骼数据.has("x"):
										pos.x = 骨骼数据['x']
									if 骨骼数据.has("y"):
										pos.y = 骨骼数据['y']#计算顶点不需要*-1
									var sca = Vector2.ONE
									if 骨骼数据.has("scaleX"):
										sca.x = 骨骼数据['scaleX']
									if 骨骼数据.has("scaleY"):
										sca.y = 骨骼数据['scaleY']
									# 先旋转后加
									if 骨骼数据["name"] != 插槽骨名:
										最终坐标 = (最终坐标*sca).rotated(deg_to_rad(旋转值))+pos
									else:
										break
									if 骨骼数据.has("parent"):
										var 父骨名 = 骨骼数据["parent"]
										for _b in json.data["bones"]:
											if _b["name"] == 父骨名:
												骨骼数据 = _b
												break
									else:
										break
								最终坐标.y *= -1
								points.append(最终坐标)
						else:
							for _i in range(0, _ver.size(), 2):
								points.append(Vector2(_ver[_i],_ver[_i+1]*-1))# 网格点Y需要*-1
						_poly.polygon = points
						_poly.internal_vertex_count = _uvs.size()/2-a["hull"]
						
						var trianles = []
						var _triangles = a["triangles"]
						for _i in range(0, _triangles.size(), 3):
							var _t = []
							_t.push_back(_triangles[_i])
							_t.push_back(_triangles[_i+1])
							_t.push_back(_triangles[_i+2])
							trianles.push_back(_t)
						_poly.polygons = trianles
						
						# 生成权重数据
						# 如果UV数据比顶点数据多，说明有权重信息
						if _uvs.size() < _ver.size():
							_c.owner = null
							_c.reparent(node_2d)# 带权重的网格需要放置到外面
							_c.owner = node_2d# 防止警告
							_poly.owner = node_2d# 重新赋予
							_poly.skeleton = _poly.get_path_to(k)# 没有权重不需要骨架

							var _weights = parse_weights(_ver)
						
							var new_bones = []
							var _sn = 0
							# 遍历所有骨骼
							for _i in s:
								var new_qz:PackedFloat32Array = []
								for _a in range(_poly.polygon.size()):# _a是遍历的当前点号
									var 权重 = 0.0
									# 找到所有当前骨骼当前点的权重
									for ii in _weights[_a]:
										if ii['bone_id'] == _sn:
											权重 = ii['weight']
									new_qz.append(权重)
								# 判断权重是否部为0，删去
								var _isq = false
								for _q in new_qz:
									if _q != 0:
										_isq = true
								if _isq:
									new_bones.append(k.get_path_to(s[_i]))
									new_bones.append(new_qz)
								_sn += 1
							_poly.bones = new_bones
							# 有权重网格才需要这样
							var _gp = _poly.global_position
							var _gr = _poly.global_rotation
							#_poly.top_level = true# 网格本身不能受到骨骼影响，只会受到权重影响
							_poly.global_position = _gp
							_poly.global_rotation = _gr
						
						# 隐藏插槽只能显示一个东西
						_poly.visible = false
						for _i in json.data["slots"]:
							if _i.has("attachment"):
								if _i["attachment"] == i2:
									_poly.visible = true
						
				else:# 如果没有类型说明就是图片
					# 加载图片
					var 图片名 = i2
					if a.has('name'):
						图片名 = a['name']
					if a.has("path"):# 有路径说明改名字了
						图片名 = a["path"]
					var _sprite = Sprite2D.new()
					_item = _sprite
					_sprite.texture = load(图片路径 + 图片名 + ".png")
					_sprite.name = i2
					_c.add_child(_sprite)
					_sprite.owner = node_2d
					
					if a.has("rotation"):
						_sprite.rotation_degrees = a['rotation']*-1
					
					var pos = Vector2.ZERO
					if a.has("x"):
						pos.x = a['x']
					if a.has("y"):
						pos.y = a['y']*-1
					_sprite.position = pos
					
					var sca = Vector2.ONE
					if a.has("scaleX"):
						sca.x = a['scaleX']
					if a.has("scaleY"):
						sca.y = a['scaleY']
					_sprite.scale = sca
					
					# 隐藏插槽只能显示一个东西
					_sprite.visible = false
					
					for _i in json.data["slots"]:
						if _i.has("attachment"):
							if _i["attachment"] == i2:
								_sprite.visible = true
				
				# 给add模式的网格或图片加上材质
				if _item:
					for _i in json.data["slots"]:
						# 找到与图片对应的插槽，查看渲染混合模式是否为add
						if _i.has("blend"):
							var _add = false
							if _i.has("attachment"):
								if _i["attachment"] == i2:
									_add = true
							if _i['name'] == _item.get_parent().name:# 图片的话插槽信息没有，所以只能判断父层级名字
								_add = true
							if _add:
								if _i["blend"] == "additive":
									var mat = CanvasItemMaterial.new()
									mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
									_item.material = mat
	return c

func 创建动画(json,s,k,c):
	var animplay = AnimationPlayer.new()
	node_2d.add_child(animplay)
	animplay.owner = node_2d
	animplay.name = "AnimationPlayer"
	
	var al = AnimationLibrary.new()
	var lg_anim = json.data['animations']
	for i in lg_anim:
		var animation = Animation.new()
		var 动画名 = i
		var 预估时长 = 0
		if lg_anim[i].has("slots"):
			var 插槽动画数据 = lg_anim[i]["slots"]
			for 插槽名 in 插槽动画数据:
				if 插槽动画数据[插槽名].has("color"):
					var 颜色帧 = 插槽动画数据[插槽名]["color"]
					var 插槽径 =  str(node_2d.get_path_to(c[插槽名])) + ":modulate"
					var track_index = animation.add_track(Animation.TYPE_VALUE)# 添加轨道
					animation.track_set_path(track_index, 插槽径)
					for _y in 颜色帧:
						var 延迟 = 0
						var 颜色值 = ""
						if _y.has("time"):
							延迟 = _y["time"]
							if 预估时长<延迟:
								预估时长 = 延迟
						if _y.has("color"):
							颜色值 = str(_y["color"])
						animation.track_insert_key(track_index,延迟, Color(颜色值))
				
				if 插槽动画数据[插槽名].has("attachment"):
					var 切换帧 = 插槽动画数据[插槽名]["attachment"]
					
					var 插槽径 =  str(node_2d.get_path_to(c[插槽名])) + ":切换名"
					var track_index = animation.add_track(Animation.TYPE_VALUE)# 添加轨道
					animation.track_set_path(track_index, 插槽径)
					# 离散更新模式，保证只切换帧一次，而不是很多次
					animation.value_track_set_update_mode(track_index,Animation.UPDATE_DISCRETE)
					animation.track_set_interpolation_type(track_index,Animation.INTERPOLATION_NEAREST)
					
					
					for _q in 切换帧:
						var 延迟 = 0
						var 切换值 = ""
						if _q.has("time"):
							延迟 = _q["time"]
							if 预估时长<延迟:
								预估时长 = 延迟
						if _q.has("name"):
							切换值 = str(_q["name"])
						animation.track_insert_key(track_index,延迟, 切换值)
		
		# 导入顶点动画轨道
		if lg_anim[i].has("deform"):
			var 顶点动画数据 = lg_anim[i]["deform"]["default"]
			for 插槽名 in 顶点动画数据:
				for 网格名 in 顶点动画数据[插槽名]:
					var 顶点帧 = 顶点动画数据[插槽名][网格名]
					var _poly = c[插槽名].find_child(网格名)
					var 顶点径 =  str(node_2d.get_path_to(_poly)) + ":polygon"
					var track_index = animation.add_track(Animation.TYPE_VALUE)# 添加轨道
					animation.track_set_path(track_index, 顶点径)
					for _vd in 顶点帧:
						var 延迟 = 0
						var _offset = 0
						var _vertices = _poly.polygon
						if _vd.has('time'):
							延迟 = _vd['time']
							if 预估时长<延迟:
								预估时长 = 延迟
						if _vd.has('offset'):
							_offset = _vd['offset']
						if _vd.has('vertices') and _poly.bones.size() == 0:# 说明这个网格无权重
							var _vds = _vd['vertices']# 拷贝顶点数组
							for _o in range(_offset):
								_vds.push_front(0)# 补全数组，spine的顶点数组不全
							if _vds.size()%2 == 1:# 如果是奇数，在末尾补0
								_vds.push_back(0)
							var _vn = 0
							for _i in range(0, _vds.size(), 2):# 把数组变成vector2数组
								_vertices[_vn] += Vector2(_vds[_i],_vds[_i+1]*-1)# 此时是vector相加
								_vn += 1
						if _vd.has('vertices') and _poly.bones.size() > 0:# 说明这个网格有权重
							var _vds = _vd['vertices']# 拷贝顶点数组
							if int(_offset)%2==1:# 如果是奇数前面加0
								_vds.push_front(0)
								_offset-=1# 说明缺少第一个点的x轴
							if _vds.size()%2==1:# 说明最后一个点缺少y轴
								_vds.push_back(0)
							# 获取该顶点受到几根骨骼影响
							# 这里忽略皮肤
							var 权重网格 = json.data['skins'][0]['attachments'][插槽名][网格名]["vertices"]
							var _weights = parse_weights(权重网格)
							"""
							print("---------------------------")
							print("点数："+str(_weights.size()))
							print("动画名:"+str(动画名))
							print("插槽名:"+str(插槽名))
							print("网格名:"+str(网格名))
							print("poly顶点数组数量："+str(_vertices.size()))
							print("顶点动画数组数量："+str(_vds.size()))
							print("权重网格数量:"+str(_weights.size()))
							"""
							var 点数组 = []# 构造空点数组
							var _wn = 0
							for _w in _weights:
								#print("_wn:"+str(_wn*2)+"   _offset:"+str(_offset))
								if _offset <= _wn*2 and (_wn*2-_offset)+1 < _vds.size():
									#print("---------------:"+str(_wn*2-_offset))
									var 最终坐标 = Vector2(_vds[(_wn*2-_offset)], _vds[(_wn*2-_offset)+1])
									最终坐标.y *= -1
									点数组.append(最终坐标)
								else:
									点数组.append(Vector2(0,0))
								_wn += _w.size()
							# 根据offset将动画数据加入到空点数组中
							
							#print(点数组)
							#print("点数组数量："+str(点数组.size()))
							var _vn = 0
							for _i in 点数组:
								_vertices[_vn] += _i# 受到骨骼权重影响
								_vn += 1
						animation.track_insert_key(track_index,延迟, _vertices)
		
		if lg_anim[i].has("bones"):
			var 骨骼动画数据 = lg_anim[i]["bones"]
			for 骨名 in 骨骼动画数据:
				if 骨骼动画数据[骨名].has("translate"):
					# 获取当前骨骼的原始变换
					var 原始变换 = s[骨名].position
					var 变换帧 = 骨骼动画数据[骨名]["translate"]
					var 骨路径 =  str(node_2d.get_path_to(s[骨名])) + ":position"
					var track_index = animation.add_track(Animation.TYPE_VALUE)# 添加轨道
					animation.track_set_path(track_index, 骨路径)
					for _t in 变换帧:
						var 延迟 = 0
						if _t.has("time"):
							延迟 = _t["time"]
							if 预估时长<延迟:
								预估时长 = 延迟
						var 变换值 = Vector2.ZERO
						if _t.has("x"):
							变换值.x = 原始变换.x + _t["x"]
						else:
							变换值.x = 原始变换.x
						if _t.has("y"):
							变换值.y = 原始变换.y + _t["y"]*-1
						else:
							变换值.y = 原始变换.y
						animation.track_insert_key(track_index,延迟, 变换值)
					
				if 骨骼动画数据[骨名].has("rotate"):
					# 获取当前骨骼的旋转值，单位度数
					var 原始旋转值 = s[骨名].rotation_degrees
					var 旋转帧 = 骨骼动画数据[骨名]["rotate"]
					var 骨路径 =  str(node_2d.get_path_to(s[骨名])) + ":rotation"
					var track_index = animation.add_track(Animation.TYPE_VALUE)# 添加轨道
					# 解决欧拉角 的旋转插值方式造成的逆向旋转BUG
					animation.track_set_interpolation_type(track_index,Animation.INTERPOLATION_LINEAR_ANGLE)
					animation.track_set_path(track_index, 骨路径)
					for _r in 旋转帧:
						var 延迟 = 0
						if _r.has("time"):
							延迟 = _r["time"]
							if 预估时长<延迟:
								预估时长 = 延迟
						var 旋转值 = 0
						if _r.has("angle"):
							旋转值 = 原始旋转值 + _r["angle"]*-1
						else:
							旋转值 = 原始旋转值
						animation.track_insert_key(track_index,延迟, deg_to_rad(旋转值))
				
				if 骨骼动画数据[骨名].has("scale"):
					# 获取当前骨骼的原始缩放
					var 原始缩放 = s[骨名].scale
					var 缩放帧 = 骨骼动画数据[骨名]["scale"]
					var 骨路径 =  str(node_2d.get_path_to(s[骨名])) + ":scale"
					var track_index = animation.add_track(Animation.TYPE_VALUE)# 添加轨道
					animation.track_set_path(track_index, 骨路径)
					for _s in 缩放帧:
						var 延迟 = 0
						if _s.has("time"):
							延迟 = _s["time"]
							if 预估时长<延迟:
								预估时长 = 延迟
						var 缩放值 = Vector2.ONE
						if _s.has("x"):
							缩放值.x = _s["x"]
						else:
							缩放值.x = 原始缩放.x
						if _s.has("y"):
							缩放值.y = _s["y"]
						else:
							缩放值.y = 原始缩放.y
						animation.track_insert_key(track_index,延迟, 缩放值)
		
		animation.set_length(预估时长)
		
		# 检测动画名是否合法，不能包括“[]”
		动画名 = 动画名.replace("[","_")
		动画名 = 动画名.replace("]","_")
		动画名 = 动画名.replace("/","_")
		al.add_animation(动画名,animation)
		
	var anim_library_name = "animations"
	animplay.add_animation_library(anim_library_name,al)
	
	#region 创建默认初始化姿势
	# 创建默认初始化姿势
	var 全局库 = AnimationLibrary.new()
	animplay.add_animation_library("",全局库)
	var global_library = animplay.get_animation_library("")
	var RESET_anim = Animation.new()
	RESET_anim.set_length(0.001)
	global_library.add_animation("RESET", RESET_anim)
	# 初始化所有插槽
	for i in c:
		var 插槽径 =  str(node_2d.get_path_to(c[i])) + ":切换名"
		var track_index = RESET_anim.add_track(Animation.TYPE_VALUE)# 添加轨道
		RESET_anim.track_set_path(track_index, 插槽径)
		# 离散更新模式，保证只切换帧一次，而不是很多次
		RESET_anim.value_track_set_update_mode(track_index,Animation.UPDATE_DISCRETE)
		RESET_anim.track_set_interpolation_type(track_index,Animation.INTERPOLATION_NEAREST)
		var 子项 = c[i].get_children()
		var 切换名 = ""
		for _i in 子项:
			if _i.visible:
				切换名 = _i.name
		RESET_anim.track_insert_key(track_index,0.0, 切换名)
		
		var 插槽颜色径 =  str(node_2d.get_path_to(c[i])) + ":modulate"
		var track_index2 = RESET_anim.add_track(Animation.TYPE_VALUE)# 添加轨道
		RESET_anim.track_set_path(track_index2, 插槽颜色径)
		RESET_anim.track_insert_key(track_index2,0.0, c[i].modulate)
		
	# 初始化所有骨骼
	for i in s:
		var 骨骼位置径 =  str(node_2d.get_path_to(s[i])) + ":position"
		var track_index = RESET_anim.add_track(Animation.TYPE_VALUE)# 添加轨道
		RESET_anim.track_set_path(track_index, 骨骼位置径)
		RESET_anim.track_insert_key(track_index,0.0, s[i].position)
		
		var 骨骼旋转径 =  str(node_2d.get_path_to(s[i])) + ":rotation"
		var track_index2 = RESET_anim.add_track(Animation.TYPE_VALUE)# 添加轨道
		RESET_anim.track_set_path(track_index2, 骨骼旋转径)
		RESET_anim.track_insert_key(track_index2,0.0, s[i].rotation)
		RESET_anim.value_track_set_update_mode(track_index2,Animation.UPDATE_DISCRETE)
		# 必须要跟上面所有动画的插值类型一样才不会警告
		RESET_anim.track_set_interpolation_type(track_index2,Animation.INTERPOLATION_LINEAR_ANGLE)
		
		var 骨骼缩放径 =  str(node_2d.get_path_to(s[i])) + ":scale"
		var track_index3 = RESET_anim.add_track(Animation.TYPE_VALUE)# 添加轨道
		RESET_anim.track_set_path(track_index3, 骨骼缩放径)
		RESET_anim.track_insert_key(track_index3,0.0, s[i].scale)
	#endregion
		
