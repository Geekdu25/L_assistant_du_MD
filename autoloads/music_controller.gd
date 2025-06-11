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
	var code = OS.execute("/chemin/vers/mpv_send.sh", [cmd], result)

func stop_music():
	_send_mpv_command({"command": ["quit"]})
	music_path = ""
	mpv_pid = -1

func _send_mpv_command(cmd_dict: Dictionary) -> int:
	var json_cmd = JSON.stringify(cmd_dict)
	var args = ["-", "UNIX-CONNECT:" + MPV_SOCKET]
	var result = []
	var exit_code = OS.execute("socat", args, result, json_cmd)
	if exit_code != 0:
		push_error("Erreur d'envoi à mpv : %s" % result)
	return exit_code

# Optionnel : pour vérifier que mpv tourne
func is_music_playing() -> bool:
	return music_path != ""
