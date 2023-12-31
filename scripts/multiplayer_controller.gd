extends Control

@export var ip_address = ""
@export var port = 8910

var peer


func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)


func peer_connected(id):
	print("Player connected: " + str(id))


func peer_disconnected(id):
	print("Player disconnected: " + str(id))


func connected_to_server():
	print("Connected to server!")
	send_player_information.rpc_id(1, $Username.text, multiplayer.get_unique_id())


func connection_failed():
	print("Couldn't connect")


@rpc("any_peer")
func send_player_information(player_name, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"player_name": player_name,
			"id": id,
			"score": 0
		}

	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(GameManager.players[i].player_name, i)


@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://scenes/levels/test_level.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()


func _on_host_button_down():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port);

	if error != OK:
		print("Cannot host: " + error)
		return

	# What is this???
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")

	send_player_information($Username.text, multiplayer.get_unique_id())


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, port)

	# What is this???
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	multiplayer.set_multiplayer_peer(peer)


func _on_start_button_down():
	start_game.rpc()
