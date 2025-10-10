extends Control

const WIDTH: int = 320
const HEIGHT: int = 240

func _ready() -> void:
	update()

func _process(_delta: float) -> void:
	update()

func update() -> void:
	var s = max(min(get_window().size.x / WIDTH, get_window().size.y / HEIGHT), 1)
	$View.scale = Vector2(s, s)
	$View.position = (get_window().size - Vector2i(WIDTH, HEIGHT) * s) / 2
	$Background.size = get_window().size
