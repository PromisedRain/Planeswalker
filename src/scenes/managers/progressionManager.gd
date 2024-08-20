extends Node

var totalCollectiblesCollected: int = 0
var totalDeaths: int = 0

enum ProgressionCollectibles {
	placeholder,
	witheredRose
}

#TODO implement check unqiue collectable status and return false or true for spawning it or not.

func check_unique_collectable_status(_roomName: String, _object) -> bool:
	return true
