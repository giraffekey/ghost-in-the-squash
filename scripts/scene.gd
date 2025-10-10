extends SubViewport

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func change_scene_to_file(path: String):
	remove_child(get_child(0))
	add_child(load(path).instantiate())
