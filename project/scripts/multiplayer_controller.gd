extends Node

enum PacketType { 
	NEW_UDP_CONNECTION_REQ,
	NEW_UDP_CONNECTION_ACK,
	POSITION
}

const UDP_PORT = 50000
const HIGH_LEVEL_PORT = 50001

# Set by main_menu.gd when "join" button pressed
var host_ip_address

# Host
var udp_server = UDPServer.new()
var udp_peers = []
var id_to_peer = { } # Key: peer_id, Value: PacketPeerUDP

# Client
var udp_peer = PacketPeerUDP.new()
var udp_connected = false

var player_info = {
	"username": ""
}

# Key: peer_id, Value: player_info. Includes myself
var peers = { }


func _ready():
	multiplayer.connected_to_server.connect(_on_connected_to_high_level_server)
	multiplayer.peer_connected.connect(_on_peer_connected)


func host():
	start_high_level_server(HIGH_LEVEL_PORT)
	start_udp_server(UDP_PORT)
	
	peers[1] = player_info
	
	get_tree().change_scene_to_file("res://project/scenes/menus/lobby_menu.tscn")


func join():
	# We'll only join the UDP server after succesfully joining
	# the high level server and getting a unique peer id
	#
	# Look at: `_on_connected_to_high_level_server`
	
	connect_to_high_level_server(host_ip_address, HIGH_LEVEL_PORT)


func start_high_level_server(port):
	if GameManager.DEBUG: print("Started high level server!")
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer


func start_udp_server(port):
	if GameManager.DEBUG: print("Started UDP server!")
	udp_server.listen(port)


func connect_to_udp_server(ip_address, port, high_level_peer_id):
	if GameManager.DEBUG: print("Connecting to UDP server...")
	udp_peer.connect_to_host(ip_address, port)
	
	MultiplayerSenderClient.send_new_udp_connection_req(high_level_peer_id)


func connect_to_high_level_server(ip_address, port):
	if GameManager.DEBUG: print("Connecting to high level server...")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, port)
	multiplayer.multiplayer_peer = peer


func _on_connected_to_high_level_server():
	var high_level_peer_id = multiplayer.get_unique_id()
	peers[high_level_peer_id] = player_info
	
	if GameManager.DEBUG: print("Connected to high level server! (" + str(high_level_peer_id) + ")")
	connect_to_udp_server(host_ip_address, UDP_PORT, high_level_peer_id)
	
	get_tree().change_scene_to_file("res://project/scenes/menus/lobby_menu.tscn")


func _on_peer_connected(peer_id):
	register_player.rpc_id(peer_id, player_info)


@rpc("any_peer", "call_remote", "reliable")
func register_player(new_player_info):
	var new_peer_id = multiplayer.get_remote_sender_id()
	
	peers[new_peer_id] = new_player_info


@rpc("authority", "call_local", "reliable")
func start_game():
	get_tree().change_scene_to_file("res://project/scenes/levels/test_level.tscn")
