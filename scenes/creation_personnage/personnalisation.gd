extends Control

@onready var fichier_a_ouvrir = $FileDialog
@onready var popup = $ecrase
@onready var info = $info
var mode = ""

func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_1.tscn")

func _on_files_selected(paths: PackedStringArray) -> void:
	for file in paths:
		if FileAccess.file_exists("res://assets/json/races_srd.json"):
			popup.text = "Le fichier " + file.get_file() + " existe déjà.\nVoulez-vous tout de même l'écraser ?"
			popup.popup()
		else:
			_launch_copy(file)



func _launch_copy(file):
	var special_path = "/" + file.get_file() # Récupère juste le nom du fichier
	special_path = mode + special_path
	var a = Utils.copy_file(file, "user://" + special_path)
	if a:
		info.text = "Votre fichier a bien été enregistré !"
	else:
		info.text = "Une erreur s'est produite lors de l'enregistrement."

func _on_races_pressed() -> void:
	mode = "races"
	fichier_a_ouvrir.popup()

func _on_classes_pressed() -> void:
	mode = "classes"
	fichier_a_ouvrir.popup()

func _on_historiques_pressed() -> void:
	mode = "historiques"
	fichier_a_ouvrir.popup()


func _on_ecrase_confirmed() -> void:
	pass # Replace with function body.
