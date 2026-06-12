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

enum ToraPhase { RIDING, EXITING, SPAWNING }

# 1. Constantes
const TRANSITION_DURATION: float = 2.0
# Spawn: traseira da tora (centro − 2u) ainda sobre a correia (início em -10).
# Sincronizado com Esteira.FEED_X (calha) e galpao.LOG_RESET_X.
const LOG_RESET_X: float = -7.5
# Gatilho de saída: centro de gravidade próximo do rolete final (x=10) —
# ponto em que a tora começaria a tombar de verdade
const EXIT_TRIGGER_X: float = 9.6
const LOG_Y: float = 0.75
# Queda da calha: tora nasce no vão do V (Esteira._build_hopper)
const SPAWN_Y: float = 2.35
const SPAWN_DURATION: float = 0.6
# Mergulho no poço de descarga (Esteira.PIT_X) — entre o fim da esteira
# (x=10.3) e a mureta da fachada aberta (face interna em x=12.54)
const PIT_X: float = 11.35
const EXIT_DURATION: float = 0.9
const EXIT_DIVE_Y: float = -1.6
const EXIT_SINK_Y: float = -2.4
const EXIT_TILT_RAD: float = -1.1
# Desaceleração suave do mundo ao fim da passada em BOB
const BOB_STOP_DURATION: float = 1.0
# Bob acompanha a tora 2.4u atrás do centro (0.4u atrás da face traseira da
# madeira). Offset maior deixava o alvo do spawn atrás do clamp e o Bob
# ficava parado esperando a tora abrir vantagem antes de andar.
const BOB_FOLLOW_OFFSET: float = -2.4
const BOB_MIN_X: float = -9.9
# Pés do Bob no topo da correia (sarrafos a 0.515; diferença imperceptível)
const BOB_BELT_Y: float = 0.5
# Pico de opacidade do tint azulado durante a transição (efeito sutil, README Semana 3)
const TINT_PEAK_ALPHA: float = 0.22
const TINT_COLOR: Color = Color(0.45, 0.65, 1.0)

# 5. Variáveis privadas
var _world: Node3D
var _tora: Tora
var _guillotine_left: Guillotine
var _guillotine_right: Guillotine
var _bob_avatar: Avatar
var _alice_avatar: Avatar
var _tint: ColorRect
var _phase: ToraPhase = ToraPhase.RIDING
var _lifecycle_tween: Tween
var _bob_pass_done: bool = false
var _bob_stop_tween: Tween

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
		# Tora só viaja em RIDING; EXITING/SPAWNING são animados por tween
		if _phase == ToraPhase.RIDING:
			_tora.position.x += step
			_follow_tora_with_bob()
			if _tora.position.x > EXIT_TRIGGER_X:
				_begin_exit()
	else:
		# No referencial de Bob a tora está em repouso; é o mundo que passa por ela
		_world.position.x -= step * GameState.bob_pass_speed_scale
		if not _bob_pass_done and _tora.position.x - _world.position.x > EXIT_TRIGGER_X:
			_finish_bob_pass()

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
func setup(world: Node3D, tora: Tora, guillotine_left: Guillotine,
		guillotine_right: Guillotine, bob_avatar: Avatar, alice_avatar: Avatar) -> void:
	_world = world
	_tora = tora
	_guillotine_left = guillotine_left
	_guillotine_right = guillotine_right
	_bob_avatar = bob_avatar
	_alice_avatar = alice_avatar
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
# A queda quase instantânea (Guillotine.FALL_SPEED) garante que o corte sai
# onde o operador mirou; a tora anda < 0.1u entre o gatilho e o cruzamento.
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

