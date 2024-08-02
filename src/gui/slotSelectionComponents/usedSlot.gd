class_name UsedSlot
extends Control

@onready var slotCurrentChapterLabel: Label = $HBoxContainer/VBoxContainer/SlotCurrentChapter
@onready var slotCollectiblesLabel: Label  = $HBoxContainer/VBoxContainer/SlotCollectibles
@onready var slotPlaytimeLabel: Label  = $HBoxContainer/VBoxContainer2/SlotPlaytime
@onready var slotDeathsLabel: Label  = $HBoxContainer/VBoxContainer2/SlotDeaths

var slot: int
var slotCurrentChapter: int = 1
var slotCollectibles: int = 0
var slotPlaytime: String = "00:00:00"
var slotDeaths: int = 0


func _ready():
	slotCurrentChapterLabel.text = str(slotCurrentChapter)
	slotCollectiblesLabel.text = str(slotCollectibles)
	slotPlaytimeLabel.text = slotPlaytime
	slotDeathsLabel.text = str(slotDeaths)

signal slotPressed(slot: int)

func _on_slot_select_pressed() -> void:
	emit_signal("slotPressed", slot)
