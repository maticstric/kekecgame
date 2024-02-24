extends Node


func _process(_delta):
	while MultiplayerController.udp_peer.get_available_packet_count() > 0:
		var packet = MultiplayerController.udp_peer.get_packet()
		var packet_type = packet[0]
		
		var packet_type_string = MultiplayerController.PacketType.keys()[packet_type]
		if GameManager.DEBUG: print("Client received new UDP packet: " + packet_type_string)
		
		match packet_type:
			MultiplayerController.PacketType.NEW_UDP_CONNECTION_ACK:
				receive_new_udp_connection_ack()
			MultiplayerController.PacketType.POSITION:
				receive_position(packet)


func receive_new_udp_connection_ack():
	MultiplayerController.udp_connected = true
	if GameManager.DEBUG: print("Connected to UDP server!")


func receive_position(packet):
	var time = packet.decode_u32(1)
	var peer_id = packet.decode_u32(5)
	var pos_x = packet.decode_half(9)
	var pos_y = packet.decode_half(11)
	
	if not MultiplayerController.peers[peer_id].has("time") or MultiplayerController.peers[peer_id].time < time:
		MultiplayerController.peers[peer_id].pos_x = pos_x
		MultiplayerController.peers[peer_id].pos_y = pos_y
		MultiplayerController.peers[peer_id].time = time
