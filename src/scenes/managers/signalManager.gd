extends Node

# system
signal initLoadComplete(loaded: bool)

signal saving(inProgress: bool)


enum Volumes {
	volume1,
	volume2,
	volume3
}

signal chosenVolume(volume: Volumes)

func signal_choosing_volume(volume: Volumes):
	chosenVolume.emit(volume)
