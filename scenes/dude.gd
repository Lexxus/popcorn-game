extends Node2D

signal done

const SPEED = 200
const MAX_HEIGHT = 332

var is_move_up := false
var is_move_down := false

@onready var body_1: Sprite2D = $DudeNaked
@onready var body_2: Sprite2D = $DudeFull


func _process(delta):
    if not is_move_up and not is_move_down: return
    var dy = SPEED * delta
    var y = $Line.position.y
    if is_move_up:
        y -= dy
        if y <= 0:
            y = 0
            is_move_up = false
            is_move_down = true
    else:
        y += dy
        if y >= MAX_HEIGHT:
            y = MAX_HEIGHT
            is_move_down = false
            $Line.hide()
            done.emit()
        body_2.region_rect.size.y = y
    $Line.position.y = y
    body_1.offset.y = y
    body_1.region_rect.position.y = y
    body_1.region_rect.size.y = MAX_HEIGHT - y


func start():
    is_move_up = true