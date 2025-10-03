extends StaticBody2D

var used: bool = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _on_use_timer_timeout() -> void:
	used = false
	$Sprite.frame = 0
	set_collision_layer_value(8, true)

func is_unused() -> bool:
	return not used

func use() -> void:
	used = true
	$Sprite.frame = 1
	$UseTimer.start()
	set_collision_layer_value(8, false)
