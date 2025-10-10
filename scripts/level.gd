extends Node2D

func _ready() -> void:
	$Tiles/PathLayer.visible = false
	for cell in $Tiles/ObjectLayer.get_used_cells():
		match $Tiles/ObjectLayer.get_cell_atlas_coords(cell):
			Vector2i(0, 0):
				var player = load("res://scenes/objects/player.tscn").instantiate()
				player.position = $Tiles/ObjectLayer.map_to_local(cell)
				$Players.add_child(player)
				$Players/Camera.reparent(player)
				$Players/Player/Camera.position = Vector2()
			Vector2i(1, 0):
				var pumpkin = load("res://scenes/objects/pumpkin.tscn").instantiate()
				pumpkin.position = $Tiles/ObjectLayer.map_to_local(cell)
				$Obstacles.add_child(pumpkin)
			Vector2i(2, 0):
				var crystal = load("res://scenes/objects/crystal.tscn").instantiate()
				crystal.position = $Tiles/ObjectLayer.map_to_local(cell)
				$Obstacles.add_child(crystal)
			Vector2i(3, 0):
				var exit = load("res://scenes/objects/exit.tscn").instantiate()
				exit.position = $Tiles/ObjectLayer.map_to_local(cell) + Vector2(8, 8)
				$Obstacles.add_child(exit)
			Vector2i(0, 1):
				var spike = load("res://scenes/objects/spike.tscn").instantiate()
				spike.position = $Tiles/ObjectLayer.map_to_local(cell)
				$Obstacles.add_child(spike)
			Vector2i(1, 1):
				var bat = load("res://scenes/objects/bat.tscn").instantiate()
				bat.position = $Tiles/ObjectLayer.map_to_local(cell)
				$Obstacles.add_child(bat)
	$Tiles/ObjectLayer.queue_free()

	$Music.play()

func _process(_delta: float) -> void:
	var x = 1.0 - $Players/Player.position.x / 2880 / 2
	$Background/Background1a.position.x = x * 640 - 320
	$Background/Background1b.position.x = x * 640 + 320
	$Background/Background2a.position.x = fmod(x * 640 * 2, 640) - 320
	$Background/Background2b.position.x = fmod(x * 640 * 2, 640) + 320
	$Background/Background3a.position.x = fmod(x * 640 * 3, 640) - 320
	$Background/Background3b.position.x = fmod(x * 640 * 3, 640) + 320
	$Background/Background4a.position.x = fmod(x * 640 * 4, 640) - 320
	$Background/Background4b.position.x = fmod(x * 640 * 4, 640) + 320

	var y = 60 + (1.0 - $Players/Player.position.y / 480) * 120 / 2
	$Background/Background1a.position.y = y
	$Background/Background1b.position.y = y
	$Background/Background2a.position.y = y
	$Background/Background2b.position.y = y
	$Background/Background3a.position.y = y
	$Background/Background3b.position.y = y
	$Background/Background4a.position.y = y
	$Background/Background4b.position.y = y
