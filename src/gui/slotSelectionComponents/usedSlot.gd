class_name UsedSlot
extends Control

@onready var slotCurrentChapterLabel = $HBoxContainer/VBoxContainer/SlotCurrentChapter
@onready var slotCollectiblesLabel = $HBoxContainer/VBoxContainer/SlotCollectibles
@onready var slotPlaytimeLabel = $HBoxContainer/VBoxContainer2/SlotPlaytime
@onready var slotDeathsLabel = $HBoxContainer/VBoxContainer2/SlotDeaths

var slotCount: int
signal slotSelectionPressed(slot: int)

func _init(_slotCurrentChapterLabel: int = 1, _slotCollectibles: int = 1, _slotPlaytime: String = "00:00:00", _slotDeaths: int = 1) -> void:
	pass
	#slotCurrentChapterLabel.text = "Chapter %s" % str(_slotCurrentChapterLabel)
	#slotCollectiblesLabel.text = "Collectibles x%s" % str(_slotCollectibles)
	#slotPlaytimeLabel.text = "%s" % _slotPlaytime
	#slotDeathsLabel.text = "Deaths x%s" % str(_slotDeaths)

func _ready() -> void:
	pass

func _on_slot_select_pressed() -> void:
	emit_signal("slotSelectionPressed", slotCount)
