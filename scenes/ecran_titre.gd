extends Control

class_name Ecran_titre

func a_propos_presse() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/a_propos.tscn")


func _on_reset_pressed() -> void:
	GestionDesDossiers.warning(get_tree().current_scene)


func _on_button_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/creation_personnage/etape_1.tscn")
