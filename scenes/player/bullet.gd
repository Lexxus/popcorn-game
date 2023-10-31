extends Area2D

signal hit(body)

var speed := 1000
var is_paused := false


func _init():
	Lib.connect(&"message", _on_message)


func start(pos: Vector2):
	position = pos


func _process(delta):
	if not is_paused:
		position.y -= speed * delta


func _on_body_entered(body):
	speed = 0
	if body.has_method("punch"):
		body.call_deferred("punch", self)
	hit.emit(self)


func _on_message(msg: StringName, param):
	if msg == &"pause":
		is_paused = param
