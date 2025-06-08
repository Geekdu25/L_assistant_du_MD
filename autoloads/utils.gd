extends Node

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

func calcul_default_level(level:int):
	if 5 <= level and level < 9:
		return 3
	elif 9 <= level and level < 13:
		return 4
	elif 13 <= level and level < 17:
		return 5
	elif 17 <= level:
		return 6
	return 2

func clear_vbox(vbox: VBoxContainer) -> void:
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()

func charger_tout(quoi:String) -> Array:
	var result = []
	# Charger races SRD
	if FileAccess.file_exists("res://assets/json/"+quoi+"_srd.json"):
		var data = FileAccess.get_file_as_string("res://assets/json/"+quoi+"_srd.json")
		result += JSON.parse_string(data)
	# Charger races personnalisées
	var dir = DirAccess.open("user://"+quoi)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".json"):
				var path = "user://"+quoi+"/" + file_name
				if FileAccess.file_exists(path):
					var data2 = FileAccess.get_file_as_string(path)
					result += JSON.parse_string(data2)
			file_name = dir.get_next()
		dir.list_dir_end()
	return result

func genere_nombre_aleatoire(nombre):
	pass

func delete_maximum(liste):
	if len(liste) < 1:
		return null
	var max = liste[0]
	var i = 0
	var indice = 0
	for nombre in liste:
		if nombre > max:
			max = nombre
			indice = i
		i += 1
	return [liste, max, indice]

func genere_caracteristiques():
	var nombres_generes = []
	var current_de = []
	var save = []
	var nombre_final = 0
	for loop in range(6):
		current_de = []
		nombre_final = 0
		for loop2 in range(4):
			current_de.append(genere_nombre_aleatoire(6))
		save = current_de
		var n = 0
		for loop2 in range(3):
			delete_maximum(current_de)
	return nombres_generes
