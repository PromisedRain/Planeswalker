extends Node

# system
@warning_ignore("unused_signal")
signal initialLoadComplete(loaded: bool)

@warning_ignore("unused_signal")
signal saving(inProgress: bool)


enum Volumes {
	volume1,
	volume2,
	volume3
}

signal chosenVolume(volume: Volumes)

func signal_choosing_volume(volume: Volumes):
	chosenVolume.emit(volume)
