extends Node

# system
@warning_ignore("unused_signal")
signal initialLoadComplete(loaded: bool)

@warning_ignore("unused_signal")
signal saving(inProgress: bool)




signal chosenVolume(volume: LevelManager.Volumes)

func signal_choosing_volume(volume: LevelManager.Volumes):
	chosenVolume.emit(volume)
