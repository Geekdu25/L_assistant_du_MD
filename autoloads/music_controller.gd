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

func send_mpv_command(cmd: String) -> void:
	# Chemin absolu du script mpv_send.sh dans user://
	var script_path := ProjectSettings.globalize_path("user://mpv_send.sh")
	var result := []
	# Commande exemple à passer : '{"command": ["cycle", "pause"]}'
	# On vérifie d'abord que le script existe
	if not FileAccess.file_exists("user://mpv_send.sh"):
		print("[MUSIC] ERREUR : Script mpv_send.sh absent à ", script_path)
		return
	# (Facultatif) Vérifier si socat est visible via PATH dans l'environnement Godot
	var socat_check := []
	OS.execute("which", ["socat"], socat_check, false)
	print("[MUSIC] which socat :", socat_check)
	# Appel du script avec la commande JSON comme argument
	var code := OS.execute(script_path, [cmd], result, false)
	print("[MUSIC] Résultat OS.execute : code =", code, " sortie =", result)

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
	send_mpv_command("{\"command\": [\"cycle\", \"pause\"]}")
	await get_tree().create_timer(0.2).timeout
	_kill_old_socket()
	playing = false
	music_path = ""
