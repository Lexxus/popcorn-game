extends Area2D

signal hit(body)

var speed := 1000


func start(pos: Vector2):
	position = pos


func _process(delta):
	position.y -= speed * delta

func _on_body_entered(body):
	speed = 0
	if body.has_method("punch"):
		body.call_deferred("punch", self)
	hit.emit(self)
