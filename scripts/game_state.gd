# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
extends Node

enum Frame { ALICE, BOB }

signal frame_changed(new_frame)
signal velocity_changed(new_beta)
signal slow_motion_changed(active)
signal tora_cut_changed(is_cut)

const BELT_BETA_STEP: float = 0.1
const BELT_BETA_MAX: float = 0.99
const BELT_BETA_MIN: float = 0.0
const BELT_BETA_DEFAULT: float = 0.05
const SLOW_MOTION_SCALE: float = 0.25

var current_frame: Frame = Frame.ALICE
var belt_beta: float = BELT_BETA_DEFAULT
var is_transitioning: bool = false
var slow_motion_active: bool = false
var overlay_active: bool = false
var tora_is_cut: bool = false

func toggle_frame() -> void:
	if is_transitioning:
		return
	current_frame = Frame.BOB if current_frame == Frame.ALICE else Frame.ALICE
	frame_changed.emit(current_frame)

func increase_speed() -> void:
	if is_transitioning:
		return
	belt_beta = minf(belt_beta + BELT_BETA_STEP, BELT_BETA_MAX)
	velocity_changed.emit(belt_beta)

func decrease_speed() -> void:
	if is_transitioning:
		return
	belt_beta = maxf(belt_beta - BELT_BETA_STEP, BELT_BETA_MIN)
	velocity_changed.emit(belt_beta)

func toggle_slow_motion() -> void:
	slow_motion_active = not slow_motion_active
	# Engine.time_scale desacelera tudo: movimento, tweens, timers — inclusive
	# o offset de simultaneidade das guilhotinas, o que é desejável no Ato 3
	Engine.time_scale = SLOW_MOTION_SCALE if slow_motion_active else 1.0
	slow_motion_changed.emit(slow_motion_active)

func set_tora_cut(value: bool) -> void:
	if tora_is_cut == value:
		return
	tora_is_cut = value
	tora_cut_changed.emit(value)

# Restaura o estado global antes de recarregar a cena (Botão B).
# Sem isso, frame/β persistiriam no autoload e divergiriam da cena recém-criada.
func reset_session() -> void:
	current_frame = Frame.ALICE
	belt_beta = BELT_BETA_DEFAULT
	is_transitioning = false
	slow_motion_active = false
	overlay_active = false
	tora_is_cut = false
	Engine.time_scale = 1.0

func get_gamma() -> float:
	var b := clampf(belt_beta, 0.0, 0.99)
	return 1.0 / sqrt(1.0 - b * b)

func get_beta() -> float:
	return belt_beta
