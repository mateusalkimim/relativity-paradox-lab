# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
extends CharacterBody3D

const WALK_SPEED: float = 5.0
const GRAVITY: float = 20.0
const PITCH_CLAMP: float = PI / 2.0 - 0.05

const IDLE_ANIM := "general/Idle_A"
const WALK_ANIM := "movement/Walking_A"

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

var _pitch: float = 0.0
var _settle_until_ms: int = 0
var _body_alice: Avatar
var _body_bob: Avatar

func _ready() -> void:
	# Grupo usado pelo FrameController para o teleporte do midpoint swap
	add_to_group("player")
	_build_bodies()
	GameState.frame_changed.connect(_on_frame_changed)
	_capture_mouse()
	InputBus.look_input_changed.connect(_on_look_mouse)

# Corpos em primeira pessoa: o operador encarna a Alice (frame ALICE) ou o
# Bob (frame BOB). Cabeça/elmo ocultos para a câmera (pivot em y=1.6) não
# clipar por dentro; olhando para baixo aparecem tronco, braços e pernas.
func _build_bodies() -> void:
	_body_alice = Avatar.new()
	_body_alice.name = "BodyAlice"
	_body_alice.model_file = "Rogue.glb"
	_body_alice.hide_meshes = PackedStringArray(["Rogue_Cape", "Rogue_Head"])
	add_child(_body_alice)

	_body_bob = Avatar.new()
	_body_bob.name = "BodyBob"
	_body_bob.model_file = "Barbarian.glb"
	_body_bob.hide_meshes = PackedStringArray(["Barbarian_Head", "Barbarian_BearHat"])
	_body_bob.attach_file = "axe_1handed.gltf"
	_body_bob.attach_rotation_degrees = Vector3(0.0, 0.0, 180.0)
	_body_bob.visible = false
	add_child(_body_bob)

func _on_frame_changed(_new_frame: GameState.Frame) -> void:
	# Troca de corpo no meio da transição, em sincronia com o teleporte
	# feito pelo FrameController._midpoint_swap
	get_tree().create_timer(FrameController.TRANSITION_DURATION * 0.5) \
			.timeout.connect(_swap_body)

func _swap_body() -> void:
	var is_bob := GameState.current_frame == GameState.Frame.BOB
	_body_bob.visible = is_bob
	_body_alice.visible = not is_bob

func _capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_settle_until_ms = Time.get_ticks_msec() + 100

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	var move_vec := InputBus.get_move_vector()
	var direction := (transform.basis * Vector3(move_vec.x, 0.0, move_vec.y)).normalized()
	if direction.length() > 0.0:
		velocity.x = direction.x * WALK_SPEED
		velocity.z = direction.z * WALK_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0.0, WALK_SPEED)

	var gamepad_look := InputBus.get_look_vector(delta)
	if gamepad_look.length_squared() > 0.0:
		_apply_look(gamepad_look)

	move_and_slide()

	# Anima o corpo visível: andar/parar (play é idempotente, ver avatar.gd)
	var body := _body_bob if _body_bob.visible else _body_alice
	var moving := Vector2(velocity.x, velocity.z).length() > 0.5
	body.play(WALK_ANIM if moving else IDLE_ANIM)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			_capture_mouse()

func _on_look_mouse(delta: Vector2) -> void:
	if Time.get_ticks_msec() < _settle_until_ms:
		return
	if delta.length() > 0.5:
		return
	_apply_look(delta)

func _apply_look(look_delta: Vector2) -> void:
	rotate_y(-look_delta.x)
	_pitch = clamp(_pitch - look_delta.y, -PITCH_CLAMP, PITCH_CLAMP)
	camera_pivot.rotation.x = _pitch
