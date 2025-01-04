extends LineEdit



func _ready() -> void:
	初始化()

func 初始化():
	alignment = HORIZONTAL_ALIGNMENT_RIGHT
	custom_minimum_size = Vector2(120,23)
	size = Vector2(120,23)
	set("theme_override_font_sizes/font_size",10)
	
	var n_style = StyleBoxFlat.new()
	n_style.bg_color = Color("#585858")
	n_style.border_width_right = 5
	n_style.border_color = Color("#585858")
	set("theme_override_styles/normal",n_style)
	
	var f_style = StyleBoxFlat.new()
	f_style.bg_color = Color("#585858")
	f_style.border_width_left = 1
	f_style.border_width_top = 1
	f_style.border_width_right = 1
	f_style.border_width_bottom = 1
	f_style.border_color = Color("#1400ff")
	set("theme_override_styles/focus",f_style)

	
