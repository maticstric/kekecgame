extends Control


func _ready():
	if multiplayer.is_server():
		$Client.hide()
	else:
		$Host.hide()


func _on_start_game_button_pressed():
	MultiplayerController.start_game.rpc()
