class_name UsedSlot
extends Control

@onready var slotCurrentVolumeLabel: Label = $HBoxContainer/VBoxContainer/SlotCurrentVolume
@onready var slotCollectiblesLabel: Label  = $HBoxContainer/VBoxContainer/SlotCollectibles
@onready var slotPlaytimeLabel: Label  = $HBoxContainer/VBoxContainer2/SlotPlaytime
@onready var slotDeathsLabel: Label  = $HBoxContainer/VBoxContainer2/SlotDeaths

var slot: int
var slotCurrentVolume: int = 1
var slotCollectibles: int = 0
var slotPlaytime: String = "00:00:00"
var slotDeaths: int = 0


func _ready() -> void:
	slotCurrentVolumeLabel.text = "Volume %s" % str(slotCurrentVolume)
	slotCollectiblesLabel.text = "Collectibles x%s" % str(slotCollectibles)
	slotPlaytimeLabel.text = slotPlaytime
	slotDeathsLabel.text = "Deaths x%s" % str(slotDeaths)

func update_ui() -> void:
	if slotCurrentVolumeLabel != null:
		slotCurrentVolumeLabel.text = "Volume %s" % str(slotCurrentVolume)
	if slotCollectiblesLabel != null:
		slotCollectiblesLabel.text = "Collectibles x%s" % str(slotCollectibles)
	if slotPlaytimeLabel != null:
		slotPlaytimeLabel.text = slotPlaytime
	if slotDeathsLabel != null:
		slotDeathsLabel.text = "Deaths x%s" % str(slotDeaths)


signal slotPressed(slot: int)

func _on_slot_select_pressed() -> void:
	slotPressed.emit(slot)
