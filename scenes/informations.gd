extends Control


func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/ecran_titre.tscn")


func _on_a_propos_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/a_propos.tscn")


func _on_juridique_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/juridique.tscn")
