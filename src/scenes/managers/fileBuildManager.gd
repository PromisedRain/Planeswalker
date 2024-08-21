class_name FileBuildManager
extends Node
# manager responsible for building required gamefiles, examples being .env and metadata files

var env: Dictionary = {}

const saveDirPath: String = "user://saves/"
const volumesDirPath: String = "user://volumes/"

const volumesMetaDataFilename: String = "volumes.json"
const volumesMetaDataFullPath: String = volumesDirPath + volumesMetaDataFilename

var currentVolumeMetaData: Dictionary

signal filePathInvalid(filePath: String)
signal instanceInvalid(instance: Node)

func _ready() -> void:
	filePathInvalid.connect(on_file_path_invalid)
	instanceInvalid.connect(on_instance_invalid)
	
	ensure_env_file_exists(get_current_env_path())
	load_env_file(get_current_env_path())
	
	SaveManager.ensure_dir_path_exists("user://volumes")

func ensure_env_file_exists(filePath: String) -> bool:
	if !FileAccess.file_exists(filePath):
		Utils.debug_print(self, ".env file not created, creating at: %s", [filePath])
		build_env_file(filePath)
		return false
	return true

func load_env_file(filePath: String) -> bool:
	if !FileAccess.file_exists(filePath):
		filePathInvalid.emit(filePath)
		return false
	
	var file: FileAccess = FileAccess.open(filePath, FileAccess.READ)
	
	if !file:
		Utils.debug_print(self, "error opening the file for reading at: %s", [filePath])
		return false
	else:
		var data = file.get_as_text()
		file.close()
		return load_env_data(data)

func load_env_data(envData: String) -> bool:
	var lines: PackedStringArray = envData.split("\n", true)
	
	for line in lines:
		if line.find("=") != -1 && !line.begins_with("#"):
			var keyValue = line.split("=", false)
			
			if keyValue.size() == 2:
				var key: String = keyValue[0].strip_edges()
				var value: String = keyValue[1].strip_edges()
				env[key] = value
	return true

func build_env_file(filePath: String) -> bool:
	var file: FileAccess = FileAccess.open(filePath, FileAccess.WRITE)
	
	if !file:
		filePathInvalid.emit(filePath)
		return false
	else:
		file.store_line("# default .env configuration")
		file.store_line("")
		file.store_line("SAVE_SECURITY_KEY=%s" % Utils.generate_uuid().to_upper())
		file.close()
		return true

func save_room_data_to_json(ID: int, roomParent: Node2D) -> void:
	var roomData: Dictionary = {}
	
	for room: Room in roomParent.get_children():
		if room is Room && is_instance_valid(room):
			var roomPosition: Vector2 = room.global_position
			var roomBounds: Rect2 = room.get_global_room_bounds()
			
			roomData[room.roomName] = {
				"global_position_x": roomPosition.x,
				"global_position_y": roomPosition.y,
				"global_bounds": {
					"position_x": roomBounds.position.x,
					"position_y": roomBounds.position.y,
					"size_x": roomBounds.size.x,
					"size_y": roomBounds.size.y
				}
			}
		else:
			instanceInvalid.emit(room)
	
	build_volumes_meta_data(ID, roomData)

func build_volumes_meta_data(ID: int, roomData: Dictionary) -> void:
	var fullFilePath: String = volumesMetaDataFullPath
	var volumeData: Dictionary = read_volumes_meta_data(fullFilePath)
	
	volumeData["volume_id_%d" % ID] = roomData
	
	var file: FileAccess = FileAccess.open(fullFilePath, FileAccess.WRITE)
	
	if !file:
		Utils.debug_print(self, "error opening volume_id_%d metadata file for reading at: %s", [ID, fullFilePath])
	else:
		var data: String = JSON.stringify(volumeData, "\t")
		file.store_string(data)
		file.close()
		Utils.debug_print(self, "volume_id_%d inside volumes.json file created and saved at: %s", [ID, fullFilePath])

func get_volume_room_data(ID: int) -> Dictionary:
	var fullFilePath: String = volumesMetaDataFullPath
	
	var volumeData: Dictionary = read_volumes_meta_data(fullFilePath)
	
	var volumeKey: String = "volume_id_%d" % ID
	if volumeData.has(volumeKey):
		return volumeData[volumeKey]
	else:
		Utils.debug_print(self, "Volume ID %d not found in the volumes metadata.", [ID])
		return {}

func read_volumes_meta_data(fullFilePath: String) -> Dictionary:
	var volumeData: Dictionary
	
	if !FileAccess.file_exists(fullFilePath):
		volumeData = create_volumes_file_template()
	else:
		var file: FileAccess = FileAccess.open(fullFilePath, FileAccess.READ)
		
		if !file:
			Utils.debug_print(self, "error opening the volumes metadata file for reading at: %s", [fullFilePath])
			volumeData = create_volumes_file_template()
		else:
			var data: String = file.get_as_text()
			file.close()
			var json: JSON = JSON.new()
			var err = json.parse(data)
			
			if err != OK:
				volumeData = create_volumes_file_template()
			else:
				volumeData = json.data
	return volumeData


func create_volumes_file_template() -> Dictionary:
	var template: Dictionary = {}
	
	for id: int in range(Utils.minVolumesCurrently, Utils.maxVolumesCurrently):
		template["volume_id_%d" % id] = {}
	return template

func get_current_env_path() -> String:
	if OS.has_feature("release") && !OS.has_feature("debug"):
		return saveDirPath
	return ".env"

func get_volumes_meta_data_file_exists() -> bool:
	if !FileAccess.file_exists(volumesMetaDataFullPath):
		return false
	return true

func on_file_path_invalid(filePath: String) -> void:
	Utils.debug_print(self, "cannot open non-existent file at: %s", [filePath])

func on_instance_invalid(instance: Node) -> void:
	Utils.debug_print(self, "instance '%s' is invalid or null", [instance])
