extends Control

@onready var import_button = $VBoxContainer/options_fichiers/import
@onready var category_selector = $VBoxContainer/options_fichiers/categories
@onready var delete_category_button = $VBoxContainer/options_fichiers/delete_category
@onready var play_button = $VBoxContainer/options_lecture/lecture
@onready var pause_button = $VBoxContainer/options_lecture/pause
@onready var stop_button = $VBoxContainer/options_lecture/stop
@onready var delete_song_button = $VBoxContainer/options_lecture/delete_song
@onready var tree = $VBoxContainer/Tree
@onready var new_category_button = $VBoxContainer/options_fichiers/new
@onready var notifications = $notifications

var new_category_line_edit := LineEdit.new()

func _ready():
	# Toujours désactiver les boutons au démarrage
	_update_buttons()
	# Connexions pour réagir aux changements
	category_selector.connect("item_selected", Callable(self, "_on_category_changed"))
	tree.connect("item_selected", Callable(self, "_on_music_selected"))
	new_category_button.connect("pressed", Callable(self, "_on_new_category_pressed"))

func _update_buttons():
	# Désactive l’import si aucune catégorie
	import_button.disabled = (category_selector.item_count == 0)
	# Désactive lecture/pause/stop/delete si aucune musique sélectionnée
	var music_selected = _is_music_selected()
	play_button.disabled = not music_selected
	pause_button.disabled = not music_selected
	stop_button.disabled = not music_selected
	delete_song_button.disabled = not music_selected

func _on_category_changed(index):
	_update_buttons()
	# Tu pourras ajouter ici le rafraîchissement de la liste des musiques pour la catégorie

func _on_music_selected():
	_update_buttons()

func _is_music_selected() -> bool:
	var item = tree.get_selected()
	return item != null and not item.is_root()  # selon ta logique d’arbre

func _on_new_category_pressed():
	notifications.dialog_text = "Nom de la nouvelle catégorie :"
	notifications.clear()
	new_category_line_edit.text = ""
	notifications.add_child(new_category_line_edit)
	notifications.get_ok_button().text = "Créer"
	notifications.popup_centered()
	notifications.connect("confirmed", Callable(self, "_on_new_category_confirmed"))
	new_category_line_edit.grab_focus()

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/start.tscn")
