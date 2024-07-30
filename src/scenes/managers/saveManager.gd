extends Node

const dirPath: String = "user://saves"
const securityKey: String = "A23I5B6925UIB32P572J283I65J"

func create_default_data_template() -> Dictionary:
	var defaultData: Dictionary = {}
	
	return defaultData

func load_slot(slot: int) -> Dictionary:
	var fileName: String = "save%s.json" % slot
	var file: FileAccess = FileAccess.open(dirPath + "/" + fileName, FileAccess.READ)
	
	if file:
		var data: String = file.get_as_text()
		file.close()
		var json = JSON.new()
		var jsonResult = json.parse(data)
		if jsonResult == OK:
			var loadedData: Dictionary = jsonResult.result
			return merge_with_default(create_default_data_template(), jsonResult)
		else:
			print("[saveManager] error parsing JSON: %s" %jsonResult.error)
			return {}
		#return JSON.parse_string(data).result
	else:
		print("[saveManager] file not found: %s" %fileName)
		return {}

func merge_with_default(defaultData: Dictionary, modifiedData: Dictionary) -> Dictionary:
	for key in defaultData.keys():
		if !modifiedData.has(key):
			modifiedData[key] = defaultData[key]
	return modifiedData

func save_slot(slot, gameData: Dictionary) -> void:
	var fileName: String = "save%s.json" % slot
	var file: FileAccess = FileAccess.open(dirPath + "/" + fileName, FileAccess.READ)
	
	if file:
		var data: String = JSON.stringify(gameData)
		file.store_string(data)
		file.close()

func create_new_slot() -> int:
	var counter: int = 1
	var foundAvailableCount: bool = false
	var saveFiles: PackedStringArray = get_save_files()
	
	while !foundAvailableCount:
		var fileName: String = "save%s.json" %counter
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

func verify_and_open_save_dir() -> DirAccess:
	if !DirAccess.dir_exists_absolute(dirPath):
		DirAccess.make_dir_absolute(dirPath)
	
	return DirAccess.open(dirPath)

func get_save_files() -> PackedStringArray:
	var dir: DirAccess = verify_and_open_save_dir()
	var files: PackedStringArray = dir.get_files()
	
	if files.size() == 0:
		return files
	
	var filteredFiles: PackedStringArray = []
	for file: String in files:
		if file.ends_with(".json"):
			filteredFiles.append(file)
	
	return filteredFiles
