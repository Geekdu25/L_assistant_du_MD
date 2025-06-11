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
	var script_path = ProjectSettings.globalize_path("user://mpv_send.sh")
	var result = []
	OS.execute(script_path, [cmd], result, false)

func play_music(godot_path: String):
	print("[MUSIC] play_music appelé avec", godot_path)
	stop_music()
	await get_tree().process_frame
	var abs_path = ProjectSettings.globalize_path(godot_path)
	print("[MUSIC] Chemin absolu :", abs_path)
	# Copie temporaire si caractères spéciaux
	var tmp_path = "/tmp/mdmusic_current.ogg"
	if FileAccess.file_exists(tmp_path):
		DirAccess.remove_absolute(tmp_path)
	var src = FileAccess.open(abs_path, FileAccess.READ)
	var dst = FileAccess.open(tmp_path, FileAccess.WRITE)
	if src and dst:
		dst.store_buffer(src.get_buffer(src.get_length()))
		src.close()
		dst.close()
		print("[MUSIC] Fichier copié vers chemin simple :", tmp_path)
		abs_path = tmp_path
	else:
		print("[MUSIC] ERREUR : Impossible de copier la musique vers un chemin simple")
		return
	music_path = abs_path
	_kill_old_socket()
	var args = [
		"--no-video",
		"--quiet",
		"--input-ipc-server=" + ipc_path,
		abs_path
	]
	var pid = OS.create_process(mpv_path, args)
	print("[MUSIC] mpv lancé avec PID :", pid)
	var dir = DirAccess.open("/tmp")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			print("[DEBUG] Fichier vu dans /tmp par Godot :", file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	var elapsed := 0.0
	var timeout := 2.0
	while not FileAccess.file_exists(ipc_path) and elapsed < timeout:
		await get_tree().create_timer(0.05).timeout
		elapsed += 0.05
	if FileAccess.file_exists(ipc_path):
		print("[MUSIC] Socket mpv prêt :", ipc_path)
		playing = true
	else:
		print("[MUSIC] ERREUR : Socket mpv NON créé après 2s :", ipc_path)
		playing = false

func pause_music():
	print("[MUSIC] pause_music appelé")
	if not playing or not FileAccess.file_exists(ipc_path):
		print("[MUSIC] Pas de musique en cours ou socket introuvable")
		return
	send_mpv_command('{"command": ["cycle", "pause"]}')

func stop_music():
	print("[MUSIC] stop_music appelé")
	if not playing or not FileAccess.file_exists(ipc_path):
		print("[MUSIC] Pas de musique en cours ou socket introuvable")
		playing = false
		music_path = ""
		return
	print("[MUSIC] Envoi commande quit à", ipc_path)
	send_mpv_command('{"command": ["quit"]}')
	await get_tree().create_timer(0.2).timeout
	_kill_old_socket()
	playing = false
	music_path = ""
