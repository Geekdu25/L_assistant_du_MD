extends Control

@onready var fichier_a_ouvrir = $Ouverture
@onready var avertissement = $Avertissement

func _ready():
	fichier_a_ouvrir.file_mode = FileDialog.FILE_MODE_OPEN_FILES
	# Connecte le signal files_selected si ce n'est pas déjà fait dans l'éditeur
	fichier_a_ouvrir.connect("files_selected", Callable(self, "_on_files_selected"))

func _on_files_selected(paths: PackedStringArray) -> void:
	for file in paths:
		var special_path = file.get_file() # Récupère juste le nom du fichier
		Utils.copy_file(file, "user://characters/" + special_path)

func _on_file_selected(path: String) -> void:
	print("Fichier sélectionné :", path)

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/ecran_titre.tscn")

func _on_fichier_pressed() -> void:
	fichier_a_ouvrir.popup()

func acces_aux_personnages() -> void:
	if GestionDesDossiers.check_file_in_folder(".xml", "user://characters"):
		print("ok")
	else:
		avertissement.dialog_text = "Attention ! Aucun personnage n'a encore été créé."
		avertissement.popup_centered()

func _on_nouveau_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_2.tscn")


func _on_personnalisation_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/personnalisation.tscn")
