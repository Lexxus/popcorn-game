extends Node2D

const MAX_LIVES = 12

var lives: int = 0


func add_live():
	if lives == MAX_LIVES: return
	lives += 1
	if lives == 1:
		$Live.show()
	else:
		var node := $Live.duplicate() as Sprite2D
		node.position.x += floori((lives - 1) / 4) * 58
		node.position.y += floori((lives - 1) % 4) * 22
		add_child(node)


func remove_live():
	if lives == 0: return
	lives -= 1
	if lives == 0:
		$Live.hide()
	else:
		var node = get_child(lives)
		remove_child(node)
