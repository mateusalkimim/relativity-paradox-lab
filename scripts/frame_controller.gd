# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
extends Node
class_name FrameController

# Coração do projeto (README §7.1-7.2, §10.6): aplica a contração de Lorentz
# conforme o referencial ativo e anima a transição ALICE ⇄ BOB.
#
# ALICE (repouso do galpão): tora contraída (scale.x = 1/γ), mundo normal, tora se move.
# BOB (repouso da tora): tora em L₀, mundo contraído (scale.x = 1/γ), mundo se move.
#
# "Mundo" = MovingWorld (galpão + guilhotinas + esteira), montado por galpao.gd.
# A tora vive FORA desse grupo justamente para não herdar a escala do mundo.

# 1. Constantes
const TRANSITION_DURATION: float = 2.0
# Faixa de viagem relativa tora↔mundo — mesmos limites da esteira de 20u
const LOG_RESET_X: float = -9.0
const LOG_EXIT_X: float = 9.0
# Pico de opacidade do tint azulado durante a transição (efeito sutil, README Semana 3)
const TINT_PEAK_ALPHA: float = 0.22
const TINT_COLOR: Color = Color(0.45, 0.65, 1.0)

# 5. Variáveis privadas
var _world: Node3D
var _tora: Tora
var _guillotine_left: Guillotine
var _guillotine_right: Guillotine
var _tint: ColorRect

# 7. Funções built-in

func _ready() -> void:
	GameState.frame_changed.connect(_on_frame_changed)
	GameState.velocity_changed.connect(_on_velocity_changed)
	_build_transition_tint()
	_apply_instant_state()

func _process(delta: float) -> void:
	# Movimento congelado durante a transição: a "reconfiguração do mundo"
	# fica legível para a audiência (teatro > simulação, README §10.4)
	if GameState.is_transitioning:
		return
	var step := GameState.belt_beta * Esteira.VISUAL_C * delta
	if GameState.current_frame == GameState.Frame.ALICE:
		_tora.position.x += step
		if _tora.position.x > LOG_EXIT_X:
			_tora.position.x = LOG_RESET_X
			_restore_tora()
	else:
		# No referencial de Bob a tora está em repouso; é o mundo que passa por ela
		_world.position.x -= step
		if _tora.position.x - _world.position.x > LOG_EXIT_X:
			_world.position.x = _tora.position.x - LOG_RESET_X
			_restore_tora()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_frame"):
		GameState.toggle_frame()
	elif event.is_action_pressed("action_primary"):
		_drop_guillotines()
	elif event.is_action_pressed("slow_motion"):
		GameState.toggle_slow_motion()
	elif event.is_action_pressed("reset_scene"):
		_reset_scene()

# 8. Funções públicas

# Chamado por galpao.gd antes de add_child — injeta as referências da cena
func setup(world: Node3D, tora: Tora, guillotine_left: Guillotine, guillotine_right: Guillotine) -> void:
	_world = world
	_tora = tora
	_guillotine_left = guillotine_left
	_guillotine_right = guillotine_right
	_guillotine_left.blade_crossed_cut_plane.connect(_check_cut.bind(_guillotine_left))
	_guillotine_right.blade_crossed_cut_plane.connect(_check_cut.bind(_guillotine_right))
	_tora.was_cut.connect(func() -> void: GameState.set_tora_cut(true))

# 9. Funções privadas

func _drop_guillotines() -> void:
	if GameState.is_transitioning:
		return
	if GameState.current_frame == GameState.Frame.ALICE:
		# Referencial da esteira: descida simultânea por definição
		_guillotine_left.drop()
		_guillotine_right.drop()
		return
	# Referencial de Bob: a simultaneidade se desfaz. A guilhotina da frente
	# (direita, no sentido do movimento) desce primeiro; a esquerda desce
	# Δt' = γ·L₀·v/c² depois (Alencar et al. 2023, §III.A).
	# VISUAL_C converte tempo físico (c=1) para a escala visual do show.
	_guillotine_right.drop()
	var separation := _guillotine_right.position.x - _guillotine_left.position.x
	var offset := LorentzTransform.simultaneity_offset(separation, GameState.belt_beta) \
		/ Esteira.VISUAL_C
	get_tree().create_timer(offset).timeout.connect(_guillotine_left.drop)

# A lâmina cruzou o topo da tora: corta se houver madeira sob ela.
# global_position absorve a escala/posição do MovingWorld automaticamente.
func _check_cut(guillotine: Guillotine) -> void:
	if _tora.is_cut:
		return
	var blade_x := guillotine.global_position.x
	var tora_x := _tora.global_position.x
	# Meia-extensão no espaço global: L₀/2 × escala efetiva da tora (1/γ em ALICE)
	var half_extent := _tora.rest_length * 0.5 * _tora.global_transform.basis.x.length()
	if absf(blade_x - tora_x) < half_extent:
		var local_x := _tora.to_local(Vector3(blade_x, _tora.global_position.y, _tora.global_position.z)).x
		_tora.cut_at(local_x)

func _restore_tora() -> void:
	if _tora.is_cut:
		_tora.restore()
		GameState.set_tora_cut(false)

func _reset_scene() -> void:
	GameState.reset_session()
	get_tree().reload_current_scene()

func _on_frame_changed(new_frame: GameState.Frame) -> void:
	GameState.is_transitioning = true
	var inv_gamma := 1.0 / GameState.get_gamma()
	var is_bob := new_frame == GameState.Frame.BOB
	var tora_target := 1.0 if is_bob else inv_gamma
	var world_target := inv_gamma if is_bob else 1.0

	var tween := create_tween().set_parallel(true) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_tora, "scale:x", tora_target, TRANSITION_DURATION)
	tween.tween_property(_world, "scale:x", world_target, TRANSITION_DURATION)
	tween.tween_method(_set_tint_progress, 0.0, 1.0, TRANSITION_DURATION)
	tween.chain().tween_callback(func() -> void: GameState.is_transitioning = false)

func _on_velocity_changed(_beta: float) -> void:
	# Velocidade só muda fora de transição (GameState bloqueia); aplica direto
	_apply_instant_state()

func _apply_instant_state() -> void:
	if GameState.current_frame == GameState.Frame.ALICE:
		_tora.set_lorentz_scale(GameState.get_gamma())
		_world.scale.x = 1.0
	else:
		_tora.reset_lorentz_scale()
		_world.scale.x = 1.0 / GameState.get_gamma()

# Pulso de tint: sobe e desce em seno — alpha 0 nas pontas, pico no meio da transição
func _set_tint_progress(t: float) -> void:
	_tint.modulate.a = sin(t * PI) * TINT_PEAK_ALPHA

func _build_transition_tint() -> void:
	var layer := CanvasLayer.new()
	layer.name = "TransitionTint"
	layer.layer = 5
	_tint = ColorRect.new()
	_tint.color = TINT_COLOR
	_tint.modulate.a = 0.0
	_tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tint.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(_tint)
	add_child(layer)
