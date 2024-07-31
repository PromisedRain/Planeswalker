extends Node

const dirPath: String = "user://saves/"
const securityKey: String = "A23I5B6925UIB32P572J283I65J"

func create_default_data_template() -> Dictionary:
	var defaultTemplate: Dictionary = {
		"current_volume": 1,
		"current_level": 1,
		"unlocked_volumes": [
			true,
			false,
			false
		]
	}
	return defaultTemplate

func load_slot(slot: int) -> Dictionary:
	var fileName: String = "save%s.json" % slot
	if !FileAccess.file_exists(dirPath + fileName):
		print("[saveManager] Cannot open non-existent file at %s" % dirPath + fileName)
		return create_default_data_template()
	
	var file: FileAccess = FileAccess.open_encrypted_with_pass(dirPath + fileName, FileAccess.READ, securityKey)
	
	if file:
		var data: String = file.get_as_text()
		file.close()
		var json = JSON.new()
		var jsonResult = json.parse(data)
		if jsonResult == OK:
			var loadedData: Dictionary = jsonResult.result
			return merge_with_default(create_default_data_template(), jsonResult)
		else:
			print("[saveManager] Error parsing JSON: %s" % jsonResult.error)
			return create_default_data_template()
		#return JSON.parse_string(data).result
	else:
		print("[saveManager] Error opening the file for reading: %s" %fileName)
		return create_default_data_template()

func save_slot(slot, gameData: Dictionary) -> void:
	var fileName: String = "save%s.json" % slot
	if !FileAccess.file_exists(dirPath + fileName):
		print("[saveManager] Cannot open non-existent file at %s" % dirPath + fileName)
		return create_default_data_template()
	
	var file: FileAccess = FileAccess.open_encrypted_with_pass(dirPath + fileName, FileAccess.WRITE, securityKey)
	
	if file:
		var data: String = JSON.stringify(gameData)
		file.store_string(data)
		file.close()
	else:
		print("[saveManager] Error opening the file for writing: %s" % fileName)

func create_new_slot() -> int:
	var counter: int = 1
	var foundAvailableCount: bool = false
	var saveFiles: PackedStringArray = get_save_files()
	
	while !foundAvailableCount:
		var fileName: String = "save%s.json" % counter
		var noMatch: bool = true
		
		for file: String in saveFiles:
			if fileName == file:
				noMatch = false
		
		if !noMatch:
			foundAvailableCount = true
		else:
			counter += 1
	
	var defaultGameData: Dictionary = create_default_data_template()
	save_slot(counter, defaultGameData)
	return counter

func merge_with_default(defaultData: Dictionary, modifiedData: Dictionary) -> Dictionary:
	for key in defaultData.keys():
		if !modifiedData.has(key):
			modifiedData[key] = defaultData[key]
	print("[saveManager] Finished merging modified data with default data")
	return modifiedData

func verify_and_open_save_dir() -> DirAccess:
	if !DirAccess.dir_exists_absolute(dirPath):
		DirAccess.make_dir_absolute(dirPath)
	else:
		print("[saveManager] Directory verified: %s" % dirPath)
	
	return DirAccess.open(dirPath)

func get_save_files() -> PackedStringArray:
	var dir: DirAccess = verify_and_open_save_dir()
	var files: PackedStringArray = dir.get_files()
	
	if files.size() == 0:
		print("[saveManager] Empty savefile directory")
		return files
	
	var filteredFiles: PackedStringArray = []
	for file: String in files:
		if file.ends_with(".json"):
			filteredFiles.append(file)
	
	return filteredFiles

#func get_unlocked_volumes(gameData: Dictionary) -> Array:
#	if gameData.has("unlocked_volumes"):
#		return gameData["unlocked_volumes"]
#	else:
#		print("[saveManager] No 'unlocked_volumes' key in gameData")
#		return []

func get_specific_game_data(gameData, data):
	if gameData.has(data):
		return gameData[data]
	else:
		print("[saveManager] No '%s' key found in gameData" % data)
		return
