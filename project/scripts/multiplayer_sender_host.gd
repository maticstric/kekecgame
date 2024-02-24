extends Node


func send_new_udp_connection_ack(peer):
	var packet = PackedByteArray()
	packet.resize(1)
	
	packet.encode_u8(0, MultiplayerController.PacketType.NEW_UDP_CONNECTION_ACK)
	
	if GameManager.DEBUG: print("Host sent new UDP packet: NEW_UDP_CONNECTION_ACK")
	peer.put_packet(packet)


func send_position(peer, packet):
	if GameManager.DEBUG: print("Host sent new UDP packet: POSITION")
	peer.put_packet(packet)
