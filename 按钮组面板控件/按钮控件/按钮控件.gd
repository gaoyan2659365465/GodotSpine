extends Button

signal 点击按钮(target,toggled_on:bool)


func _ready() -> void:
	初始化()
	toggled.connect(_on_button_toggled)

func 初始化():
	text = "旋转"
	icon = preload("res://icon.svg")
	expand_icon = true
	custom_minimum_size = Vector2(64,23)
	size = Vector2(64,23)
	focus_mode = FOCUS_NONE
	set("theme_override_constants/h_separation",7)
	set("theme_override_constants/icon_max_width",15)
	set("theme_override_constants/align_to_largest_stylebox",1)
	set("theme_override_font_sizes/font_size",12)
	
	var n_style = StyleBoxFlat.new()
	n_style.bg_color = Color("#666666")
	n_style.border_width_top = 1
	n_style.border_color = Color("#7c7c7c")
	n_style.border_blend = true
	n_style.corner_radius_top_left = 4
	n_style.corner_radius_top_right = 4
	n_style.corner_radius_bottom_right = 4
	n_style.corner_radius_bottom_left = 4
	n_style.shadow_color = Color("#0000004b")
	n_style.shadow_size = 1
	set("theme_override_styles/normal",n_style)
	
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color("#2a86bf")
	p_style.border_width_top = 1
	p_style.border_color = Color("#5a5a5a")
	p_style.border_blend = true
	p_style.corner_radius_top_left = 4
	p_style.corner_radius_top_right = 4
	p_style.corner_radius_bottom_right = 4
	p_style.corner_radius_bottom_left = 4
	p_style.shadow_color = Color("#0000004b")
	p_style.shadow_size = 1
	set("theme_override_styles/pressed",p_style)
	
	var h_style = StyleBoxFlat.new()
	h_style.bg_color = Color("#9d9d9d")
	h_style.border_width_top = 1
	h_style.border_color = Color("#7c7c7c")
	h_style.border_blend = true
	h_style.corner_radius_top_left = 4
	h_style.corner_radius_top_right = 4
	h_style.corner_radius_bottom_right = 4
	h_style.corner_radius_bottom_left = 4
	h_style.shadow_color = Color("#0000004b")
	h_style.shadow_size = 1
	set("theme_override_styles/hover",h_style)

func 取消圆角():
	var h_style = get("theme_override_styles/hover")
	h_style.corner_radius_top_right = 0
	h_style.corner_radius_bottom_right = 0
	var p_style = get("theme_override_styles/pressed")
	p_style.corner_radius_top_right = 0
	p_style.corner_radius_bottom_right = 0
	var n_style = get("theme_override_styles/normal")
	n_style.corner_radius_top_right = 0
	n_style.corner_radius_bottom_right = 0
	
	

func 设置文字(value):
	text = value

func 选中(value):
	button_pressed = value

func _on_button_toggled(toggled_on: bool) -> void:
	# 按钮切换
	点击按钮.emit(self,toggled_on)
	
