class_name UsedSlot
extends Control

@onready var slotCurrentVolumeLabel = $HBoxContainer/VBoxContainer/SlotCurrentVolume
@onready var slotCollectiblesLabel: Label  = $HBoxContainer/VBoxContainer/SlotCollectibles
@onready var slotPlaytimeLabel: Label  = $HBoxContainer/VBoxContainer2/SlotPlaytime
@onready var slotDeathsLabel: Label  = $HBoxContainer/VBoxContainer2/SlotDeaths

var slot: int
var slotCurrentVolume: int = 1
var slotCollectibles: int = 0
var slotPlaytime: String = "00:00:00"
var slotDeaths: int = 0


func _ready():
	slotCurrentVolumeLabel.text = str(slotCurrentVolume)
	slotCollectiblesLabel.text = str(slotCollectibles)
	slotPlaytimeLabel.text = slotPlaytime
	slotDeathsLabel.text = str(slotDeaths)
	pass

signal slotPressed(slot: int)

func _on_slot_select_pressed() -> void:
	emit_signal("slotPressed", slot)
