extends Panel




func _draw() -> void:
	var 眼睛 = preload("res://资源/眼睛.svg")
	var 钥匙 = preload("res://资源/钥匙.svg")
	draw_texture_rect(眼睛,Rect2(Vector2(5,5),Vector2(15,15)),false)
	draw_texture_rect(钥匙,Rect2(Vector2(5+23,5),Vector2(15,15)),false)
	
	var default_font = ThemeDB.fallback_font
	draw_string(default_font, Vector2(23*2+4,15), "Hierarchy", HORIZONTAL_ALIGNMENT_CENTER, -1, 13,Color("#c3c3c3"))
	
	draw_line(Vector2(0,23), Vector2(get_rect().size.x,23), Color("#6d6d6d"),-1)
	draw_line(Vector2(23,0), Vector2(23,get_rect().size.y), Color("#6d6d6d"),-1)
	draw_line(Vector2(23*2,0), Vector2(23*2,get_rect().size.y), Color("#6d6d6d"),-1)
	
	
