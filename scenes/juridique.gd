extends Control

class_name  A_propos

func retour_presse() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/informations.tscn")
