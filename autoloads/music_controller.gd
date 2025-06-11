extends Node

# Chemin du socket mpv (à adapter si tu changes l'option --input-ipc-server)
const MPV_SOCKET = "/tmp/mdmusic"

var music_path: String = ""
var mpv_pid: int = -1
var playing = false

func play_music(path: String):
	# Stop la musique en cours si besoin
	if music_path != "":
		stop_music()	
	var abs_path = ProjectSettings.globalize_path(path)
	music_path = abs_path	
	# Lance mpv avec le socket IPC
	var args = [
		"--no-video",
		"--input-ipc-server=" + MPV_SOCKET,
		abs_path
	]
	# Démarre mpv en tâche de fond (sans bloquer Godot)
	mpv_pid = OS.create_process("mpv", args)
	# Optionnel : tu peux vérifier que le fichier existe avant
	if not FileAccess.file_exists(abs_path):
		push_error("Fichier musical introuvable : %s" % abs_path)
		music_path = ""
		return
	playing = true

func send_mpv_command(cmd: String):
	var script_path = "/home/etienne/mpv_send.sh"
	var result = []
	var code = OS.execute(script_path, [cmd], result)
	print("[MUSIC] Résultat OS.execute : code =", code, " sortie =", result)

func pause_music():
	print("[MUSIC] pause_music appelé")
	if not playing:
		print("[MUSIC] Pas de musique en cours")
		return
	send_mpv_command(JSON.stringify({"command": ["cycle", "pause"]}))

func stop_music():
	print("[MUSIC] stop_music appelé")
	if not playing:
		print("[MUSIC] Pas de musique en cours")
		return
	send_mpv_command(JSON.stringify({"command": ["quit"]}))
	playing = false

# Optionnel : pour vérifier que mpv tourne
func is_music_playing() -> bool:
	return music_path != ""
