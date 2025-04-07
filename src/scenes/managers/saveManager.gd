extends Node

@onready var fileBuildManager: FileBuildManager = $FileBuildManager as FileBuildManager

var configFileLoadCheck: bool = false
var metaDataLoadCheck: bool = false
var currentSaveSlotLoadCheck: bool = false

var currentSlotData: Dictionary
var currentConfigData: Dictionary
var currentMetaData: Dictionary
var currentSaveSlot: int

var savingFlag: bool = false

const fireSuccessPrint: bool = true

const saveDirPath: String = "user://saves/"

const configFilename: String = "config.ini"
const configFullPath: String = saveDirPath + configFilename

const metaDataFilename: String = "metadata.json"
const metaDataFullPath: String = saveDirPath + metaDataFilename

#const saveDataFilename: String = "savedata%s.json"
#const saveDataFullPath: String = saveDirPath + saveDataFilename

signal filePathInvalid(filePath)

func _ready() -> void:
	filePathInvalid.connect(on_file_path_invalid)

func init() -> void:
	ensure_dir_path_exists(saveDirPath) #checking savedirectory path
	
	ensure_config_file_exists()
	currentConfigData = load_config_file()
	
	ensure_meta_data_file_exists()
	currentMetaData = load_all_meta_data()
	
	var passed: bool = get_runtime_check()
	var passedStr: String = Utils.get_check_word(passed)
	
	if passed:
		Utils.debug_print(self, "runtime load check: %s", [passedStr])
		SignalManager.initialLoadComplete.emit(passed)
	else:
		Utils.debug_print(self, "runtime load check: %s", [passedStr])
		SignalManager.initialLoadComplete.emit(passed)

func ensure_dir_path_exists(dirPath: String) -> void:
	var dir: DirAccess = verify_and_open_dir(dirPath)
	
	if dir == null:
		if !DirAccess.dir_exists_absolute(dirPath):
			var err = DirAccess.make_dir_absolute(dirPath)
			
			if err != OK:
				Utils.debug_print(self, "failed to create the save directory at: %s", [dirPath])
		else:
			dir = DirAccess.open(dirPath)

func ensure_config_file_exists() -> void:
	if !FileAccess.file_exists(configFullPath):
		Utils.debug_print(self, "configFile not created, creating at: %s", [configFullPath])
		save_config_file(create_default_config_data_template())

func ensure_meta_data_file_exists() -> void:
	if !FileAccess.file_exists(metaDataFullPath):
		Utils.debug_print(self, "metaDataFile not created, creating at: %s", [metaDataFullPath])
		save_meta_data(1 , create_meta_data_template())

func ensure_slot_file_exists(slot: int) -> bool:
	var fileName: String = "savedata%s.json" % slot
	var slotFilePath: String = saveDirPath + fileName
	
	if !FileAccess.file_exists(slotFilePath):
		filePathInvalid.emit(slotFilePath)
		return false
	else:
		Utils.debug_print(self, "slotData verified at: %s", [slotFilePath])
		return true

#data templates
func create_default_slot_data_template(slot: int) -> Dictionary:
	return {
		"save_slot_number": slot,
		"unlocked_volume_1": true,
		"unlocked_volume_2": false,
		"unlocked_volume_3": false,
		"current_volume": 0,
		"current_room": "",
		"current_spawn_global_position_x": 0,
		"current_spawn_global_position_y": 0,
	}

func create_default_meta_data_template(slot: int) -> Dictionary:
	return {
		"save_slot_number": slot,
		"total_slot_playtime": "00:00:00",
		"total_collectibles_collected": 0,
		"total_slot_deaths": 0,
		"current_volume": 0,
		"latest_volume_name": "Prologue",
	}

func create_meta_data_template() -> Dictionary:
	var template: Dictionary = {}
	
	for slot: int in range(1, 4):
		template["slot_%d" % slot] = create_default_meta_data_template(slot)
	return template

