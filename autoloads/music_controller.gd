class_name Music_Controller
extends Node

var mpv_pid: int = -1

var mpv_socket_path: String = "/tmp/mpvsocket"
var music_path: String = ""

func _ready():
	# Nettoie une ancienne socket si besoin
	if FileAccess.file_exists(mpv_socket_path):
		OS.execute("rm", ["-f", mpv_socket_path], [])
	if OS.get_name() == "Windows":
		mpv_socket_path = "\\\\.\\pipe\\mpvsocket"
	else:
		mpv_socket_path = "/tmp/mpvsocket"

func play_music(godot_path: String):
	stop_music()  # Stoppe d'abord toute lecture en cours
	var abs_path = ProjectSettings.globalize_path(godot_path)
	music_path = abs_path
	# Génère un socket unique pour chaque session
	var base_socket = "mpvsocket_%d" % int(Time.get_ticks_msec())
	if OS.get_name() == "Windows":
		mpv_socket_path = "\\\\.\\pipe\\" + base_socket
	else:
		mpv_socket_path = "/tmp/" + base_socket
	if FileAccess.file_exists(mpv_socket_path):
		OS.execute("rm", ["-f", mpv_socket_path], [])
	var args = [
		"--no-video",
		"--force-window=no",
		"--quiet",
		"--input-ipc-server=" + mpv_socket_path,
		abs_path
	]
	mpv_pid = OS.create_process("mpv", args)
	await _await_socket_ready()

func stop_music():
	if mpv_pid > 0 and FileAccess.file_exists(mpv_socket_path):
		_send_mpv_command({"command": ["quit"]})
		mpv_pid = -1
	# Supprime le socket pour éviter les conflits
	if FileAccess.file_exists(mpv_socket_path):
		OS.execute("rm", ["-f", mpv_socket_path], [])
	music_path = ""

func pause_music():
	if FileAccess.file_exists(mpv_socket_path):
		_send_mpv_command({"command": ["cycle", "pause"]})
	else:
		print("Socket mpv introuvable, pause impossible.")

func _await_socket_ready(timeout := 2.0) -> void:
	var elapsed = 0.0
	while not FileAccess.file_exists(mpv_socket_path) and elapsed < timeout:
		await get_tree().create_timer(0.05).timeout
		elapsed += 0.05
	if not FileAccess.file_exists(mpv_socket_path):
		print("ATTENTION: La socket mpv n'a pas été créée après %s secondes !" % timeout)

func _send_mpv_command(cmd: Dictionary):
	if not FileAccess.file_exists(mpv_socket_path):
		print("Socket mpv introuvable, mpv doit être lancé d’abord.")
		return
	var json_cmd = JSON.stringify(cmd) + "\n"
	OS.execute("socat", ["-", "UNIX-CONNECT:" + mpv_socket_path], [], json_cmd)
