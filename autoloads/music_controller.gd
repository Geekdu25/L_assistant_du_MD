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
	print("[MUSIC] play_music appelé avec", godot_path)
	stop_music()
	await get_tree().process_frame
	var abs_path = ProjectSettings.globalize_path(godot_path)
	print("[MUSIC] Chemin absolu :", abs_path)
	music_path = abs_path
	_kill_old_socket()
	var args = [
		"--no-video",
		"--quiet",
		"--input-ipc-server=" + ipc_path,
		abs_path
	]
	print("[MUSIC] Lancement mpv :", mpv_path, args)
	# TEST: OS.execute (bloquant, juste pour log)
	var output = []
	var err = []
	var exit_code = OS.execute(mpv_path, args, output, true, err)
	print("[MUSIC] mpv OS.execute exit code:", exit_code)
	print("[MUSIC] mpv stdout:", output)
	print("[MUSIC] mpv stderr:", err)
	# TEST: socket existe ?
	if FileAccess.file_exists(ipc_path):
		print("[MUSIC] Socket mpv prêt :", ipc_path)
		playing = true
	else:
		print("[MUSIC] ERREUR : Socket mpv NON créé après OS.execute :", ipc_path)
		playing = false

func pause_music():
	print("[MUSIC] pause_music appelé")
	if not playing or not FileAccess.file_exists(ipc_path):
		print("[MUSIC] Pas de musique en cours ou socket introuvable")
		return
	var f = FileAccess.open(ipc_path, FileAccess.WRITE)
	if f:
		print("[MUSIC] Envoi commande pause à", ipc_path)
		f.store_line('{"command": ["cycle", "pause"]}')
		f.close()
	else:
		print("[MUSIC] Impossible d'ouvrir le socket en écriture :", ipc_path)

func stop_music():
	print("[MUSIC] stop_music appelé")
	if not playing or not FileAccess.file_exists(ipc_path):
		print("[MUSIC] Pas de musique en cours ou socket introuvable")
		playing = false
		music_path = ""
		return
	var f = FileAccess.open(ipc_path, FileAccess.WRITE)
	if f:
		print("[MUSIC] Envoi commande quit à", ipc_path)
		f.store_line('{"command": ["quit"]}')
		f.close()
	else:
		print("[MUSIC] Impossible d'ouvrir le socket en écriture pour stop :", ipc_path)
	await get_tree().create_timer(0.2).timeout
	_kill_old_socket()
	playing = false
	music_path = ""
