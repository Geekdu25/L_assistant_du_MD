class_name Music_Controller
extends Node

var mpv_path := "mpv"
var process_id := 0
var ipc_path := ""
var playing := false
var music_path := ""
var monitor_timer : Timer

func _ready():
	if OS.get_name() == "Windows":
		ipc_path = "\\\\.\\pipe\\mdmusic"
	else:
		ipc_path = "/tmp/mdmusic"
	monitor_timer = Timer.new()
	monitor_timer.wait_time = 1.0
	monitor_timer.one_shot = false
	monitor_timer.autostart = false
	add_child(monitor_timer)
	monitor_timer.connect("timeout", Callable(self, "_on_monitor_timer_timeout"))

func _kill_old_socket():
	if FileAccess.file_exists(ipc_path):
		OS.execute("rm", ["-f", ipc_path], [])

func send_mpv_command_json(cmd: Dictionary):
	if not FileAccess.file_exists(ipc_path):
		print("[MUSIC] IPC socket non trouvé :", ipc_path)
		return
	var json_str = JSON.stringify(cmd) + "\n"
	var file = FileAccess.open(ipc_path, FileAccess.WRITE)
	if file:
		file.store_string(json_str)
		file.close()
	else:
		print("[MUSIC] Impossible d’ouvrir le socket IPC")

func _on_monitor_timer_timeout():
	if process_id != 0 and not OS.is_process_running(process_id):
		playing = false
		music_path = ""
		monitor_timer.stop()
		# Notifie l’UI (musique.gd) que la lecture est terminée
		get_tree().call_group("musique_ui", "on_music_stopped_by_end")

func play_music(godot_path: String):
	var abs_path = ProjectSettings.globalize_path(godot_path)
	if playing and music_path == abs_path:
		print("[MUSIC] La même musique est déjà en cours")
		return
	stop_music()
	await get_tree().process_frame
	var args = [
		"--no-video",
		"--quiet",
		"--input-ipc-server=" + ipc_path,
		abs_path
	]
	process_id = OS.create_process(mpv_path, args)
	playing = true
	music_path = abs_path
	await get_tree().create_timer(0.5).timeout
	playing = true
	music_path = abs_path
	monitor_timer.start() # Démarre la surveillance

func pause_music():
	if not playing:
		print("[MUSIC] Pas de musique en cours")
		return
	send_mpv_command_json({"command": ["cycle", "pause"]})

func stop_music():
	if not playing:
		print("[MUSIC] Pas de musique en cours")
		return
	send_mpv_command_json({"command": ["quit"]})
	await get_tree().create_timer(0.2).timeout
	_kill_old_socket()
	playing = false
	music_path = ""
