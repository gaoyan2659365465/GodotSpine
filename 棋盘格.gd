extends Sprite2D


func _ready() -> void:
	show_behind_parent = true
	
	texture = GradientTexture2D.new()
	texture.gradient = Gradient.new()
	texture.width = 1
	texture.height = 1
	
	scale = Vector2(20000,20000)
	
	material = ShaderMaterial.new()
	material.shader = preload("res://资源/棋盘格.gdshader")
	material.set("shader_parameter/size",50)
	material.set("shader_parameter/color1",Color("#525252"))
	material.set("shader_parameter/color2",Color("#59595c"))
