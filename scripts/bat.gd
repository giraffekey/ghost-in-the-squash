extends CharacterBody2D

enum Direction {LEFT, RIGHT, UP, DOWN}

@onready var PathLayer = $"../../Tiles/PathLayer"

var cell: Vector2i = Vector2i()
var direction: Direction = Direction.LEFT

func _ready() -> void:
	follow_path()

func _process(_delta: float) -> void:
	$Animation.play("fly")

func _on_move_timer_timeout() -> void:
	follow_path()

func follow_path() -> void:
	match PathLayer.get_cell_atlas_coords(cell):
		Vector2i(0, 0):
			pass
		Vector2i(1, 0):
			direction = Direction.LEFT
		Vector2i(2, 0):
			direction = Direction.RIGHT
		Vector2i(0, 1):
			pass
		Vector2i(1, 1):
			direction = Direction.UP
		Vector2i(2, 1):
			direction = Direction.DOWN
		Vector2i(3, 0):
			if direction == Direction.LEFT:
				direction = Direction.DOWN
			elif direction == Direction.UP:
				direction = Direction.RIGHT
		Vector2i(4, 0):
			if direction == Direction.RIGHT:
				direction = Direction.DOWN
			elif direction == Direction.UP:
				direction = Direction.LEFT
		Vector2i(3, 1):
			if direction == Direction.LEFT:
				direction = Direction.UP
			elif direction == Direction.DOWN:
				direction = Direction.RIGHT
		Vector2i(4, 1):
			if direction == Direction.RIGHT:
				direction = Direction.UP
			elif direction == Direction.DOWN:
				direction = Direction.LEFT
		Vector2i(5, 0):
			match direction:
				Direction.LEFT:
					direction = Direction.RIGHT
				Direction.RIGHT:
					direction = Direction.LEFT
				Direction.UP:
					direction = Direction.DOWN
				Direction.DOWN:
					direction = Direction.UP

	match direction:
		Direction.LEFT:
			cell.x -= 1
			$Sprite.flip_h = true
			create_tween().tween_property(self, "position:x", position.x - 16, $MoveTimer.wait_time)
		Direction.RIGHT:
			cell.x += 1
			$Sprite.flip_h = false
			create_tween().tween_property(self, "position:x", position.x + 16, $MoveTimer.wait_time)
		Direction.UP:
			cell.y -= 1
			create_tween().tween_property(self, "position:y", position.y - 16, $MoveTimer.wait_time)
		Direction.DOWN:
			cell.y += 1
			create_tween().tween_property(self, "position:y", position.y + 16, $MoveTimer.wait_time)

	$MoveTimer.start()