# Saída (ALICE): a tora passa do rolete final, tomba e mergulha no poço de
# descarga; o interior escuro do poço mascara o despawn. Depois, respawn.
func _begin_exit() -> void:
	_phase = ToraPhase.EXITING
	_lifecycle_tween = create_tween().set_parallel(true)
	_lifecycle_tween.tween_property(_tora, "position:x", PIT_X, EXIT_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_lifecycle_tween.tween_property(_tora, "position:y", EXIT_DIVE_Y, EXIT_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_lifecycle_tween.tween_property(_tora, "rotation:z", EXIT_TILT_RAD, EXIT_DURATION) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	# Bob segue até o fim da correia enquanto a tora tomba à frente dele
	_lifecycle_tween.tween_property(_bob_avatar, "position:x", PIT_X - 0.45,
			EXIT_DURATION + 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	# Afunda o resto do comprimento abaixo do chão antes do respawn;
	# Bob mergulha no poço logo atrás dela (paralelo dentro deste passo)
	_lifecycle_tween.chain().tween_property(_tora, "position:y", EXIT_SINK_Y, 0.25)
	_lifecycle_tween.tween_property(_bob_avatar, "position:y", EXIT_DIVE_Y, 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_lifecycle_tween.tween_property(_bob_avatar, "rotation:z", EXIT_TILT_RAD, 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_lifecycle_tween.chain().tween_interval(0.2)
	_lifecycle_tween.chain().tween_callback(_spawn_tora)

# Entrada (ALICE): tora nova cai da calha de alimentação com leve bounce.
# Bob cai junto com ela (em BOB_MIN_X, o clamp de início da correia).
func _spawn_tora() -> void:
	_phase = ToraPhase.SPAWNING
	_restore_tora()
	_tora.rotation.z = 0.0
	_tora.position = Vector3(LOG_RESET_X, SPAWN_Y, 0.0)
	_bob_avatar.rotation.z = 0.0
	_bob_avatar.position = Vector3(BOB_MIN_X, SPAWN_Y, 0.0)
	_lifecycle_tween = create_tween().set_parallel(true)
	_lifecycle_tween.tween_property(_tora, "position:y", LOG_Y, SPAWN_DURATION) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_lifecycle_tween.tween_property(_bob_avatar, "position:y", BOB_BELT_Y, SPAWN_DURATION) \
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_lifecycle_tween.chain().tween_callback(func() -> void: _phase = ToraPhase.RIDING)

# Fim da passada em BOB: o galpão já passou inteiro pela tora. Em vez de
# teleportar de volta, o mundo desacelera suavemente e para — a repetição
# fica a cargo do operador (LB volta a Alice, B reseta, slow-mo no replay).
# O fator vive no GameState: a Esteira lê para os sarrafos pararem junto.
func _finish_bob_pass() -> void:
	_bob_pass_done = true
	_bob_stop_tween = create_tween() \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_bob_stop_tween.tween_property(GameState, "bob_pass_speed_scale", 0.0, BOB_STOP_DURATION)

func _reset_bob_pass() -> void:
	# Mata o tween de desaceleração se ainda estiver rodando — sem isso ele
	# continuaria após a troca de frame e re-zeraria o fator em ALICE
	if _bob_stop_tween != null and _bob_stop_tween.is_valid():
		_bob_stop_tween.kill()
	_bob_pass_done = false
	GameState.bob_pass_speed_scale = 1.0

# Bob caminha na correia atrás da tora: mesma velocidade (está em repouso no
# referencial dela) e mesma contração — em ALICE ele é um corpo em movimento.
func _follow_tora_with_bob() -> void:
	_bob_avatar.position.x = clampf(_tora.position.x + BOB_FOLLOW_OFFSET,
			BOB_MIN_X, EXIT_TRIGGER_X)
	_bob_avatar.scale.x = _tora.scale.x

# Garante a tora assentada na correia (usado na troca de referencial,
# que pode interromper animações de entrada/saída no meio). Bob vem junto:
# o snap pode pegá-lo no meio do mergulho no poço.
func _snap_tora_to_belt() -> void:
	_phase = ToraPhase.RIDING
	_tora.rotation.z = 0.0
	_tora.position.x = clampf(_tora.position.x, LOG_RESET_X, EXIT_TRIGGER_X)
	_tora.position.y = LOG_Y
	_bob_avatar.rotation.z = 0.0
	_bob_avatar.position.y = BOB_BELT_Y
	_follow_tora_with_bob()

func _reset_scene() -> void:
	GameState.reset_session()
	get_tree().reload_current_scene()

func _on_frame_changed(new_frame: GameState.Frame) -> void:
	GameState.is_transitioning = true
	# Animação de ciclo da tora não sobrevive à troca de referencial
	if _lifecycle_tween != null and _lifecycle_tween.is_valid():
		_lifecycle_tween.kill()
	_snap_tora_to_belt()

	var inv_gamma := 1.0 / GameState.get_gamma()
	var is_bob := new_frame == GameState.Frame.BOB
	var tora_target := 1.0 if is_bob else inv_gamma
	var world_target := inv_gamma if is_bob else 1.0

	var tween := create_tween().set_parallel(true) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(_tora, "scale:x", tora_target, TRANSITION_DURATION)
	tween.tween_property(_world, "scale:x", world_target, TRANSITION_DURATION)
	tween.tween_method(_set_tint_progress, 0.0, 1.0, TRANSITION_DURATION)

	if not is_bob:
		# Recentra o palco: em BOB o mundo deslizou; preservamos a posição
		# relativa tora↔galpão trazendo ambos de volta junto com a transição.
		# Se a passada já tinha terminado, recomeça com tora nova na entrada.
		var rel := _tora.position.x - _world.position.x
		var tora_target_x := rel if rel <= EXIT_TRIGGER_X else LOG_RESET_X
		if rel > EXIT_TRIGGER_X:
			_restore_tora()
		tween.tween_property(_world, "position:x", 0.0, TRANSITION_DURATION)
		tween.tween_property(_tora, "position:x", tora_target_x, TRANSITION_DURATION)
		_reset_bob_pass()

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
