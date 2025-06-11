class_name Music_Controller

extends Node

@export var transition_duration: float = 1.00
@export var transition_type: int = 1 # TRANS_SINE
@export var volume: float = 1.0
@onready var music_path: String = ""
@onready var sound_path: String = ""
@onready var musique_1: AudioStreamPlayer = $music_1
@onready var son_1: AudioStreamPlayer = $son_1

# Création d'un dictionnaire pour stocker les AudioStreamPlayers contrôlés
var audio_players: Dictionary = {}
var is_fading: bool = false
var queued_music: Array = []  # Utilisé pour stocker les informations en attente (chemin et boucle)

# Variables pour les boucles personnalisées
var custom_loop_start: float = 0.0
var custom_loop_end: float = 0.0
var use_custom_loop: bool = false

# Fichier contenant les points de boucle
var loop_points: Dictionary = {}

func _process(delta: float):
	# Si aucune transition n'est en cours et une musique est en attente
	if not is_fading and queued_music != null and queued_music.size() > 0:
		var path: String = queued_music[0]
		var loop: bool = queued_music[1]
		queued_music = []  # Réinitialise la file d'attente
		_internal_play_music(path, loop)
	if use_custom_loop and musique_1.playing:
		# Vérifie si la position actuelle a atteint la fin de la boucle
		if musique_1.get_playback_position() >= custom_loop_end:
			musique_1.seek(custom_loop_start)

func _ready():
	register_audio_player("music_1", musique_1)
	register_audio_player("sound_1", son_1)

# Ajoute un AudioStreamPlayer à la gestion
func register_audio_player(name: String, player: AudioStreamPlayer):
	audio_players[name] = player

func fade_audio(name: String, duration: float, fade_in: bool, stop_after_fade_out: bool = false, callback: Callable = Callable()):
	# Si un fondu est déjà en cours et qu'il s'agit d'un fondu sortant, ignorer
	if is_fading and not fade_in:
		return
	if not audio_players.has(name):
		return

	var player = audio_players[name]
	var starting_volume: float = player.volume_db if not fade_in else -80.0
	var target_volume: float = 0.0 if fade_in else -80.0
	var current_time: float = 0.0
	is_fading = true  # Indique qu'un fondu est en cours
	# Crée un Timer pour gérer le fondu
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1  # Intervalle de 100 ms
	timer.one_shot = false

	# Stocke les données nécessaires dans le Timer
	timer.set_meta("player", player)
	timer.set_meta("starting_volume", starting_volume)
	timer.set_meta("target_volume", target_volume)
	timer.set_meta("duration", duration)
	timer.set_meta("current_time", current_time)
	timer.set_meta("fade_in", fade_in)
	timer.set_meta("stop_after_fade_out", stop_after_fade_out)
	timer.set_meta("callback", callback)

	# Connecte le Timer pour exécuter `_on_fade_step`
	timer.connect("timeout", Callable(self, "_on_fade_step").bind(timer))
	timer.start()

func _on_fade_step(timer: Timer):
	# Récupère les données stockées dans le Timer
	var player: AudioStreamPlayer = timer.get_meta("player")
	var starting_volume: float = timer.get_meta("starting_volume")
	var target_volume: float = timer.get_meta("target_volume")
	var duration: float = timer.get_meta("duration")
	var current_time: float = timer.get_meta("current_time")
	var fade_in: bool = timer.get_meta("fade_in")
	var stop_after_fade_out: bool = timer.get_meta("stop_after_fade_out")
	var callback: Callable = timer.get_meta("callback")

	# Met à jour le temps écoulé
	current_time += timer.wait_time
	timer.set_meta("current_time", current_time)

	# Calcule le volume en fonction du temps écoulé
	var t: float = clamp(current_time / duration, 0.0, 1.0)
	player.volume_db = lerp(starting_volume, target_volume, t)

	# Arrête le fondu si la durée est dépassée
	if t >= 1.0:
		timer.stop()
		timer.queue_free()  # Supprime le Timer

		# Gère l'arrêt de la musique si nécessaire
		if not fade_in and stop_after_fade_out:
			player.stop()

		# Réinitialise l'état de fondu
		is_fading = false

		# Pour un fondu entrant, réinitialise `is_fading`
		if fade_in:
			is_fading = false

		# Exécute le callback si défini
		if callback != null:
			callback.call_deferred([])
# Joue une musique avec gestion du fondu si nécessaire
func play_music(path: String):
	var result = OS.execute("mpv", [path], [])
	print(result)



func _internal_play_music(path: String, loop: bool):
	if path != music_path:
		var audio_stream: AudioStream = load(path)
		musique_1.stop()
		musique_1.stream = audio_stream
		music_path = path
		if audio_stream is AudioStream:
			musique_1.stream.set_loop(loop)
		musique_1.volume_db = -80.0
		musique_1.play()
		fade_audio("music_1", transition_duration, true)

func _on_fade_out_complete():
	is_fading = false  # Réinitialise l'état de fondu

	# Arrête la musique en cours
	if musique_1.playing:
		musique_1.stop()

	# Vérifie s'il y a une musique en attente
	if queued_music != null and queued_music.size() > 0:
		var path: String = queued_music[0]
		var loop: bool = queued_music[1]
		queued_music = []  # Réinitialise la file d'attente
		_internal_play_music(path, loop)
	else:
		print("No queued music to play.")

func play_sound(path: String, loop: bool = false):
	if path != sound_path:
		var audio_stream: AudioStream = load(path)
		son_1.stream = audio_stream
		son_1.stream.set_loop(loop)
		son_1.play()