func create_default_config_data_template() -> Dictionary:
	return {
		"settings_control": {
			
		},
		"settings_video": {
			"fullscreen": false,
			"borderless": false,
			"exclusive": false,
			"v_sync": false,
			"screen_shake": false,
		},
		"settings_special": {
			"vignette": true,
			"game_timer": true,
			"debug_mode": false,
		}
	}

#multiple slots saving and loading
func load_slot(slot: int) -> Dictionary:
	var fileName: String = "savedata%s.json" % slot
	var fullFilePath: String = saveDirPath + fileName
	
	if !FileAccess.file_exists(fullFilePath):
		filePathInvalid.emit(fullFilePath)
		return create_default_slot_data_template(slot)
	
	var file: FileAccess = FileAccess.open_encrypted_with_pass(fullFilePath, FileAccess.READ, fileBuildManager.env.get("SAVE_SECURITY_KEY", "ERROR_NO_SAVE_SECURITY_KEY")) #decryption
	#var file: FileAccess = FileAccess.open(fullFilePath, FileAccess.READ) #no decryption
	
	if file == null:
		Utils.debug_print(self, "error opening file failed: %s", [FileAccess.get_open_error()])
		return create_default_slot_data_template(slot)
	elif !file:
		Utils.debug_print(self, "error opening the file for reading: %s", [fileName])
		return create_default_slot_data_template(slot)
	else:
		var data: String = file.get_as_text()
		file.close()
		var json = JSON.new()
		var err = json.parse(data)
		
		if err != OK:
			Utils.debug_print(self, "error message parsing JSON: %s", [json.get_error_message()])
			Utils.debug_print(self, "error line at: %s", [json.get_error_line()])
			return create_default_slot_data_template(slot)
		else:
			var loadedData: Dictionary = json.data
			
			currentSaveSlotLoadCheck = true
			currentSaveSlot = slot
			return merge_with_default(create_default_slot_data_template(slot), loadedData, fileName)

func save_slot(slot: int, slotData: Dictionary = currentSlotData) -> void:
	var fileName: String = "savedata%s.json" % slot
	var fullFilePath: String = saveDirPath + fileName
	var file: FileAccess = FileAccess.open_encrypted_with_pass(fullFilePath, FileAccess.WRITE, fileBuildManager.env.get("SAVE_SECURITY_KEY", "ERROR_NO_SAVE_SECURITY_KEY")) #encryption
	#var file: FileAccess = FileAccess.open(fullFilePath, FileAccess.WRITE) #no encryption
	
	if file == null:
		Utils.debug_print(self, "error opening file failed: %s", [FileAccess.get_open_error()])
	elif !file:
		Utils.debug_print(self, "error opening the slotData file for writing at: %s", [fullFilePath])
	else:
		var data: String = JSON.stringify(slotData, "\t")
		
		file.store_string(data)
		file.close()
		SignalManager.saving.emit(false)
		Utils.debug_print(self, "slotData file created and saved at: %s", [fullFilePath])

#config file saving and loading
func load_config_file() -> Dictionary:
	var configFile: ConfigFile = ConfigFile.new()
	
	if !FileAccess.file_exists(configFullPath):
		filePathInvalid.emit(configFullPath)
		return create_default_config_data_template()
	
	var err = configFile.load(configFullPath)
	
	if err != OK:
		Utils.debug_print(self, "error loading config file: %s", [err])
		return create_default_config_data_template()
	
	var loadedData: Dictionary = {}
	
	for section in configFile.get_sections():
		var sectionData: Dictionary = {}
		
		if configFile.has_section(section):
			for key in configFile.get_section_keys(section):
				sectionData[key] = configFile.get_value(section, key)
			loadedData[section] = sectionData
	#currentConfigData = loadedData
	configFileLoadCheck = true
	return loadedData

