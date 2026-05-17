extends CharacterBody3D

const WALK_SPEED: float = 5.0
const GRAVITY: float = 20.0
const PITCH_CLAMP: float = PI / 2.0 - 0.05

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

var _pitch: float = 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	InputBus.look_input_changed.connect(_on_look_mouse)

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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var captured := Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if captured else Input.MOUSE_MODE_CAPTURED)

func _on_look_mouse(delta: Vector2) -> void:
	_apply_look(delta)

func _apply_look(look_delta: Vector2) -> void:
	rotate_y(-look_delta.x)
	_pitch = clamp(_pitch - look_delta.y, -PITCH_CLAMP, PITCH_CLAMP)
	camera_pivot.rotation.x = _pitch
