extends StaticBody2D

@export var possessed: bool = false

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if possessed:
		$Animation.play("possessed")
	else:
		$Animation.play("idle")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "possessed":
		queue_free()
