class_name Music_Controller
extends Node

var mpv_path := "mpv"
var process_id := 0
var ipc_path := ""
var playing := false
var music_path := ""

func _get_ipc_path() -> String:
	if OS.get_name() == "Windows":
		return "\\\\.\\pipe\\mpv_audio_pipe"
	else:
		return "/tmp/mpv_audio_pipe"

func play_music(godot_path: String):
	stop_music()
	ipc_path = _get_ipc_path()
	var abs_path = ProjectSettings.globalize_path(godot_path)
	music_path = abs_path
	var args = [
		"--no-video",
		"--quiet",
		"--input-ipc-server=" + ipc_path,
		abs_path
	]
	process_id = OS.create_process(mpv_path, args)
	playing = true

func pause_music():
	if not playing or ipc_path == "":
		return
	if OS.get_name() == "Windows":
		var cmd = "echo {\"command\": [\"cycle\", \"pause\"]} > " + ipc_path
		OS.execute("cmd", ["/C", cmd], [])
	else:
		if FileAccess.file_exists(ipc_path):
			var f = FileAccess.open(ipc_path, FileAccess.WRITE)
			if f:
				f.store_line('{"command": ["cycle", "pause"]}')
				f.close()

func stop_music():
	if playing and ipc_path != "":
		if OS.get_name() == "Windows":
			var cmd = "echo {\"command\": [\"quit\"]} > " + ipc_path
			OS.execute("cmd", ["/C", cmd], [])
		else:
			if FileAccess.file_exists(ipc_path):
				var f = FileAccess.open(ipc_path, FileAccess.WRITE)
				if f:
					f.store_line('{"command": ["quit"]}')
					f.close()
	playing = false
	ipc_path = ""
	music_path = ""