func save_config_file(configData: Dictionary = create_default_config_data_template()) -> void:
	var config: ConfigFile = ConfigFile.new()
	var err = config.load(configFullPath)
	
	if err != OK && err != ERR_FILE_NOT_FOUND:
		Utils.debug_print(self, "error loading configFile at: %s", [err])
		return
	
	for section in configData.keys():
		for key in configData[section].keys():
			config.set_value(section, key, configData[section][key])
	
	err = config.save(configFullPath)
	if err != OK:
		Utils.debug_print(self, "error saving configFile at: %s", [err])

#metadata for slots saving and loading
func load_meta_data(slot: int) -> Dictionary:
	var fullFilePath: String = metaDataFullPath
	
	if !FileAccess.file_exists(fullFilePath):
		filePathInvalid.emit(fullFilePath)
		return create_default_meta_data_template(slot)
	
	var file: FileAccess = FileAccess.open(fullFilePath, FileAccess.READ)
	
	if !file:
		Utils.debug_print(self, "error opening the file for reading at: %s", [fullFilePath])
		return create_meta_data_template()
	else:
		var data: String = file.get_as_text()
		file.close()
		var json = JSON.new()
		var err = json.parse(data)
		
		if err != OK:
			Utils.debug_print(self, "error message parsing JSON: %s", [json.get_error_message()])
			Utils.debug_print(self, "error line at: %s", [json.get_error_line()])
			return create_default_meta_data_template(slot)
		else:
			var loadedData: Dictionary = json.data
			
			if "slot_%d" % slot in loadedData:
				metaDataLoadCheck = true
				return merge_with_default(create_default_meta_data_template(slot), loadedData["slot_%d" % slot], fullFilePath)
			else:
				return create_default_meta_data_template(slot)

func load_all_meta_data() -> Dictionary:
	var fullFilePath: String = metaDataFullPath
	
	if !FileAccess.file_exists(fullFilePath):
		filePathInvalid.emit(fullFilePath)
		return create_meta_data_template()
	
	var file: FileAccess = FileAccess.open(fullFilePath, FileAccess.READ)
	
	if !file:
		Utils.debug_print(self, "error opening the file for reading at: %s", [metaDataFilename])
		return create_meta_data_template()
	else:
		var data: String = file.get_as_text()
		file.close()
		var json = JSON.new()
		var err = json.parse(data)
		
		if err != OK:
			Utils.debug_print(self, "error message parsing JSON: %s", [json.get_error_message()])
			Utils.debug_print(self, "error line at: %s", [json.get_error_line()])
			return create_meta_data_template()
		else:
			metaDataLoadCheck = true
			return json.data

func save_meta_data(slot: int, _metaData: Dictionary) -> void:
	var fullFilePath: String = metaDataFullPath
	var metaData: Dictionary
	
	if !FileAccess.file_exists(fullFilePath):
		metaData = create_meta_data_template()
	else:
		var file: FileAccess = FileAccess.open(fullFilePath, FileAccess.READ)
		
		if !file:
			Utils.debug_print(self, "error opening the metaData file for reading at: %s", [fullFilePath])
			metaData = create_meta_data_template()
		else:
			var data: String = file.get_as_text()
			file.close()
			var json = JSON.new()
			var err = json.parse(data)
			
			if err != OK:
				metaData = create_meta_data_template()
			else:
				metaData = json.data
	
	metaData["slot_%d" % slot] = _metaData
	
	var _file: FileAccess = FileAccess.open(fullFilePath, FileAccess.WRITE)
	
	if !_file:
		Utils.debug_print(self, "error opening the metaData file for writing at: %s", [fullFilePath])
	else:
		var data: String = JSON.stringify(_metaData, "\t")
		_file.store_string(data)
		_file.close()
		Utils.debug_print(self, "metadata file created and saved at: %s", [fullFilePath])

