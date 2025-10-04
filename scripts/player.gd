extends CharacterBody2D

enum State {PUMPKIN, GHOST}
enum Direction {LEFT, RIGHT, UP, DOWN}

const MIN_WALK_SPEED: float = 64
const MAX_WALK_SPEED: float = 128
const MAX_RUN_SPEED: float = 256
const ACCELERATION: float = 256
const DECELERATION: float = 512
const GRAVITY: float = 512
const JUMP_ACCELERATION: float = 256
const MIN_JUMP_HEIGHT: float = 48
const MAX_JUMP_HEIGHT: float = 64
const GHOST_SPEED: float = 256
const GHOST_ENERGY: float = 480

@onready var GroundLayer = $"../../Tiles/GroundLayer"
@onready var MistLayer = $"../../Tiles/MistLayer"
@onready var Obstacles = $"../../Obstacles"
@onready var EnergyBar = $"../../UI/EnergyBar"

var state: State = State.PUMPKIN
var direction: Direction = Direction.RIGHT
var is_jumping: bool = false
var jump_from: float = 0
var jump_dx: float = 0
var is_falling: bool = false
var energy: float = 0
var time: float = 0
var checkpoint: Vector2 = Vector2()
var pumpkin_position: Vector2 = Vector2()

func _ready() -> void:
	checkpoint = position
	reset_at_checkpoint()
	MistLayer.modulate.a = 0.5

func _process(delta: float) -> void:
	match state:
		State.PUMPKIN:
			if not $DieTimer.is_stopped():
				$Animation.play("pumpkin_die")
				return

			if not $ExitTimer.is_stopped():
				return

			var is_running = Input.is_action_pressed("run")

			if Input.is_action_pressed("left"):
				if velocity.x == 0:
					velocity.x = -MIN_WALK_SPEED
				elif velocity.x > 0:
					velocity.x -= DECELERATION * delta
				elif is_running and velocity.x > -MAX_RUN_SPEED:
					velocity.x = max(velocity.x - ACCELERATION * delta, -MAX_RUN_SPEED)
				elif velocity.x > -MAX_WALK_SPEED:
					velocity.x = max(velocity.x - ACCELERATION * delta, -MAX_WALK_SPEED)
				elif not is_running and velocity.x < -MAX_WALK_SPEED:
					velocity.x = min(velocity.x + DECELERATION * delta, -MAX_WALK_SPEED)
				$Sprite.flip_h = true
			elif Input.is_action_pressed("right"):
				if velocity.x == 0:
					velocity.x = MIN_WALK_SPEED
				elif velocity.x < 0:
					velocity.x += DECELERATION * delta
				elif is_running and velocity.x < MAX_RUN_SPEED:
					velocity.x = min(velocity.x + ACCELERATION * delta, MAX_RUN_SPEED)
				elif velocity.x < MAX_WALK_SPEED:
					velocity.x = min(velocity.x + ACCELERATION * delta, MAX_WALK_SPEED)
				elif not is_running and velocity.x > MAX_WALK_SPEED:
					velocity.x = max(velocity.x - DECELERATION * delta, MAX_WALK_SPEED)
				$Sprite.flip_h = false
			elif velocity.x < 0:
				velocity.x = min(velocity.x + DECELERATION * delta, 0)
			elif velocity.x > 0:
				velocity.x = max(velocity.x - DECELERATION * delta, 0)

			if Input.is_action_just_pressed("jump"):
				$JumpTimer.start()

			if not $JumpTimer.is_stopped() and not is_jumping and not is_falling:
				is_jumping = true
				jump_from = position.y
				velocity.y = -192
				$JumpTimer.stop()

				if is_running:
					jump_dx = MAX_RUN_SPEED
				else:
					jump_dx = MAX_WALK_SPEED
  
			if is_jumping:
				var diff = jump_from - position.y
				if not Input.is_action_pressed("jump") and diff >= MIN_JUMP_HEIGHT:
					is_jumping = false
					velocity.y = 0
					$HangTimer.start()
				elif diff >= MAX_JUMP_HEIGHT:
					is_jumping = false
					velocity.y = 0
					$HangTimer.start()
				else:
					velocity.y -= JUMP_ACCELERATION * delta

			if $HangTimer.is_stopped():
				velocity.y += GRAVITY * delta

			if not is_on_floor():
				if velocity.x > jump_dx:
					velocity.x = jump_dx
				elif velocity.x < -jump_dx:
					velocity.x = -jump_dx

			move_and_slide()

			if is_on_floor():
				is_jumping = false
				is_falling = false
				time += 4 * delta
				$Sprite.offset.y = cos(time) * 4 - 4
			else:
				time = 0
				$Sprite.offset.y = 0
				if $CoyoteTimer.is_stopped():
					$CoyoteTimer.start()

			if is_on_ceiling():
				velocity.y = 64

			for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				var collider = collision.get_collider()
				if not collider is TileMapLayer:
					if collider.get_collision_layer_value(3) and collision.get_normal() == Vector2(0, -1):
						die()
					elif collider.get_collision_layer_value(5):
						die()
					elif collider.get_collision_layer_value(9):
						set_collision_mask_value(9, false)
						if position.x > collider.position.x:
							position = collider.position + Vector2(16, 8)
						else:
							position = collider.position + Vector2(-16, 8)
						create_tween().tween_property(self, "position:x", collider.position.x, $ExitTimer.wait_time)
						$ExitTimer.start()

			if position.y > $Camera.limit_bottom + 8:
				position.y = $Camera.limit_bottom - 8
				die()

			$Animation.play("pumpkin_idle")
		State.GHOST:
			if not $DieTimer.is_stopped():
				$Animation.play("ghost_die")
				return

			if not $PossessionTimer.is_stopped():
				$Animation.play("ghost_possess")
				return

			if Input.is_action_pressed("left"):
				direction = Direction.LEFT
				$Sprite.flip_h = true
				$Sprite.rotation = 0

			if Input.is_action_pressed("right"):
				direction = Direction.RIGHT
				$Sprite.flip_h = false
				$Sprite.rotation = 0

			if Input.is_action_pressed("up"):
				direction = Direction.UP
				if $Sprite.flip_h:
					$Sprite.rotation = deg_to_rad(90)
				else:
					$Sprite.rotation = deg_to_rad(-90)

			if Input.is_action_pressed("down"):
				direction = Direction.DOWN
				if $Sprite.flip_h:
					$Sprite.rotation = deg_to_rad(-90)
				else:
					$Sprite.rotation = deg_to_rad(90)

			match direction:
				Direction.LEFT:
					velocity = Vector2(-GHOST_SPEED, 0)
				Direction.RIGHT:
					velocity = Vector2(GHOST_SPEED, 0)
				Direction.UP:
					velocity = Vector2(0, -GHOST_SPEED)
				Direction.DOWN:
					velocity = Vector2(0, GHOST_SPEED)

			var last_position = position
			var collision = move_and_collide(velocity * delta)
			if collision:
				var collider = collision.get_collider()
				if collider is TileMapLayer:
					die()
				else:
					if collider.get_collision_layer_value(7):
						collider.possessed = true
						checkpoint = collider.position
						pumpkin_position = collider.position

						match direction:
							Direction.LEFT:
								position = collider.position + Vector2(16, 0)
							Direction.RIGHT:
								position = collider.position + Vector2(-16, 0)
							Direction.UP:
								position = collider.position + Vector2(0, 16)
							Direction.DOWN:
								position = collider.position + Vector2(0, -16)

						velocity = Vector2()
						set_collision_mask_value(7, false)
						$PossessionTimer.start()
					elif collider.get_collision_layer_value(8) and collider.is_unused():
						energy = GHOST_ENERGY
						last_position = position
						collider.use()

			energy -= position.distance_to(last_position)
			EnergyBar.get_node("Top").size.x = ceil(energy / 16)
			EnergyBar.get_node("Bottom").size.x = ceil(energy / 16)
			if energy <= 0:
				velocity = Vector2()
				$DieTimer.start()

			$Animation.play("ghost_move")

