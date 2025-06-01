extends Control


func _on_retour_pressed() -> void:
	get_node("/root/Ecran_principal").change_page("res://scenes/ecran_titre.tscn")
