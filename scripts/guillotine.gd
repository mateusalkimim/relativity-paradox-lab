extends Node3D
class_name Guillotine

enum State { READY, FALLING, DOWN, RETRACTING }

const FALL_SPEED: float = 8.0
const RETRACT_SPEED: float = 3.0
const DOWN_DURATION: float = 1.5

const FRAME_HEIGHT: float = 5.0
const BLADE_RAISED_Y: float = 4.0
const BLADE_DOWN_Y: float = 0.7

var state: State = State.READY
var _blade: MeshInstance3D
var _down_timer: float = 0.0

func _ready() -> void:
	_build_frame()
	_build_blade()

func _process(delta: float) -> void:
	match state:
		State.FALLING:
			_blade.position.y = move_toward(_blade.position.y, BLADE_DOWN_Y, FALL_SPEED * delta)
			if _blade.position.y <= BLADE_DOWN_Y:
				_blade.position.y = BLADE_DOWN_Y
				state = State.DOWN
				_down_timer = DOWN_DURATION

		State.DOWN:
			_down_timer -= delta
			if _down_timer <= 0.0:
				state = State.RETRACTING

		State.RETRACTING:
			_blade.position.y = move_toward(_blade.position.y, BLADE_RAISED_Y, RETRACT_SPEED * delta)
			if _blade.position.y >= BLADE_RAISED_Y:
				_blade.position.y = BLADE_RAISED_Y
				state = State.READY

func drop() -> void:
	if state == State.READY:
		state = State.FALLING

func reset() -> void:
	state = State.READY
	_blade.position.y = BLADE_RAISED_Y
	_down_timer = 0.0

func _build_frame() -> void:
	_add_mesh("Frame", Vector3(0.0, FRAME_HEIGHT * 0.5, 0.0), Vector3(0.3, FRAME_HEIGHT, 2.2), Color(0.5, 0.42, 0.32))

func _build_blade() -> void:
	_blade = _add_mesh("Blade", Vector3(0.0, BLADE_RAISED_Y, 0.0), Vector3(0.5, 0.4, 2.5), Color(0.29, 0.33, 0.38))

func _add_mesh(node_name: String, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	mi.mesh = mesh
	mi.set_surface_override_material(0, mat)
	add_child(mi)
	return mi