func _on_coyote_timer_timeout() -> void:
	is_falling = true

func _on_hang_timer_timeout() -> void:
	is_falling = true

func _on_die_timer_timeout() -> void:
	match state:
		State.PUMPKIN:
			if position.y >= $Camera.limit_bottom - 8:
				reset_at_checkpoint()
			else:
				if $Sprite.flip_h:
					direction = Direction.LEFT
				else:
					direction = Direction.RIGHT

				state = State.GHOST
				energy = GHOST_ENERGY
				$Sprite.offset.y = 0
				set_collision_layer_value(1, false)
				set_collision_layer_value(2, true)
				set_collision_layer_value(10, false)
				set_collision_mask_value(1, false)
				set_collision_mask_value(2, true)
				set_collision_mask_value(3, false)
				set_collision_mask_value(4, true)
				set_collision_mask_value(5, false)
				set_collision_mask_value(7, true)
				set_collision_mask_value(8, true)
				set_collision_mask_value(9, false)
				GroundLayer.modulate.a = 0.5
				MistLayer.modulate.a = 1.0
				EnergyBar.visible = true
				EnergyBar.get_node("Top").size.x = 30
				EnergyBar.get_node("Bottom").size.x = 30
		State.GHOST:
			reset_at_checkpoint()

func _on_possession_timer_timeout() -> void:
	state = State.PUMPKIN
	$Sprite.rotation = 0
	$Sprite.frame = 0
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, false)
	set_collision_layer_value(10, true)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, true)
	set_collision_mask_value(4, false)
	set_collision_mask_value(5, true)
	set_collision_mask_value(7, false)
	set_collision_mask_value(8, false)
	set_collision_mask_value(9, true)
	position = pumpkin_position
	visible = true
	GroundLayer.modulate.a = 1.0
	MistLayer.modulate.a = 0.5
	EnergyBar.visible = false

func _on_exit_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/end.tscn")

func die() -> void:
	if $DieTimer.is_stopped():
		velocity = Vector2()
		$DieTimer.start()

func reset_at_checkpoint() -> void:
	var pumpkin_scene = load("res://scenes/objects/pumpkin.tscn")
	var pumpkin = pumpkin_scene.instantiate()
	pumpkin.position = checkpoint
	pumpkin.possessed = true
	Obstacles.add_child(pumpkin)

	state = State.GHOST
	visible = false
	position = checkpoint
	pumpkin_position = checkpoint
	$PossessionTimer.start()