#saving everything
func save_current_meta_data(_metaData: Dictionary = currentMetaData) -> void:
	var slotMetaData: Dictionary = get_all_slot_meta_data(currentSaveSlot) 
	_metaData["slot_%d" % currentSaveSlot] = slotMetaData
	save_meta_data(currentSaveSlot, _metaData)

func save_current_slot_data(slot: int = currentSaveSlot, _slotData: Dictionary = currentSlotData) -> void:
	save_slot(slot, _slotData)

func save_game(icon: bool = false) -> void:
	savingFlag = true
	save_config_file(currentConfigData)
	save_current_meta_data()
	save_current_slot_data()
	
	if icon:
		UiManager.create_save_icon_notification()
	else:
		savingFlag = false
	
	Utils.debug_print(self, "saved game")

#deleting
func delete_save_file(file: String, slot: int) -> void:
	var fileName: String = "%s%s.json" % [file, slot]
	var fullFilePath: String = saveDirPath + fileName
	var dir: DirAccess = verify_and_open_dir(saveDirPath)
	
	if !FileAccess.file_exists(fullFilePath):
		filePathInvalid.emit(fullFilePath)
	else:
		var err = dir.remove(fullFilePath)
		
		if err != OK:
			Utils.debug_print(self, "error deleting file at: %s", [fileName])
		else:
			Utils.debug_print(self, "file successfully deleted at: %s", [fileName])

func delete_slot_meta_data(slot: int, _metaData: Dictionary = currentMetaData) -> void:
	_metaData["slot_%d" % slot] = create_default_meta_data_template(slot)
	save_current_meta_data(_metaData)
	Utils.debug_print(self, "deleted and replaced a section of the metaData file, slot replaced: slot_%d", [slot])

func delete_config_file(path: String = configFullPath) -> void:
	if !FileAccess.file_exists(path):
		filePathInvalid.emit(path)
	else:
		var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		
		if file:
			file.close()  
			var dir = verify_and_open_dir(saveDirPath)
			var err = dir.remove(configFilename)
			
			if err != OK:
				Utils.debug_print(self, "error deleting file at: %s", [path])
			else:
				Utils.debug_print(self, "file successfully deleted at: %s", [path])

#helpers
func merge_with_default(defaultData: Dictionary, modifiedData: Dictionary, from: String, _fireSucess: bool = fireSuccessPrint) -> Dictionary:
	for key in defaultData.keys():
		if !modifiedData.has(key):
			modifiedData[key] = defaultData[key]
	
	Utils.debug_print(self, "finished merging modified data with default data at: %s", [from])
	return modifiedData

func verify_and_open_dir(dirPath: String, _fireSucess: bool = fireSuccessPrint) -> DirAccess:
	var dir: DirAccess = DirAccess.open(dirPath)
	
	if dir == null:
		if !DirAccess.dir_exists_absolute(dirPath):
			Utils.debug_print(self, "failed to create a directory at: %s", [dirPath])
			return null
		else:
			dir = DirAccess.open(dirPath)
	
	if dir == null:
		Utils.debug_print(self, "error opening directory at: %s", [dirPath])
		return null
	
	Utils.debug_print(self, "directory verified at: %s", [dirPath])
	return dir

func get_save_dir_json_files() -> PackedStringArray:
	var dir: DirAccess = verify_and_open_dir(saveDirPath)
	var files: PackedStringArray = dir.get_files()
	
	if files.size() == 0:
		Utils.debug_print(self, "empty savefile directory")
		return files
	
	var filteredFiles: PackedStringArray = []
	
	for file: String in files:
		if file.ends_with(".json"):
			filteredFiles.append(file)
	return filteredFiles

func get_config_data(section: String, key: String, _configData: Dictionary = currentConfigData) -> Variant:
	if !_configData.has(section):
		Utils.debug_print(self, "no '%s' section found in configData", [section])
		return null
	else:
		var sectionData = _configData[section]
		if !sectionData.has(key):
			Utils.debug_print(self, "no '%s' key found in configData section", [key])
			return null
		else:
			return sectionData[key]

