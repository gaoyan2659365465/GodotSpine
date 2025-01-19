extends VBoxContainer


var 详细面板

func _ready() -> void:
	await get_tree().process_frame
	Global.选择管理器.更改选中.connect(_on_更改选中)
	


func 创建详细面板子控件():
	if 详细面板:
		详细面板.queue_free()
	详细面板 = preload("res://详细面板控件/详细面板控件.gd").new()
	add_child(详细面板)
	详细面板.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	

func _on_更改选中():
	if Global.选择管理器.选中列表.size() == 0:
		if 详细面板:
			详细面板.queue_free()
			详细面板 = null
		return
	创建详细面板子控件()
