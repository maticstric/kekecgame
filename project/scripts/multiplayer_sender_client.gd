extends Node


func send_new_udp_connection_req(peer_id):
	var packet = PackedByteArray()
	packet.resize(5)
	
	packet.encode_u8(0, MultiplayerController.PacketType.NEW_UDP_CONNECTION_REQ)
	packet.encode_u32(1, peer_id)

	if GameManager.DEBUG: print("Client sent new UDP packet: NEW_UDP_CONNECTION_REQ")
	MultiplayerController.udp_peer.put_packet(packet)


func send_position(peer_id, pos_x, pos_y):
	var packet = PackedByteArray()
	packet.resize(13)
	packet.encode_u8(0, MultiplayerController.PacketType.POSITION)
	packet.encode_u32(1, GameManager.cur_time)
	packet.encode_u32(5, peer_id)
	packet.encode_half(9, pos_x)
	packet.encode_half(11, pos_y)
	
	if GameManager.DEBUG: print("Client sent new UDP packet: POSITION")

	# If host, don't send position to host, just send it to everyone else
	# Don't have to go through the host, can contact directly
	if peer_id == 1:
		for peer in MultiplayerController.udp_peers:
			peer.put_packet(packet)
		
		return
	
	MultiplayerController.udp_peer.put_packet(packet)
