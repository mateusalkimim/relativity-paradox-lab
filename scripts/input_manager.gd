extends Node

signal look_input_changed(delta: Vector2)

const GAMEPAD_LOOK_SENSITIVITY: float = 150.0
const MOUSE_SENSITIVITY: float = 0.002

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_input_changed.emit(event.relative * MOUSE_SENSITIVITY)

func get_move_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_back")

func get_look_vector(delta: float) -> Vector2:
	var x := Input.get_axis("look_left", "look_right")
	var y := Input.get_axis("look_up", "look_down")
	return Vector2(x, y) * GAMEPAD_LOOK_SENSITIVITY * delta
