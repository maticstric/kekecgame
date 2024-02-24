extends Node2D

@export var player_scene : PackedScene


func _ready():
	spawn_players()


func spawn_players():
	# Sort so that players spawn in same positions
	var sorted_peer_ids = MultiplayerController.peers.keys()
	sorted_peer_ids.sort()
	
	for i in range(len(sorted_peer_ids)):
		var peer_id = sorted_peer_ids[i]
		
		var current_player = player_scene.instantiate()
		current_player.name = str(peer_id)
		current_player.get_node("UsernameLabel").text = MultiplayerController.peers[peer_id]["username"]
		add_child(current_player)
		
		if peer_id == multiplayer.get_unique_id():
			current_player.authority = true
		else:
			# Don't bump into other players
			current_player.get_node("CollisionShape2D").set_disabled(true)
			
		current_player.global_position = $SpawnLocations.get_child(i).global_position
