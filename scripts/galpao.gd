extends Node3D

const GALPAO_LENGTH: float = 20.0
const GALPAO_WIDTH: float = 8.0
const GALPAO_HEIGHT: float = 5.0
const GUILLOTINE_SEPARATION: float = 4.0

var _guillotine_left: Guillotine
var _guillotine_right: Guillotine

func _ready() -> void:
	_build_structure()
	_build_conveyor_belt()
	_build_guillotines()
	_setup_lighting()
	_build_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("action_primary"):
		_guillotine_left.drop()
		_guillotine_right.drop()

func _build_structure() -> void:
	_add_static_box("Floor",    Vector3(0, 0, 0),                                   Vector3(GALPAO_LENGTH, 0.2,  GALPAO_WIDTH), Color(0.612, 0.455, 0.259))
	_add_static_box("Ceiling",  Vector3(0, GALPAO_HEIGHT, 0),                       Vector3(GALPAO_LENGTH, 0.2,  GALPAO_WIDTH), Color(0.45,  0.4,   0.35))
	_add_static_box("WallLeft", Vector3(-GALPAO_LENGTH * 0.5, GALPAO_HEIGHT * 0.5, 0), Vector3(0.2, GALPAO_HEIGHT, GALPAO_WIDTH), Color(0.545, 0.494, 0.431))
	_add_static_box("WallRight",Vector3( GALPAO_LENGTH * 0.5, GALPAO_HEIGHT * 0.5, 0), Vector3(0.2, GALPAO_HEIGHT, GALPAO_WIDTH), Color(0.545, 0.494, 0.431))
	_add_static_box("WallBack", Vector3(0, GALPAO_HEIGHT * 0.5, -GALPAO_WIDTH * 0.5),  Vector3(GALPAO_LENGTH, GALPAO_HEIGHT, 0.2), Color(0.545, 0.494, 0.431))

func _build_hud() -> void:
	var hud := HUD.new()
	hud.name = "HUD"
	add_child(hud)

func _build_conveyor_belt() -> void:
	var belt := ConveyorBelt.new()
	belt.name = "ConveyorBeltNode"
	add_child(belt)

func _build_guillotines() -> void:
	var half_sep := GUILLOTINE_SEPARATION * 0.5

	_guillotine_left = Guillotine.new()
	_guillotine_left.name = "GuillotineLeft"
	_guillotine_left.position.x = -half_sep
	add_child(_guillotine_left)

	_guillotine_right = Guillotine.new()
	_guillotine_right.name = "GuillotineRight"
	_guillotine_right.position.x = half_sep
	add_child(_guillotine_right)

func _setup_lighting() -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "SunLight"
	sun.rotation_degrees = Vector3(-50.0, 30.0, 0.0)
	sun.light_color = Color(1.0, 0.92, 0.75)
	sun.light_energy = 1.5
	sun.shadow_enabled = true
	sun.shadow_bias = 0.05
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.name = "FillLight"
	fill.rotation_degrees = Vector3(-20.0, -150.0, 0.0)
	fill.light_color = Color(0.5, 0.6, 0.8)
	fill.light_energy = 0.4
	fill.shadow_enabled = false
	add_child(fill)

func _add_static_box(node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos

	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.9
	mi.mesh = mesh
	mi.set_surface_override_material(0, mat)
	body.add_child(mi)

	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)

	add_child(body)
