extends Node

var mpv_path := "mpv" # Mets ici le chemin du binaire mpv si besoin (ex: "res://tools/mpv/mpv.exe")
var process_id := 0
var ipc_path := ""
var playing := false

func _get_ipc_path() -> String:
	if OS.get_name() == "Windows":
		# Pipe Windows : \\.\pipe\mpv_audio_pipe_xxx
		return "\\\\.\\pipe\\mpv_audio_pipe_%d" % int(OS.get_unix_time())
	else:
		# Socket Unix : /tmp/mpv_audio_pipe_xxx
		return "/tmp/mpv_audio_pipe_%d" % int(OS.get_unix_time())

func play_music(abs_path: String):
	stop_music()
	ipc_path = _get_ipc_path()
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
	# Sous Windows, FileAccess ne gère pas les pipes nommés : on utilise process OS natif via 'cmd' ou 'powershell'
	if OS.get_name() == "Windows":
		var cmd = "echo {\"command\": [\"cycle\", \"pause\"]} > " + ipc_path
		OS.execute("cmd", ["/C", cmd], false)
	else:
		# Sous Linux/Mac, pipe Unix classique
		var f = FileAccess.open(ipc_path, FileAccess.WRITE)
		if f:
			f.store_line('{"command": ["cycle", "pause"]}')
			f.close()

func stop_music():
	if process_id != 0:
		OS.kill(process_id)
		process_id = 0
	playing = false
	ipc_path = ""
