class_name Music_Controller
extends Node

var mpv_path := "mpv"
var process_id := 0
var ipc_path := ""
var playing := false
var music_path := ""

func _ready():
	if OS.get_name() == "Windows":
		ipc_path = "\\\\.\\pipe\\mdmusic"
	else:
		ipc_path = "/tmp/mdmusic"

func _kill_old_socket():
	if FileAccess.file_exists(ipc_path):
		OS.execute("rm", ["-f", ipc_path], [])

func play_music(godot_path: String):
	stop_music()  # Stoppe toute instance précédente
	await get_tree().process_frame  # Laisse le temps à mpv (et à l'OS) de libérer la socket
	var abs_path = ProjectSettings.globalize_path(godot_path)
	music_path = abs_path
	_kill_old_socket()
	var args = [
		"--no-video",
		"--quiet",
		"--input-ipc-server=" + ipc_path,
		abs_path
	]
	process_id = OS.create_process(mpv_path, args)
	playing = true

func pause_music():
	if not playing or not FileAccess.file_exists(ipc_path):
		return
	var f = FileAccess.open(ipc_path, FileAccess.WRITE)
	if f:
		f.store_line('{"command": ["cycle", "pause"]}')
		f.close()

func stop_music():
	if not playing or not FileAccess.file_exists(ipc_path):
		playing = false
		music_path = ""
		return
	var f = FileAccess.open(ipc_path, FileAccess.WRITE)
	if f:
		f.store_line('{"command": ["quit"]}')
		f.close()
	await get_tree().create_timer(0.2).timeout  # Laisse mpv se fermer
	_kill_old_socket()
	playing = false
	music_path = ""
