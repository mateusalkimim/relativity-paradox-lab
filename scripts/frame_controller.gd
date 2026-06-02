# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
extends Node
class_name FrameController

const TRANSITION_DURATION: float = 1.5
# L₀/2 — metade da separação própria entre guilhotinas (Alencar et al., Seção III.A)
const GUILLOTINE_HALF_SEP: float = 2.0

var _esteira: Esteira
var _tora: Tora
var _guillotine_left: Guillotine
var _guillotine_right: Guillotine
var _vignette: ColorRect
var _tween: Tween

func init(esteira: Esteira, g_left: Guillotine, g_right: Guillotine) -> void:
	_esteira = esteira
	_tora = esteira.get_tora()
	_guillotine_left = g_left
	_guillotine_right = g_right
	_build_vignette()
	GameState.frame_changed.connect(_on_frame_changed)
	GameState.velocity_changed.connect(_on_velocity_changed)
	_apply_frame_state()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_frame"):
		GameState.toggle_frame()

func _on_frame_changed(new_frame: GameState.Frame) -> void:
	GameState.is_transitioning = true
	var gamma := GameState.get_gamma()

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)

	if new_frame == GameState.Frame.ALICE:
		# Mundo volta à escala normal; tora contrai
		_tween.tween_property(_esteira, "scale:x", 1.0, TRANSITION_DURATION)
		_tween.tween_property(_tora, "scale:x", 1.0 / gamma, TRANSITION_DURATION)
		_tween.tween_property(_guillotine_left, "scale:x", 1.0, TRANSITION_DURATION)
		_tween.tween_property(_guillotine_right, "scale:x", 1.0, TRANSITION_DURATION)
		_tween.tween_property(_guillotine_left, "position:x", -GUILLOTINE_HALF_SEP, TRANSITION_DURATION)
		_tween.tween_property(_guillotine_right, "position:x", GUILLOTINE_HALF_SEP, TRANSITION_DURATION)
	else:
		# Tora em repouso (escala local γ cancela pai 1/γ → escala mundo = 1); mundo contrai
		_tween.tween_property(_esteira, "scale:x", 1.0 / gamma, TRANSITION_DURATION)
		_tween.tween_property(_tora, "scale:x", gamma, TRANSITION_DURATION)
		_tween.tween_property(_guillotine_left, "scale:x", 1.0 / gamma, TRANSITION_DURATION)
		_tween.tween_property(_guillotine_right, "scale:x", 1.0 / gamma, TRANSITION_DURATION)
		_tween.tween_property(_guillotine_left, "position:x", -GUILLOTINE_HALF_SEP / gamma, TRANSITION_DURATION)
		_tween.tween_property(_guillotine_right, "position:x", GUILLOTINE_HALF_SEP / gamma, TRANSITION_DURATION)

	# Libera o bloqueio de inputs quando todos os tweens paralelos terminam
	_tween.tween_callback(func(): GameState.is_transitioning = false).set_delay(TRANSITION_DURATION)

	# Vinheta: pulso sequencial num tween separado
	var vt := create_tween()
	vt.tween_property(_vignette, "modulate:a", 0.6, TRANSITION_DURATION * 0.35)
	vt.tween_property(_vignette, "modulate:a", 0.0, TRANSITION_DURATION * 0.65)

func _on_velocity_changed(_beta: float) -> void:
	if not GameState.is_transitioning:
		_apply_frame_state()

# Aplica o estado visual correto sem animação (início do jogo e mudanças de velocidade)
func _apply_frame_state() -> void:
	var gamma := GameState.get_gamma()
	if GameState.current_frame == GameState.Frame.ALICE:
		_esteira.scale.x = 1.0
		_tora.scale.x = 1.0 / gamma
		_guillotine_left.scale.x = 1.0
		_guillotine_right.scale.x = 1.0
		_guillotine_left.position.x = -GUILLOTINE_HALF_SEP
		_guillotine_right.position.x = GUILLOTINE_HALF_SEP
	else:
		_esteira.scale.x = 1.0 / gamma
		_tora.scale.x = gamma
		_guillotine_left.scale.x = 1.0 / gamma
		_guillotine_right.scale.x = 1.0 / gamma
		_guillotine_left.position.x = -GUILLOTINE_HALF_SEP / gamma
		_guillotine_right.position.x = GUILLOTINE_HALF_SEP / gamma

func _build_vignette() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 5
	add_child(canvas)
	_vignette = ColorRect.new()
	_vignette.color = Color(0.05, 0.02, 0.15, 1.0)
	_vignette.modulate.a = 0.0
	_vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(_vignette)
