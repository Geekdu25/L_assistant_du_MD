extends Node

@onready var mpv_manquant = $mpv_manquant
var _missing_folders := []
const REQUIRED_FOLDERS := [
	"user://saves",
	"user://characters",
	"user://musics",
	"user://campaigns",
	"user://races",
	"user://classes",
	"user://historiques"
]

# Supprime la variable globale de popup_instance

func setup_script_for_mpv():
	# Lis le contenu du script dans res://
	var src = FileAccess.open("res://scripts/mpv_send.sh", FileAccess.READ)
	var script_text = src.get_as_text()
	src.close()

	# Écris-le dans user://
	var dst_path = "user://.dm_mpv_send.sh"
	var dst = FileAccess.open(dst_path, FileAccess.WRITE)
	dst.store_string(script_text)
	dst.close()

	# Rends-le exécutable (nécessite un système POSIX)
	OS.execute("chmod", ["+x", ProjectSettings.globalize_path(dst_path)], [], false)

func verifie_dossiers(parent):
	_missing_folders.clear()
	var missing_folders = []
	for folder_path in REQUIRED_FOLDERS:
		if not DirAccess.dir_exists_absolute(folder_path):
			_missing_folders.append(folder_path)
			missing_folders.append(folder_path)
	if missing_folders.size() > 0:
		_show_popup(missing_folders, parent)
	else:
		proceed_to_next_scene(parent)

func ensure_mpv():
	var result = OS.execute("which", ["mpv"], [])
	result += OS.execute("which", ["socat"])
	if result != 0:
		print("Attention ! mpv et/ou socat est manquant ! Installez-le(s) avec : sudo apt install mpv et sudo apt install socat")
		mpv_manquant.popup_centered()
		Utils.mpv = false
	else:
		Utils.mpv = true

func check_file_in_folder(file:String, folder:String):
	var dir = DirAccess.open(folder)
	var i = 0
	if dir:
		for subfile in dir.get_files():
			if subfile.ends_with(file):
				i += 1
		return i > 0
	return false

func _show_popup(missing_folders, parent):
	# On instancie une nouvelle popup à chaque affichage
	var popup_instance = preload("res://scenes/interface_utilisateur/popup.tscn").instantiate()
	var popup_label = popup_instance.get_node("popup/Label")
	var popup_panel = popup_instance.get_node("popup")
	var accept_button = popup_instance.get_node("popup/AcceptButton")
	var refuse_button = popup_instance.get_node("popup/RefuseButton")

	# Prépare le texte
	var cleaned_folders = ""
	for f in missing_folders:
		cleaned_folders += f.replace("user://", "") + "\n"
	popup_label.text = "Des dossiers nécessaires sont manquants :\n" + cleaned_folders + "\nIls vont être créés."

	parent.add_child(popup_instance)
	popup_panel.visible = true
	popup_panel.set_focus_mode(Control.FOCUS_ALL)
	accept_button.grab_focus()

	# Connexion des signaux, suppression propre
	accept_button.pressed.connect(func():
		for folder_path in _missing_folders:
			DirAccess.make_dir_recursive_absolute(folder_path)
		popup_instance.queue_free()
		proceed_to_next_scene(parent)
	)

	refuse_button.pressed.connect(func():
		popup_instance.queue_free()
		get_tree().quit()
	)

func proceed_to_next_scene(parent):
	# Ici, ajoute le code pour continuer l'initialisation ou changer de page.
	# Par exemple :
	pass
	# ... autre logique si besoin

# Exemple d'utilisation d'une popup d'avertissement réutilisable
func warning(parent):
	var popup_instance = preload("res://scenes/interface_utilisateur/popup.tscn").instantiate()
	var popup_label = popup_instance.get_node("popup/Label")
	var popup_panel = popup_instance.get_node("popup")
	var accept_button = popup_instance.get_node("popup/AcceptButton")
	var refuse_button = popup_instance.get_node("popup/RefuseButton")

	popup_label.text = "Toutes les données de sauvegarde vont être effacées.\nÊtes-vous sûr de vouloir le faire ? (Une fois effacées, les données ne peuvent plus être restaurées.)"

	parent.add_child(popup_instance)
	popup_panel.visible = true
	popup_panel.set_focus_mode(Control.FOCUS_ALL)
	accept_button.grab_focus()

	accept_button.pressed.connect(func():
		delete_all_saves()
		popup_instance.queue_free()
		get_tree().quit()
	)

	refuse_button.pressed.connect(func():
		popup_instance.queue_free()
		# Tu peux ici rappeler proceed_to_next_scene ou autre action
	)

func delete_dir_recursive(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		for file_name in dir.get_files():
			var file_path = path.path_join(file_name)
			dir.remove(file_path)
		for subdir_name in dir.get_directories():
			var subdir_path = path.path_join(subdir_name)
			delete_dir_recursive(subdir_path)
			dir.remove(subdir_path)
	# On ne supprime pas 'user://' lui-même

func delete_all_saves():
	var dir = DirAccess.open("user://")
	if dir:
		for subdir_name in dir.get_directories():
			var subdir_path = "user://".path_join(subdir_name)
			delete_dir_recursive(subdir_path)
			dir.remove(subdir_path)