func set_config_data(section: String, key: String, value: Variant, _configData: Dictionary = currentConfigData) -> void:
	if !_configData.has(section):
		_configData[section] = {}
		Utils.debug_print(self, "no '%s' section found in configData, creating one", [section])
	
	_configData[section][key] = value
	save_config_file(_configData)
	Utils.debug_print(self, "set '%s/%s' to '%s' in configData", [section, key, value])

func get_slot_data(key: String, slotData: Dictionary = currentSlotData) -> Variant:
	if slotData.has(key):
		return slotData[key]
	else:
		Utils.debug_print(self, "no '%s' key found in slotData", [key])
		return null

func set_slot_data(key: String, value: Variant, _slotData: Dictionary = currentSlotData) -> void:
	if !_slotData.has(key):
		_slotData[key] = {}
		Utils.debug_print(self, "no '%s' key found in slotData, creating one", [key])
	
	_slotData[key] = value
	
	var slot: int = get_slot_for_setting_slot_data()
	save_slot(slot, _slotData)
	Utils.debug_print(self, "set '%s' to '%s' in savedData", [key, value])

func get_slot_for_setting_slot_data() -> int:
	var _slotData: Dictionary = currentSlotData
	var slot: int = _slotData["save_slot_number"]
	
	if slot == null:
		return 1
	return slot

func get_all_slot_meta_data(slot: int, _metaData: Dictionary = currentMetaData) -> Dictionary:
	var _slot: String = "slot_%d" % slot
	
	if !_metaData.has(_slot):
		Utils.debug_print(self, "no '%s' slot found in metaData", [_slot])
		return Dictionary()
	else:
		return _metaData[_slot]

func set_specific_slot_meta_data(slot: int, key: String, value: Variant, _metaData: Dictionary = currentMetaData) -> void:
	var _slot: String = "slot_%d" % slot
	
	if!_metaData.has(_slot):
		Utils.debug_print(self, "no '%s' slot found in metaData", [_slot])
		return
	
	if !_metaData[_slot].has(key):
		Utils.debug_print(self, "no '%s' key found in slot_%d metaData, making key", [key, slot])
		_metaData[_slot] = {}
	
	_metaData[_slot][key] = value
	
	save_meta_data(slot, _metaData)
	Utils.debug_print(self, "set '%s' to '%s' in slot_%d metaData", [key, value, slot])

func get_runtime_check() -> bool:
	var loadCheck: bool
	var currentDataCheck: bool
	
	if configFileLoadCheck && metaDataLoadCheck:
		loadCheck = true
	else:
		Utils.debug_print(self, "configFileLoadCheck: %s", [configFileLoadCheck])
		Utils.debug_print(self, "metaDataLoadCheck: %s", [metaDataLoadCheck])
		loadCheck = false
	
	if currentConfigData != null:
		currentDataCheck = true
	else:
		Utils.debug_print(self, "currentConfigData: %s", [currentConfigData])
		currentDataCheck = false
	return loadCheck && currentDataCheck

func get_available_slot_count() -> int:
	var counter: int = 1
	var foundAvailableCount: bool = false
	var saveFiles: PackedStringArray = get_save_dir_json_files()
	
	while !foundAvailableCount:
		var fileName: String = "savedata%s.json" % counter 
		var noMatch: bool = false 
		
		for file: String in saveFiles:
			if !fileName == file && file.begins_with("savedata"):
				noMatch = true
				break
		
		if noMatch:
			foundAvailableCount = true
		else:
			counter += 1
	
	#var defaultGameData: Dictionary = create_default_slot_data_template()
	#save_slot(counter, defaultGameData)
	return counter

func on_file_path_invalid(filePath) -> void:
	Utils.debug_print(self, "cannot open non-existent file at: %s", [filePath])
