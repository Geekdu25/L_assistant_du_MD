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
@onready var new_category_line_edit = $notifications/LineEdit

func _ready():
	_populate_categories()
	# Toujours désactiver les boutons au démarrage
	_update_buttons()
	# Connexions pour réagir aux changements
	category_selector.connect("item_selected", Callable(self, "_on_category_changed"))
	tree.connect("item_selected", Callable(self, "_on_music_selected"))
	new_category_button.connect("pressed", Callable(self, "_on_new_category_pressed"))
	delete_category_button.connect("pressed", Callable(self, "_on_delete_category_pressed"))

func _update_buttons():
	# Désactive l’import si aucune catégorie
	import_button.disabled = (category_selector.item_count == 0)
	# Désactive lecture/pause/stop/delete si aucune musique sélectionnée
	var music_selected = _is_music_selected()
	play_button.disabled = not music_selected
	pause_button.disabled = not music_selected
	stop_button.disabled = not music_selected
	delete_song_button.disabled = not music_selected

func _on_delete_category_pressed():
	var idx = category_selector.get_selected_id()
	if idx == -1 or category_selector.item_count == 0:
		return # Rien à supprimer
	var category_name = category_selector.get_item_text(idx)
	# Masque le champ de saisie si besoin
	new_category_line_edit.hide()
	notifications.dialog_text = "Voulez-vous vraiment supprimer la catégorie '%s' ?\nToutes les musiques qu'elle contient seront supprimées." % category_name
	notifications.get_ok_button().text = "Supprimer"
	# Déconnecte les anciens signaux
	if notifications.is_connected("confirmed", Callable(self, "_on_confirm_delete_category")):
		notifications.disconnect("confirmed", Callable(self, "_on_confirm_delete_category"))
	if notifications.is_connected("confirmed", Callable(self, "_on_error_acknowledged")):
		notifications.disconnect("confirmed", Callable(self, "_on_error_acknowledged"))
	if notifications.is_connected("confirmed", Callable(self, "_on_new_category_confirmed")):
		notifications.disconnect("confirmed", Callable(self, "_on_new_category_confirmed"))
	notifications.connect("confirmed", Callable(self, "_on_confirm_delete_category"), CONNECT_ONE_SHOT)
	notifications.popup_centered()

func _on_confirm_delete_category():
	var idx = category_selector.get_selected_id()
	if idx == -1:
		return
	var category_name = category_selector.get_item_text(idx)
	var base_path = "user://musics"
	var category_path = base_path + "/" + category_name
	var dir = DirAccess.open(base_path)
	if dir and dir.dir_exists(category_name):
		_delete_directory_recursive(category_path)
	# Retire de l'UI
	category_selector.remove_item(idx)
	# Sélectionne le premier item restant, ou rien si plus rien
	if category_selector.item_count > 0:
		category_selector.select(0)
	_update_buttons()

func _delete_directory_recursive(path: String):
	# Ne supprime jamais le dossier racine des musiques
	if path == "user://musics":
		return
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name == "." or file_name == "..":
				file_name = dir.get_next()
				continue
			var file_path = path + "/" + file_name
			if dir.current_is_dir():
				_delete_directory_recursive(file_path)
			else:
				DirAccess.remove_absolute(file_path)
			file_name = dir.get_next()
		dir.list_dir_end()
	DirAccess.remove_absolute(path)

func _on_category_changed(index):
	_update_buttons()
	# Tu pourras ajouter ici le rafraîchissement de la liste des musiques pour la catégorie

func _populate_categories():
	category_selector.clear()
	var base_path = "user://musics"
	var dir = DirAccess.open(base_path)
	if dir:
		dir.list_dir_begin()
		var name = dir.get_next()
		while name != "":
			if dir.current_is_dir() and name != "." and name != "..":
				category_selector.add_item(name)
			name = dir.get_next()
		dir.list_dir_end()

func _on_music_selected():
	_update_buttons()

func _is_music_selected() -> bool:
	var item = tree.get_selected()
	return item != null and not item.is_root()  # selon ta logique d’arbre

func _on_new_category_pressed():
	new_category_line_edit.text = ""
	new_category_line_edit.show()
	notifications.dialog_text = ""
	notifications.get_ok_button().text = "Créer"
	# Déconnecte d'abord tout
	if notifications.is_connected("confirmed", Callable(self, "_on_new_category_confirmed")):
		notifications.disconnect("confirmed", Callable(self, "_on_new_category_confirmed"))
	if notifications.is_connected("confirmed", Callable(self, "_on_error_acknowledged")):
		notifications.disconnect("confirmed", Callable(self, "_on_error_acknowledged"))
	notifications.connect("confirmed", Callable(self, "_on_new_category_confirmed"), CONNECT_ONE_SHOT)
	notifications.popup_centered()
	new_category_line_edit.grab_focus()

func show_error_dialog(message: String):
	new_category_line_edit.hide()
	notifications.dialog_text = message
	notifications.get_ok_button().text = "OK"
	# Déconnecte tout avant de connecter
	notifications.disconnect("confirmed", Callable(self, "_on_new_category_confirmed")) if notifications.is_connected("confirmed", Callable(self, "_on_new_category_confirmed")) else null
	notifications.disconnect("confirmed", Callable(self, "_on_error_acknowledged")) if notifications.is_connected("confirmed", Callable(self, "_on_error_acknowledged")) else null
	notifications.connect("confirmed", Callable(self, "_on_error_acknowledged"), CONNECT_ONE_SHOT)
	notifications.popup_centered()

func _on_error_acknowledged():
	# Réaffiche le champ de saisie si besoin, ou rien si le dialogue se ferme
	notifications.dialog_text = ""
	new_category_line_edit.show()
	new_category_line_edit.text = ""
	notifications.get_ok_button().text = "Créer"
	# Le bouton OK referme la popup

func _on_new_category_confirmed():
	var name = new_category_line_edit.text.strip_edges()
	if name == "":
		show_error_dialog("Le nom ne peut pas être vide.")
		notifications.popup_centered()
		return

	# Vérification et création du dossier racine musics si besoin
	var base_path = "user://musics"
	var dir = DirAccess.open(base_path)
	if not dir:
		DirAccess.make_dir_recursive_absolute(base_path)
		dir = DirAccess.open(base_path)
	var category_path = base_path + "/" + name

	# Vérification d'existence
	if dir.dir_exists(name):
		show_error_dialog("Cette catégorie existe déjà.")
		notifications.popup_centered()
		return

	# Création du dossier
	var err = dir.make_dir(name)
	if err != OK:
		show_error_dialog("Erreur à la création du dossier !")
		notifications.popup_centered()
		return

	# Ajout à l'UI
	category_selector.add_item(name)
	category_selector.select(category_selector.item_count - 1)
	_update_buttons()

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/start.tscn")
