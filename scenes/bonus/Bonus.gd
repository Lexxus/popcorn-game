extends Area2D

signal catch(body)
signal out(body)

const FALL_SPEED = 100

var type := Lib.Bonus.NONE
var scale_speed = -1
var is_front_side: bool = true
var viewport_height: float
var is_paused := false


func init(bonus_type: Lib.Bonus, pos: Vector2):
	viewport_height = ProjectSettings["display/window/size/viewport_height"]
	var label: Label = $Sprite2D/Label
	type = bonus_type
	match bonus_type:
		Lib.Bonus.EXTEND:
			label.text = 'E'
		Lib.Bonus.INIT:
			label.text = 'I'
			$Sprite2D.self_modulate = Color(1, 1, 0, 1)
		Lib.Bonus.GLUE:
			label.text = 'C'
		Lib.Bonus.SLOW:
			label.text = 'S'
		Lib.Bonus.FIRE:
			label.text = 'L'
		Lib.Bonus.FREEZE:
			label.text = 'M'
			$Sprite2D.self_modulate = Color(0, 1, 1, 1)
		Lib.Bonus.SPLIT:
			label.text = 'T'
			$Sprite2D.self_modulate = Color(0, 0.5, 1, 1)
		Lib.Bonus.WALL:
			label.text = 'F'
			$Sprite2D.self_modulate = Color(0, 0.8, 1, 1)
		Lib.Bonus.LIFE:
			label.text = 'V'
			$Sprite2D.self_modulate = Color(0, 1, 0.4, 1)
	position = pos
	name = "Bonus" + String.num(type)


func pause(value: bool):
	is_paused = value


func _process(delta):
	if is_paused: return
	position.y += FALL_SPEED * delta
	if position.y > viewport_height:
		out.emit(self)
		return
	var scale_y = $Sprite2D.scale.y + (scale_speed * delta)
	if ($Sprite2D.scale.y >= 0 and scale_y <= 0) or ($Sprite2D.scale.y <= 0 and scale_y >= 0):
		is_front_side = not is_front_side
		if is_front_side:
			$Sprite2D/Label.show()
		else:
			$Sprite2D/Label.hide()
	$Sprite2D.scale.y = scale_y
	
	if scale_y <= -1 or scale_y >= 1:
		scale_speed = -scale_speed


func _on_body_entered(_body):
	catch.emit(self)
