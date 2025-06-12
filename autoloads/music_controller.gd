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

func send_mpv_command_json(cmd: String):
	var script_path = "user://.dm_mpv_send.sh"
	var cmd_b64 = Marshalls.utf8_to_base64(cmd)
	var result = []
	var code = OS.execute(script_path, [cmd_b64], result)
	print("[MUSIC] Résultat OS.execute : code =", code, " sortie =", result)

func play_music(godot_path: String):
	print("[MUSIC] play_music appelé avec", godot_path)
	stop_music()
	await get_tree().process_frame
	var abs_path = ProjectSettings.globalize_path(godot_path)
	var args = [
		"--no-video",
		"--quiet",
		"--input-ipc-server=" + ipc_path,
		abs_path
	]
	print("[MUSIC] Lancement mpv avec args :", args)
	process_id = OS.create_process(mpv_path, args)
	playing = true
	music_path = abs_path
	await get_tree().create_timer(0.5).timeout

func pause_music():
	print("[MUSIC] pause_music appelé")
	var json_cmd = JSON.stringify({"command": ["cycle", "pause"]}) + "\n"
	send_mpv_command_json(json_cmd)

func stop_music():
	print("[MUSIC] stop_music appelé")
	var json_cmd = JSON.stringify({"command": ["quit"]}) + "\n"
	send_mpv_command_json(json_cmd)
	await get_tree().create_timer(0.2).timeout
	_kill_old_socket()
	playing = false
	music_path = ""
