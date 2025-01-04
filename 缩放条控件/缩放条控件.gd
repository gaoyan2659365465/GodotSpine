extends Panel

var 滑块条位置 = 50

# 鼠标是否按下
var is_pressed = false

var 相机

signal 设置缩放(value)


func _ready() -> void:
	size = Vector2(20,95)
	position = Vector2(7,490)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#00000041")
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_left = 5
	style.corner_radius_bottom_right = 5
	set("theme_override_styles/panel",style)

	gui_input.connect(_on_gui_input)
	
	创建按钮()


func 初始化缩放条(target):
	相机 = target
	相机.滚轮缩放.connect(_on_主相机_滚轮缩放)


func 创建按钮():
	var bt1 = Button.new()
	add_child(bt1)
	bt1.size = Vector2(25,25)
	bt1.position = Vector2(-0.65,97.31)
	bt1.icon = preload("res://资源/放大镜.svg")
	bt1.expand_icon = true
	bt1.focus_mode = FOCUS_NONE
	bt1.flat = true
	bt1.set("theme_override_colors/icon_normal_color",Color("#90ebeb"))
	bt1.set("theme_override_colors/icon_pressed_color",Color("#000000"))
	bt1.set("theme_override_colors/icon_hover_color",Color("#ffffff"))
	bt1.pressed.connect(_on_放大镜_pressed)
	
	var bt2 = Button.new()
	add_child(bt2)
	bt2.size = Vector2(25,25)
	bt2.position = Vector2(-0.65,120)
	bt2.icon = preload("res://资源/最大化箭头.svg")
	bt2.expand_icon = true
	bt2.focus_mode = FOCUS_NONE
	bt2.flat = true
	bt2.set("theme_override_colors/icon_normal_color",Color("#90ebeb"))
	bt2.set("theme_override_colors/icon_pressed_color",Color("#000000"))
	bt2.set("theme_override_colors/icon_hover_color",Color("#ffffff"))
	bt2.pressed.connect(_on_最大化_pressed)

func _on_放大镜_pressed():
	相机.相机缩放插值(Vector2(1,1))
	var tween = create_tween()
	tween.tween_property(相机,"position",Vector2(0,0),0.2)
	_on_主相机_滚轮缩放()

func _on_最大化_pressed():
	相机.相机缩放插值(Vector2(2,2))
	var tween = create_tween()
	tween.tween_property(相机,"position",Vector2(0,0),0.2)
	_on_主相机_滚轮缩放()



func _on_主相机_滚轮缩放():
	var z = 相机.zoom.x
	if z <= 1.0:
		z = remap(z,0.1,1.0,74,50)
	else:
		z = remap(z,1.0,20.0,50,22)
	滑块条位置 = z
	queue_redraw()


func _on_gui_input(event):
	if event is InputEventMouseButton:
		self.is_pressed = event.pressed
		if is_pressed:
			滑块条位置 = get_local_mouse_position().y
			滑块条位置 = clamp(滑块条位置,22,74)
			queue_redraw()
			设置缩放.emit(remap(滑块条位置,22,74,1,0))
	if event is InputEventMouseMotion:
		if self.is_pressed:
			滑块条位置 = get_local_mouse_position().y
			滑块条位置 = clamp(滑块条位置,22,74)
			queue_redraw()
			设置缩放.emit(remap(滑块条位置,22,74,1,0))


func _draw() -> void:
	draw_char(ThemeDB.fallback_font,Vector2(5,15),"+",16,Color("#a4d4d4"))
	draw_char(ThemeDB.fallback_font,Vector2(7,90),"-",16,Color("#a4d4d4"))
	
	var points = [Vector2(6,18),Vector2(14,18),Vector2(10,85)]
	var colors = [Color("#2e2e2f"),Color("#2e2e2f"),Color("#2e2e2f")]
	draw_primitive(points,colors,points)
	
	draw_circle(Vector2(10,滑块条位置),4,Color.WHITE,true,-1.0,true)
