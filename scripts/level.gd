extends Node2D

func _ready() -> void:
	$Tiles/PathLayer.visible = false
	for cell in $Tiles/ObjectLayer.get_used_cells():
		match $Tiles/ObjectLayer.get_cell_atlas_coords(cell):
			Vector2i(0, 0):
				var player = load("res://scenes/objects/player.tscn").instantiate()
				player.position = cell as Vector2 * 16 + Vector2(8, 8)
				$Players.add_child(player)
				$Players/Camera.reparent(player)
				$Players/Player/Camera.position = Vector2()
			Vector2i(1, 0):
				var pumpkin = load("res://scenes/objects/pumpkin.tscn").instantiate()
				pumpkin.position = cell as Vector2 * 16 + Vector2(8, 8)
				$Obstacles.add_child(pumpkin)
			Vector2i(2, 0):
				var crystal = load("res://scenes/objects/crystal.tscn").instantiate()
				crystal.position = cell as Vector2 * 16 + Vector2(8, 8)
				$Obstacles.add_child(crystal)
			Vector2i(0, 1):
				var spike = load("res://scenes/objects/spike.tscn").instantiate()
				spike.position = cell as Vector2 * 16 + Vector2(8, 8)
				$Obstacles.add_child(spike)
			Vector2i(1, 1):
				var bat = load("res://scenes/objects/bat.tscn").instantiate()
				bat.position = cell as Vector2 * 16 + Vector2(8, 8)
				bat.cell = cell
				$Obstacles.add_child(bat)
	$Tiles/ObjectLayer.queue_free()
