extends CharacterBody2D

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	$Animation.play("fly")
