extends Node


var 绘制控件
var 选择管理器
var 根节点#里面存放骨架和网格
var 主相机


signal 设置轴模式(value)
var 轴模式:
	set(v):
		轴模式 = v
		设置轴模式.emit(v)

signal 设置变换模式(value)
var 变换模式:
	set(v):
		变换模式 = v
		设置变换模式.emit(v)

signal 设置工具模式(value)
var 工具模式:
	set(v):
		工具模式 = v
		设置工具模式.emit(v)

signal 添加节点(node)

signal 重命名节点(node)
