extends Node


func _process(_delta):
	MultiplayerController.udp_server.poll()
	
	udp_check_for_new_connections()
	
	for peer in MultiplayerController.udp_peers:
		while peer.get_available_packet_count() > 0:
			var packet = peer.get_packet()
			var packet_type = packet[0]
			
			var packet_type_string = MultiplayerController.PacketType.keys()[packet_type]
			if GameManager.DEBUG: print("Host received new UDP packet: " + packet_type_string)
			
			match packet_type:
				MultiplayerController.PacketType.NEW_UDP_CONNECTION_REQ:
					receive_new_udp_connection_req(peer, packet)
				MultiplayerController.PacketType.POSITION:
					receive_position(packet)


func receive_new_udp_connection_req(peer, packet):
	var peer_id = packet.decode_u32(1)
	MultiplayerController.id_to_peer[peer_id] = peer
	MultiplayerSenderHost.send_new_udp_connection_ack(peer)


func receive_position(packet):
	var sender_id = packet.decode_u32(1)
	
	for peer_id in MultiplayerController.peers.keys():
		if peer_id == sender_id: continue # Don't need to send position to whoever sent it
		if peer_id == 1: # Don't need to send position to server. Can update locally
			MultiplayerReceiverClient.receive_position(packet)
			continue
		
		var udp_peer = MultiplayerController.id_to_peer[peer_id]
		MultiplayerSenderHost.send_position(udp_peer, packet)


func udp_check_for_new_connections():
	if MultiplayerController.udp_server.is_connection_available():
		var peer = MultiplayerController.udp_server.take_connection()
		MultiplayerController.udp_peers.append(peer)


