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
