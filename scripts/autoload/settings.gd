extends Node
## Player preferences, persisted to user://settings.cfg (separate from saves).

signal changed

const PATH := "user://settings.cfg"
const DIFFICULTY_NAMES := ["Chilled", "Normal", "Hardcore"]
const UI_SCALES := [0.85, 1.0, 1.15, 1.3]

var difficulty: int = 1
var ui_scale_idx: int = 1
var weekly_popup: bool = false
var confirm_next_week: bool = false
var reduce_effects: bool = false
var autosave: bool = true


func _ready() -> void:
	load_settings()
	apply()


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		_default_scale_for_device()
		return
	difficulty = cfg.get_value("game", "difficulty", difficulty)
	ui_scale_idx = cfg.get_value("display", "ui_scale_idx", ui_scale_idx)
	weekly_popup = cfg.get_value("game", "weekly_popup", weekly_popup)
	confirm_next_week = cfg.get_value("game", "confirm_next_week", confirm_next_week)
	reduce_effects = cfg.get_value("display", "reduce_effects", reduce_effects)
	autosave = cfg.get_value("game", "autosave", autosave)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("game", "difficulty", difficulty)
	cfg.set_value("display", "ui_scale_idx", ui_scale_idx)
	cfg.set_value("game", "weekly_popup", weekly_popup)
	cfg.set_value("game", "confirm_next_week", confirm_next_week)
	cfg.set_value("display", "reduce_effects", reduce_effects)
	cfg.set_value("game", "autosave", autosave)
	cfg.save(PATH)
	apply()
	changed.emit()


## Phones get slightly bigger UI by default so buttons stay thumb-friendly.
func _default_scale_for_device() -> void:
	if OS.has_feature("mobile"):
		ui_scale_idx = 2


func apply() -> void:
	var tree := get_tree()
	if tree and tree.root:
		tree.root.content_scale_factor = UI_SCALES[clampi(ui_scale_idx, 0, UI_SCALES.size() - 1)]


func income_mult() -> float:
	return [1.25, 1.0, 0.85][clampi(difficulty, 0, 2)]


func decay_mult() -> float:
	return [0.7, 1.0, 1.3][clampi(difficulty, 0, 2)]
