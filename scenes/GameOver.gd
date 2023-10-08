extends Sprite2D

const SPEED: int = 500
const MAX_Y: int = 500
const direction: Vector2 = Vector2.DOWN

var is_active: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_active:
		position += direction * SPEED * delta
		if position.y >= MAX_Y:
			is_active = false

func start():
	is_active = true
