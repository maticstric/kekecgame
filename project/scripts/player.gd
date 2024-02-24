extends CharacterBody2D


@export var move_speed : float
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float
@export var max_jumps : int

@onready var jump_velocity = -(2.0 * jump_height) / jump_time_to_peak
@onready var jump_gravity = -(-2.0 * jump_height) / jump_time_to_peak ** 2
@onready var fall_gravity = -(-2.0 * jump_height) / jump_time_to_descent ** 2

var jump_num = 0
var authority = false

func _physics_process(delta):
	if authority:
		velocity.x = get_input_velocity() * move_speed
		velocity.y += get_gravity() * delta
		
		if is_on_floor():
			jump_num = 0
		
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				jump()
			elif jump_num < max_jumps - 1:
				jump()
				jump_num += 1
		
		move_and_slide()
		
		var pos = get_global_position()
		MultiplayerSenderClient.send_position(multiplayer.get_unique_id(), pos.x, pos.y)
	else:
		var peer_id = name.to_int()
		
		if MultiplayerController.peers.has(peer_id):
			if MultiplayerController.peers[peer_id].has_all(["pos_x", "pos_y"]):
				var pos_x = MultiplayerController.peers[peer_id]["pos_x"]
				var pos_y = MultiplayerController.peers[peer_id]["pos_y"]
				var new_pos = Vector2(pos_x, pos_y)
				new_pos = get_global_position().slerp(new_pos, 0.5)
				set_global_position(new_pos)

func jump():
	velocity.y = jump_velocity


func get_gravity():
	return jump_gravity if velocity.y < 0.0 else fall_gravity


func get_input_velocity():
	var horizontal = 0.0
	
	if Input.is_action_pressed("left"):
		horizontal = -1.0
	
	if Input.is_action_pressed("right"):
		horizontal = 1.0
		
	return horizontal
