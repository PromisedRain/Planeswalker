extends Node

var currentSlotData: Dictionary
var currentConfigData: Dictionary

const saveDirPath: String = "user://saves/"
const configFullPath: String = saveDirPath + "configFile.ini"
#const metaFullPath: String = saveDirPath + "metaData%s.json"
const metaFileNameTemplate: String = "metaData%s.json"
const metaFullPathTemplate: String = saveDirPath + metaFileNameTemplate
const configFilename: String = "configFile.ini"
const securityKey: String = "A23I5B6925UIB32P572J283I65J" #change location in the future, but who cares rn.

var configFileLoadCheck: bool = false
var metaDataLoadCheck: bool = false

func _ready() -> void:
	ensure_save_dir_exists()
	ensure_meta_data_files_exists()
	ensure_config_file_exists()

func load_before_game_data(metaDataFiles: int = 3) -> void:
	load_config_file()
	for i in metaDataFiles:
		load_meta_data(i + 1)
	
	var sucessfull: bool = get_load_check()
	if sucessfull:
		print("[saveManager] PASSED INITIAL CHECK")
	else:
		print("[saveManager] FAILED INITIAL CHECK")

#ensuring existence of files needed before choosing slots.
func ensure_save_dir_exists() -> void:
	var dir: DirAccess = verify_and_open_save_dir()
	if dir == null:
		if !DirAccess.dir_exists_absolute(saveDirPath):
			if DirAccess.make_dir_absolute(saveDirPath) != OK:
				print("[saveManager] Failed to create the save directory at: %s" % saveDirPath)
		else:
			dir = DirAccess.open(saveDirPath)
	
	#if !DirAccess.dir_exists_absolute(saveDirPath):
	#	DirAccess.make_dir_absolute(saveDirPath)
	#else:
	#	print("[saveManager] Directory verified: %s" % saveDirPath)

func ensure_config_file_exists() -> void:
	if !FileAccess.file_exists(configFullPath):
		print("[saveManager] ConfigFile not created, creating at: %s" % configFullPath)
		save_config_file(create_default_config_data_template())

func ensure_meta_data_files_exists(numFiles: int = 3) -> void:
	for i in range(numFiles):
		var metaFilePath: String = metaFullPathTemplate % str(i + 1)
		if !FileAccess.file_exists(metaFilePath):
			print("[saveManager] MetaDatafile not created, creating at: %s" % metaFilePath)
			save_meta_data(i + 1, create_default_meta_data_template())

#data templates
func create_default_game_data_template() -> Dictionary:
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

func create_default_meta_data_template() -> Dictionary:
	var defaultTemplate: Dictionary = {
		"total_slot_playtime": 0,
		"total_collectibles_collected": 0
	}
	return defaultTemplate

func create_default_config_data_template() -> Dictionary:
	var defaultTemplate: Dictionary = {
		"settings": {
			"vignette": true
		}
	}
	return defaultTemplate

#config file saving and loading
func load_config_file() -> Dictionary:
	var configFile: ConfigFile = ConfigFile.new()
	
	if !FileAccess.file_exists(configFullPath):
		print("[saveManager] Cannot open non-existent file at %s" % configFullPath)
		return create_default_config_data_template()
	
	var err = configFile.load(configFullPath)
	if err != OK:
		print("[saveManager] Error loading config file: %s" % err)
		return create_default_config_data_template()
	
	var loadedData: Dictionary = {}
	
	for section in configFile.get_sections():
		var sectionData: Dictionary = {}
		for key in configFile.get_section_keys(section):
			sectionData[key] = configFile.get_value(section, key)
		loadedData[section] = sectionData
	configFileLoadCheck = true
	return loadedData

func save_config_file(configData: Dictionary = create_default_config_data_template()) -> void:
	var config: ConfigFile = ConfigFile.new()
	
	var err = config.load(configFullPath)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		print("[saveManager] error loading config file: %s" % err)
		return
	
	for section in configData.keys():
		for key in configData[section].keys():
			config.set_value(section, key, configData[section][key])
	
	err = config.save(configFullPath)
	if err != OK:
		print("[saveManager] error saving config file: %s" % err)

#multiple slots saving and loading
func load_slot(slot: int) -> Dictionary:
	var fileName: String = "saveslot%s.json" % slot
	var fullFilePath: String = saveDirPath + fileName
	
	if !FileAccess.file_exists(fullFilePath):
		print("[saveManager] Cannot open non-existent file at %s" % fullFilePath)
		return create_default_game_data_template()
	
	var file: FileAccess = FileAccess.open_encrypted_with_pass(fullFilePath, FileAccess.READ, securityKey)
	if !file:
		print("[saveManager] Error opening the file for reading: %s" % fileName)
		return create_default_game_data_template()
	else:
		var data: String = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(data)
		
		if error != OK:
			print("[saveManager] Error message parsing JSON: %s" % json.get_error_message())
			print("[saveManager] Error line at: %s" % json.get_error_line())
			return create_default_game_data_template()
		else:
			var loadedData: Dictionary = json.result
			return merge_with_default(create_default_game_data_template(), loadedData, fileName)

