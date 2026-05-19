extends Node3D
class_name ConveyorBelt

const BELT_LENGTH: float = 14.0
const BELT_HALF: float = BELT_LENGTH * 0.5

# Visual speed scale: decouples beta [0,1] from visible movement speed.
# At beta=0.9, log crosses the belt in ~3 seconds. Pure visual choice.
const VISUAL_C: float = 5.0

const LOG_PROPER_LENGTH: float = 4.0
const LOG_RESET_X: float = -9.0
const LOG_EXIT_X: float = 9.0
const LOG_Y: float = 0.85

const STRIPE_COUNT: int = 5

var _log: MeshInstance3D
var _stripes: Array[MeshInstance3D] = []

func _ready() -> void:
	_build_belt()
	_build_stripes()
	_build_log()

func _process(delta: float) -> void:
	var speed := GameState.belt_beta * VISUAL_C

	_log.position.x += speed * delta
	if _log.position.x > LOG_EXIT_X:
		_log.position.x = LOG_RESET_X

	for stripe in _stripes:
		stripe.position.x += speed * delta
		if stripe.position.x > BELT_HALF:
			stripe.position.x -= BELT_LENGTH

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("speed_up"):
		GameState.increase_speed()
	elif event.is_action_pressed("speed_down"):
		GameState.decrease_speed()

func _build_belt() -> void:
	_add_mesh("BeltSurface", Vector3(0.0, 0.55, 0.0),       Vector3(BELT_LENGTH, 0.1, 1.4), Color(0.18, 0.18, 0.18))
	_add_mesh("SupportLeft",  Vector3(-BELT_HALF, 0.3, 0.0), Vector3(0.15, 0.5, 1.4),       Color(0.35, 0.35, 0.38))
	_add_mesh("SupportRight", Vector3( BELT_HALF, 0.3, 0.0), Vector3(0.15, 0.5, 1.4),       Color(0.35, 0.35, 0.38))

func _build_stripes() -> void:
	var spacing := BELT_LENGTH / STRIPE_COUNT
	for i in STRIPE_COUNT:
		var x := -BELT_HALF + spacing * (i + 0.5)
		var stripe := _add_mesh("Stripe%d" % i, Vector3(x, 0.615, 0.0), Vector3(0.25, 0.03, 1.35), Color(0.28, 0.28, 0.28))
		_stripes.append(stripe)

func _build_log() -> void:
	_log = _add_mesh("Log", Vector3(LOG_RESET_X, LOG_Y, 0.0), Vector3(LOG_PROPER_LENGTH, 0.5, 0.5), Color(0.545, 0.357, 0.169))

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
