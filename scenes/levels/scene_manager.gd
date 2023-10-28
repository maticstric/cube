extends Node2D

@export var player_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var spawn_locations= get_node("SpawnLocations")
	var index = 0
	
	for player in GameManager.players:
		var current_player = player_scene.instantiate()
		current_player.name = str(GameManager.players[player].id)
		add_child(current_player)
		
		# I think this assumes the GameManger.players is an ordered dictionary
		# since we need every client to spawn the players in the same location.
		# What happens if GameManager.players isn't in the same order?
		current_player.global_position = spawn_locations.get_child(index).global_position
		
		index += 1
