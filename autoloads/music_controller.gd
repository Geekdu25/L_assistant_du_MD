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

func send_mpv_command(cmd: String):
	var script_path = "/home/etienne/mpv_send.sh"
	var cmd_dict = {"command": ["cycle", "pause"]}
	cmd = JSON.stringify(cmd_dict) # Donne la bonne chaîne JSON
	print("CHAINE JSON:", cmd)
	var bash_cmd = "printf '%s' | \"%s\"" % [cmd, script_path]
	print("Commande lancée :", bash_cmd)
	var result = []
	var code = OS.execute("bash", ["-c", bash_cmd], result, false)
	print("[MUSIC] Résultat bash direct : code =", code, " sortie =", result)

func play_music(godot_path: String):
	print("[MUSIC] play_music appelé avec", godot_path)
	stop_music()
	await get_tree().process_frame
	var abs_path = ProjectSettings.globalize_path(godot_path)
	# ... copie du fichier etc ...
	var args = [
		"--no-video",
		"--quiet",
		"--input-ipc-server=" + ipc_path,
		abs_path
	]
	print(ipc_path)
	process_id = OS.create_process(mpv_path, args)
	print("[MUSIC] mpv lancé avec PID :", process_id)
	playing = true


func pause_music():
	print("[MUSIC] pause_music appelé")
	if not playing:
		print("[MUSIC] Pas de musique en cours")
		return
	send_mpv_command("{\"command\": [\"cycle\", \"pause\"]}")

func stop_music():
	print("[MUSIC] stop_music appelé")
	if not playing:
		print("[MUSIC] Pas de musique en cours")
		return
	print("[MUSIC] Envoi commande quit à", ipc_path)
	send_mpv_command("{\"command\": [\"quit\"]}")
	await get_tree().create_timer(0.2).timeout
	_kill_old_socket()
	playing = false
	music_path = ""
