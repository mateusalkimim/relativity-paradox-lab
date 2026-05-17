extends Node

signal look_input_changed(delta: Vector2)

const GAMEPAD_LOOK_SENSITIVITY: float = 3.0
const MOUSE_SENSITIVITY: float = 0.002
const GAMEPAD_DEADZONE: float = 0.15

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_input_changed.emit(event.relative * MOUSE_SENSITIVITY)

func get_move_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_back")

func get_look_vector(delta: float) -> Vector2:
	var x := Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var y := Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if absf(x) < GAMEPAD_DEADZONE:
		x = 0.0
	if absf(y) < GAMEPAD_DEADZONE:
		y = 0.0
	return Vector2(x, y) * GAMEPAD_LOOK_SENSITIVITY * delta
