extends Node2D

signal timeout(body)

var speed: float = -0.7
var is_score := false
@onready var timer: Timer = $Timer


func _process(delta):
	if not is_score: return
	var v = scale.x + speed * delta
	scale = Vector2(v, v)
	if v <= 0.5 || v >= 1:
		speed = -speed


func extra_score():
	is_score = true
	$Animated.hide()
	timer.start(3)


func crash(color: Color = Color(1, 1, 1, 1)):
	$Label.hide()
	$Animated.self_modulate = color
	$Animated.play()
	timer.start(1)


func _on_timer_timeout():
	timeout.emit(self)