func save_slot(slot, gameData: Dictionary) -> void:
	var fileName: String = "saveslot%s.json" % slot
	var fullFilePath: String = saveDirPath + fileName
	
	if !FileAccess.file_exists(fullFilePath):
		print("[saveManager] Cannot open non-existent file at: %s" % fullFilePath)
		return create_default_game_data_template()
	
	var file: FileAccess = FileAccess.open_encrypted_with_pass(fullFilePath, FileAccess.WRITE, securityKey)
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
		var fileName: String = "saveslot%s.json" % counter
		var noMatch: bool = true
		
		for file: String in saveFiles:
			if fileName == file:
				noMatch = false
		
		if !noMatch:
			foundAvailableCount = true
		else:
			counter += 1
	
	var defaultGameData: Dictionary = create_default_game_data_template()
	save_slot(counter, defaultGameData)
	return counter

#metadata for slots saving and loading
func load_meta_data(slot: int) -> Dictionary:
	var fileName: String = "metaData%s.json" % slot
	var fullFilePath: String = saveDirPath + fileName
	
	if !FileAccess.file_exists(fullFilePath):
		print("[saveManager] Cannot open non-existent file at %s" % fullFilePath)
		return create_default_meta_data_template()
	
	var file: FileAccess = FileAccess.open(fullFilePath, FileAccess.READ)
	
	if !file:
		print("[saveManager] Error opening the file for reading: %s" % fileName)
		return create_default_meta_data_template()
	else:
		var data: String = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(data)
		
		if error != OK:
			print("[saveManager] Error message parsing JSON: %s" % json.get_error_message())
			print("[saveManager] Error line at: %s" % json.get_error_line())
			return create_default_meta_data_template()
		else:
			var loadedData: Dictionary = json.data
			metaDataLoadCheck = true
			return merge_with_default(create_default_meta_data_template(), loadedData, fileName)

func save_meta_data(slot: int, metaData: Dictionary = create_default_meta_data_template()) -> void:
	var fileName: String = "metaData%s.json" % slot
	var fullFilePath: String = saveDirPath + fileName
	
	var file: FileAccess = FileAccess.open(fullFilePath, FileAccess.WRITE)
	if file:
		var data: String = JSON.stringify(metaData)
		file.store_string(data)
		file.close()
		print("[saveManager] MetaData file created/saved at: %s" % fullFilePath)
	else:
		print("[saveManager] Error opening the metadata file for writing at: %s" % fullFilePath)

#deleting
func delete_save_file(slot: int, file: String) -> void:
	var fileName: String = "%s%s.json" % [file, slot]
	var fullFilePath: String = saveDirPath + fileName
	var dir: DirAccess = verify_and_open_save_dir()
	
	if FileAccess.file_exists(fullFilePath):
		var error = dir.remove(fullFilePath)
		if error == OK:
			print("[saveManager] File sucessfully deleted: %s" % fileName)
		else:
			print("[saveManager] Error deleting file: %s" % fileName)
	else:
		print("[saveManager] Cannot open non-existent file at: %s" % fullFilePath)

func delete_config_file(path: String) -> void:
	if FileAccess.file_exists(path):
		var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		if file:
			file.close()  
			var dir = verify_and_open_save_dir()
			var error = dir.remove(configFilename)
			if error == OK:
				print("[saveManager] File successfully deleted at: %s" % path)
			else:
				print("[saveManager] Error deleting file at: %s" % path)
	else:
		print("[saveManager] Cannot open non-existent file at: %s" % path)

#helpers
func merge_with_default(defaultData: Dictionary, modifiedData: Dictionary, from: String) -> Dictionary:
	for key in defaultData.keys():
		if !modifiedData.has(key):
			modifiedData[key] = defaultData[key]
	print("[saveManager] Finished merging modified data with default data at: %s" % from)
	return modifiedData

func verify_and_open_save_dir() -> DirAccess:
	var dir: DirAccess = DirAccess.open(saveDirPath)
	if dir == null:
		if !DirAccess.dir_exists_absolute(saveDirPath):
			print("[saveManager] Failed to create a directory at: %s" % saveDirPath)
			return null
		else:
			dir = DirAccess.open(saveDirPath)
	
	if dir == null:
		print("[saveManager] Error opening directory  at: %s" % saveDirPath)
		return null
	print("[saveManager] Directory verified at: %s" % saveDirPath)
	return dir
	
	#DirAccess.make_dir_absolute(saveDirPath)
	#if !DirAccess.dir_exists_absolute(saveDirPath):
	#	DirAccess.make_dir_absolute(saveDirPath)
	#else:
	#	print("[saveManager] Directory verified: %s" % saveDirPath)
	#
	#var err = DirAccess.open(saveDirPath)
	#if !err == OK:
	#	print("[saveManager] Error opening directory %s" % DirAccess.get_open_error())
	#return err

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

#getters
func get_specific_game_data(data: String, gameData: Dictionary = currentSlotData):
	if gameData.has(data):
		return gameData[data]
	else:
		print("[saveManager] No '%s' key found in gameData" % data)
		return null #Dictionary()

func get_specific_metadata(data: String, metaData: Dictionary = create_default_meta_data_template()):
	if metaData.has(data):
		return metaData[data]
	else:
		print("[saveManager] No '%s' key found in metaData" % data)
		return null

func get_specific_config_data(data: String, configData: Dictionary = create_default_config_data_template()):
	if configData.has(data):
		return configData[data]
	else:
		print("[saveManager] No '%s' key found in configData" % data)
		return null

#func get_specific_save_data(data: String, type, saveData: Dictionary):
#	match type:
#		"gameData":
#			pass
#		_:
#			pass

func get_load_check() -> bool:
	if configFileLoadCheck && metaDataLoadCheck:
		return true
	else:
		print("[saveManager] configFileLoadCheck: %s" % configFileLoadCheck)
		print("[saveManager] metaDataLoadCheck: %s" % metaDataLoadCheck)
		return false
