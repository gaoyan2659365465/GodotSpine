@tool
extends Control

var 标题字 = ""

func _ready() -> void:
	await get_tree().process_frame
	Global.选择管理器.更改选中.connect(_on_更改选中)
	

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

func _draw() -> void:
	var default_font = ThemeDB.fallback_font
	draw_string(default_font, Vector2(2,17), 标题字, HORIZONTAL_ALIGNMENT_CENTER, -1, 13,Color("#8ce6ef"))
