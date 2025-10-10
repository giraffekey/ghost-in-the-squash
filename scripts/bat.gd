extends CharacterBody2D

enum Direction {NONE, LEFT, RIGHT, UP, DOWN}

@onready var PathLayer = $"../../Tiles/PathLayer"

var direction: Direction = Direction.NONE

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	$Animation.play("fly")

	follow_path()
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is CharacterBody2D and collider.get_collision_layer_value(10):
			move_through_player()
			collider.die()

func follow_path() -> void:
	var cell
	match direction:
		Direction.NONE:
			cell = PathLayer.local_to_map(position)
		Direction.LEFT:
			cell = PathLayer.local_to_map(position + Vector2(8, 0))
		Direction.RIGHT:
			cell = PathLayer.local_to_map(position + Vector2(-8, 0))
		Direction.UP:
			cell = PathLayer.local_to_map(position + Vector2(0, 8))
		Direction.DOWN:
			cell = PathLayer.local_to_map(position + Vector2(0, -8))

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
		Direction.NONE:
			velocity = Vector2()
		Direction.LEFT:
			$Sprite.flip_h = true
			velocity = Vector2(-80, 0)
		Direction.RIGHT:
			$Sprite.flip_h = false
			velocity = Vector2(80, 0)
		Direction.UP:
			velocity = Vector2(0, -80)
		Direction.DOWN:
			velocity = Vector2(0, 80)

func move_through_player() -> void:
	set_collision_mask_value(10, false)
	await get_tree().create_timer(0.4).timeout
	set_collision_mask_value(10, true)
