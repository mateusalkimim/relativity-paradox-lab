extends Node3D

const GALPAO_LENGTH: float = 20.0
const GALPAO_WIDTH: float = 8.0
const GALPAO_HEIGHT: float = 5.0
const GUILLOTINE_SEPARATION: float = 4.0

func _ready() -> void:
	_build_structure()
	_build_conveyor_belt()
	_build_guillotine_placeholders()
	_setup_lighting()

func _build_structure() -> void:
	_add_static_box("Floor",    Vector3(0, 0, 0),                                   Vector3(GALPAO_LENGTH, 0.2,  GALPAO_WIDTH), Color(0.612, 0.455, 0.259))
	_add_static_box("Ceiling",  Vector3(0, GALPAO_HEIGHT, 0),                       Vector3(GALPAO_LENGTH, 0.2,  GALPAO_WIDTH), Color(0.45,  0.4,   0.35))
	_add_static_box("WallLeft", Vector3(-GALPAO_LENGTH * 0.5, GALPAO_HEIGHT * 0.5, 0), Vector3(0.2, GALPAO_HEIGHT, GALPAO_WIDTH), Color(0.545, 0.494, 0.431))
	_add_static_box("WallRight",Vector3( GALPAO_LENGTH * 0.5, GALPAO_HEIGHT * 0.5, 0), Vector3(0.2, GALPAO_HEIGHT, GALPAO_WIDTH), Color(0.545, 0.494, 0.431))
	_add_static_box("WallBack", Vector3(0, GALPAO_HEIGHT * 0.5, -GALPAO_WIDTH * 0.5),  Vector3(GALPAO_LENGTH, GALPAO_HEIGHT, 0.2), Color(0.545, 0.494, 0.431))

func _build_conveyor_belt() -> void:
	var belt := ConveyorBelt.new()
	belt.name = "ConveyorBeltNode"
	add_child(belt)

func _build_guillotine_placeholders() -> void:
	var half_sep := GUILLOTINE_SEPARATION * 0.5
	for side: int in [-1, 1]:
		var x := side * half_sep
		var suffix := "Left" if side == -1 else "Right"
		_add_box("GuillotineFrame" + suffix, Vector3(x, GALPAO_HEIGHT * 0.5, 0),         Vector3(0.3, GALPAO_HEIGHT, 2.2), Color(0.5,  0.42, 0.32))
		_add_box("GuillotineBlade" + suffix, Vector3(x, GALPAO_HEIGHT * 0.5 + 1.5, 0),  Vector3(0.15, 0.3, 1.8),          Color(0.29, 0.33, 0.38))

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

func _add_box(node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
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
