extends Control

class_name Ecran_titre

func a_propos_presse() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/informations.tscn")


func _on_reset_pressed() -> void:
	GestionDesDossiers.warning(get_tree().current_scene)

func _on_start_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/start.tscn")
