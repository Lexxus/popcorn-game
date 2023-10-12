extends Node2D

signal wall_ready

const SPEED = 500

var wall_moving: bool = false
@onready var top_group := %TopGroup as CanvasGroup


func _ready():
	toggle_bottom_wall(false)


func _process(delta):
	if wall_moving:
		top_group.position += Vector2.UP * SPEED * delta
		if top_group.position.y <= 0:
			wall_moving = false
			top_group.position.y = 0
			wall_ready.emit()


func hide_wall():
	top_group.position.y = Lib.PLAY_WIDTH_HEIGHT


func show_wall():
	wall_moving = true


func toggle_bottom_wall(enable: bool):
	if enable:
		$Bottom.show()
		$Bottom/Timer.start()
	else:
		$Bottom.hide()
	$Bottom.process_mode = Node.PROCESS_MODE_INHERIT if enable else Node.PROCESS_MODE_DISABLED


func _on_wall_area_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if !wall_moving:
		if body.has_method("correct_speed"):
			$AudioWall.play()
			body.correct_speed()


func _on_bottom_timer_timeout():
	toggle_bottom_wall(false)
