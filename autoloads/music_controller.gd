class_name Music_Controller
extends Node

var mpv_pid: int = -1
var mpv_socket_path: String = "/tmp/mpvsocket"

func _ready():
	# Nettoie une ancienne socket si besoin
	if FileAccess.file_exists(mpv_socket_path):
		OS.execute("rm", ["-f", mpv_socket_path], [])

func play_music(path: String):
	stop_music()  # Stoppe la musique précédente si besoin
	# Nettoie l’ancienne socket
	if FileAccess.file_exists(mpv_socket_path):
		OS.execute("rm", ["-f", mpv_socket_path], [])
	# Lance mpv sans GUI, mode IPC
	var args = [
		"--no-video",
		"--force-window=no",
		"--quiet",
		"--input-ipc-server=" + mpv_socket_path,
		path
	]
	mpv_pid = OS.create_process("mpv", args)
	print("mpv lancé avec pid : ", mpv_pid)

func pause_music():
	_send_mpv_command({"command": ["cycle", "pause"]})

func stop_music():
	if mpv_pid > 0:
		# Arrête proprement le processus via IPC
		_send_mpv_command({"command": ["quit"]})
		mpv_pid = -1

func _send_mpv_command(cmd: Dictionary):
	if not FileAccess.file_exists(mpv_socket_path):
		print("Socket mpv introuvable, mpv doit être lancé d’abord.")
		return
	var json_cmd = JSON.stringify(cmd) + "\n"
	var socket = StreamPeerUnix.new()
	var err = socket.connect_to_path(mpv_socket_path)
	if err == OK:
		socket.put_utf8_string(json_cmd)
		socket.disconnect_from_host()
	else:
		print("Erreur de connexion à la socket mpv : ", err)
