extends Node

# Chemin du socket mpv (à adapter si tu changes l'option --input-ipc-server)
const MPV_SOCKET = "/tmp/mdmusic"

var music_path: String = ""
var mpv_pid: int = -1

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

func pause_music():
	var cmd = JSON.stringify({"command": ["cycle", "pause"]})
	var result = []
	# Le 1er argument est la commande JSON
	var code = OS.execute("/home/etienne/mpv_send.sh", [cmd], result)

func stop_music():
	var cmd = JSON.stringify({"command": ["quit"]})
	var result = []
	# Le 1er argument est la commande JSON
	var code = OS.execute("/home/etienne/mpv_send.sh", [cmd], result)

# Optionnel : pour vérifier que mpv tourne
func is_music_playing() -> bool:
	return music_path != ""
