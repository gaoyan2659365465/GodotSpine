extends Node

"""
图片的选中状态、悬浮状态
点选择，线选择
"""


var 当前选中
var 选中列表 = []
var 预选中

signal 更改选中
signal 更改预选中

func 选中目标(target):
	当前选中 = target

func 预选中目标(target):
	if target == 当前选中 && target != null:
		return
	预选中 = target
	更改预选中.emit()# 其他UI控件使用此信号

func 设置选中列表(target):
	选中列表 = target
	更改选中.emit()# 其他UI控件使用此信号


func _process(delta: float) -> void:
	
	for 选中 in 选中列表:
		if 选中 is Sprite2D:
			var tran = 选中.get_global_transform_with_canvas()
			tran = tran.rotated(-1*tran.get_rotation())# 旋转不能直接乘rect，需要绘制时候对画布旋转
			var rect = 选中.get_rect()
			Global.绘制控件.绘制矩形实线框(tran * rect,选中)
			if Global.变换模式 == "旋转":
				Global.绘制控件.绘制旋转控件(选中.get_canvas_transform()*选中.global_position, 选中.rotation_degrees)
			elif Global.变换模式 == "移动":
				Global.绘制控件.绘制移动控件(选中.get_canvas_transform()*选中.global_position)
			elif Global.变换模式 == "缩放":
				Global.绘制控件.绘制缩放控件(选中.get_canvas_transform()*选中.global_position)
			elif Global.变换模式 == "倾斜":
				pass
		if 选中 is Bone2D:
			if Global.变换模式 == "旋转":
				Global.绘制控件.绘制旋转控件(选中.get_canvas_transform()*选中.global_position, 选中.rotation_degrees)
			elif Global.变换模式 == "移动":
				Global.绘制控件.绘制移动控件(选中.get_canvas_transform()*选中.global_position)
			elif Global.变换模式 == "缩放":
				Global.绘制控件.绘制缩放控件(选中.get_canvas_transform()*选中.global_position)
			elif Global.变换模式 == "倾斜":
				pass
	if 预选中:
		if 预选中 is Sprite2D:
			var tran = 预选中.get_global_transform_with_canvas()
			tran = tran.rotated(-1*tran.get_rotation())# 旋转不能直接乘rect，需要绘制时候对画布旋转
			var rect = 预选中.get_rect()
			if 预选中.visible == true:# BUG 仅显示的节点能显示虚线框
				Global.绘制控件.绘制矩形虚线框(tran * rect,预选中)
		# 当选中骨骼时的逻辑
		if 预选中 is Bone2D:
			pass
