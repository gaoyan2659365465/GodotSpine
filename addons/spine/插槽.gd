@tool
class_name 插槽 extends Node2D

@export var 切换名:String = "":
	set(value):
		切换名 = value
		var c = get_children()
		for i in c:
			i.visible = false
			if i.name == 切换名:
				i.visible = true
