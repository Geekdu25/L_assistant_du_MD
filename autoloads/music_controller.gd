class_name Music_Controller
extends Node

var mpv_pid: int = -1
var mpv_socket_path: String = "/tmp/mpvsocket"

func _ready():
	# Nettoie une ancienne socket si besoin
	if FileAccess.file_exists(mpv_socket_path):
		OS.execute("rm", ["-f", mpv_socket_path], [])

func play_music(path: String):
	stop_music()
	if FileAccess.file_exists(mpv_socket_path):
		OS.execute("rm", ["-f", mpv_socket_path], [])
	var args = [
		"--no-video",
		"--force-window=no",
		"--quiet",
		"--input-ipc-server=" + mpv_socket_path,
		path
	]
	mpv_pid = OS.create_process("mpv", args)
	# Attendre que la socket soit créée avant de pouvoir envoyer des commandes
	await_socket_ready()

func pause_music():
	_send_mpv_command({"command": ["cycle", "pause"]})

func stop_music():
	_send_mpv_command({"command": ["quit"]})
	mpv_pid = -1

func await_socket_ready(timeout := 2.0):
	# Attend jusqu'à 2 secondes que le socket apparaisse (ou moins si déjà là)
	var elapsed = 0.0
	while not FileAccess.file_exists(mpv_socket_path) and elapsed < timeout:
		await get_tree().create_timer(0.05).timeout
		elapsed += 0.05

func _send_mpv_command(cmd: Dictionary):
	if not FileAccess.file_exists(mpv_socket_path):
		print("Socket mpv introuvable, mpv doit être lancé d’abord.")
		return
	var json_cmd = JSON.stringify(cmd) + "\n"
	OS.execute("socat", ["-", "UNIX-CONNECT:" + mpv_socket_path], [], json_cmd)
