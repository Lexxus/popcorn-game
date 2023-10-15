extends Node2D

signal top
signal bottom

const SPEED = 500
var MIN_Y: int = -(Lib.PLAY_WIDTH_HEIGHT - 20)
var is_active: bool = false
var direction: int = -1
@onready var piston_head = $PistonHead


func start():
	show()
	is_active = true
	var frame: int = piston_head.get_child_count() - 1
	for node in piston_head.get_children():
		node.set_frame(frame)
		node.play()
		frame -= 1


func _process(delta):
	if !is_active: return
	var delta_y = direction * SPEED * delta
	piston_head.position.y += delta_y
	var top_y = piston_head.position.y
	$Piston4.position.y += delta_y * 0.875
	$Piston4.set_region_rect($Piston4.region_rect.grow_side(3, -delta_y * 0.25))
	$PistonHead3.position.y += delta_y * 0.75
	$Piston3.position.y += delta_y * 0.625
	$Piston3.set_region_rect($Piston3.region_rect.grow_side(3, -delta_y * 0.25))
	$PistonHead2.position.y += delta_y * 0.5
	$Piston2.position.y += delta_y * 0.375
	$Piston2.set_region_rect($Piston2.region_rect.grow_side(3, -delta_y * 0.25))
	$PistonHead1.position.y += delta_y * 0.25
	$Piston1.position.y += delta_y * 0.125
	$Piston1.set_region_rect($Piston1.region_rect.grow_side(3, -delta_y * 0.25))
	$Cover.position.y = top_y / 2 + 10
	$Cover.set_region_rect($Cover.region_rect.grow_side(1, -delta_y))
	if top_y <= MIN_Y:
		direction = -direction
		top.emit()
	if top_y >= 0 and direction > 0:
		direction = -direction
		is_active = false
		for node in piston_head.get_children():
			node.stop()
		hide()
		bottom.emit()
