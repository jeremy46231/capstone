extends Node

const port = 9871
var peer: ENetMultiplayerPeer

func __ready():
	multiplayer.peer_connected.connect(_on_peer_connect)
	multiplayer.peer_disconnected.connect(_on_peer_disconnect)

func host():
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	print("hosted on port ", port)

func join(ip):
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	print("connecting to ", ip)

func _on_peer_connect(id):
	print("Player connected: ", id)
	
func _on_peer_disconnect(id):
	print("Player disconnected: ", id)
