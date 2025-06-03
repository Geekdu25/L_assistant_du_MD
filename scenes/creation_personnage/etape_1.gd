extends Control

@onready var fichier_a_ouvrir = $Ouverture
@onready var avertissement = $Avertissement

func _on_file_selected(path):
	print("Fichier sélectionné :", path)


func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/ecran_titre.tscn")


func _on_fichier_pressed() -> void:
	fichier_a_ouvrir.popup()



func copy_file(src_path: String, dst_path: String) -> bool:
	var src = FileAccess.open(src_path, FileAccess.READ)
	if not src:
		print("Impossible d'ouvrir le fichier source.")
		return false

	var dst = FileAccess.open(dst_path, FileAccess.WRITE)
	if not dst:
		print("Impossible de créer le fichier destination.")
		src.close()
		return false

	var buffer = src.get_buffer(src.get_length())
	dst.store_buffer(buffer)

	src.close()
	dst.close()
	return true

func acces_aux_personnages() -> void:
	if GestionDesDossiers.check_file_in_folder(".xml", "user://characters"):
		print("ok")
	else:
		avertissement.dialog_text = "Attention ! Aucun personnage n'a encore été créé."
		avertissement.popup_centered()


func _on_nouveau_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_2.tscn")

func _on_files_selected(paths:PackedStringArray):
	for p in paths:
		print(p)
	
func _on_ouverture_confirmed() -> void:
		var files = $Ouverture.get_selected_options()
		print(files)
		for file in files:
			var special_path = file.split("/")[len(file.split("/"))-1]
			copy_file(file, "user://characters/"+special_path)
