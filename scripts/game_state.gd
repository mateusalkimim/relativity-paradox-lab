extends Node

enum Frame { ALICE, BOB }

signal frame_changed(new_frame)
signal velocity_changed(new_beta)

const BELT_BETA_STEP: float = 0.1
const BELT_BETA_MAX: float = 0.99
const BELT_BETA_MIN: float = 0.0

var current_frame: Frame = Frame.ALICE
var belt_beta: float = 0.05
var is_transitioning: bool = false
var slow_motion_active: bool = false
var overlay_active: bool = false

func toggle_frame() -> void:
	if is_transitioning:
		return
	current_frame = Frame.BOB if current_frame == Frame.ALICE else Frame.ALICE
	frame_changed.emit(current_frame)

func increase_speed() -> void:
	belt_beta = minf(belt_beta + BELT_BETA_STEP, BELT_BETA_MAX)
	velocity_changed.emit(belt_beta)

func decrease_speed() -> void:
	belt_beta = maxf(belt_beta - BELT_BETA_STEP, BELT_BETA_MIN)
	velocity_changed.emit(belt_beta)

func get_gamma() -> float:
	var b := clampf(belt_beta, 0.0, 0.99)
	return 1.0 / sqrt(1.0 - b * b)

func get_beta() -> float:
	return belt_beta
