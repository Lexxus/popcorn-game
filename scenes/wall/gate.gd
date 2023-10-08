extends AnimatedSprite2D

signal finish(body)

func open():
	play_backwards("open")


func close():
	play("open")


func grow():
	play("grow")


func open_enemy():
	play("open_enemy")


func close_enemy():
	play_backwards("open_enemy")


func _on_animation_finished():
	finish.emit(self)
