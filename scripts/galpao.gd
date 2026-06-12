# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
extends Node3D

# Fallback procedural: dimensões aproximadas do GLB girado (26×15×6)
const GALPAO_LENGTH: float = 26.0
const GALPAO_WIDTH: float = 15.0
const GALPAO_HEIGHT: float = 6.0
const GUILLOTINE_SEPARATION: float = 4.0

# Sincronizado com FrameController.LOG_RESET_X: spawn com a traseira da
# tora (centro − 2u) ainda sobre a correia (que começa em x = -10)
const LOG_RESET_X: float = -7.5
const LOG_Y: float = 0.75

var _guillotine_left: Guillotine
var _guillotine_right: Guillotine
var _esteira: Esteira
var _tora: Tora
# Grupo escalado/movido pelo FrameController no referencial de Bob.
# Tudo que está em repouso no referencial de Alice (galpão, guilhotinas,
# esteira) vai aqui dentro; tora, skydome, luzes e HUD ficam fora.
var _world: Node3D

func _ready() -> void:
	_build_skydome()
	_build_world_group()
	_build_galpao_mesh()
	_build_esteira()
	_build_guillotines()
	_build_tora()
	_build_ground()
	_setup_lighting()
	_build_hud()
	_build_frame_controller()

func _build_world_group() -> void:
	_world = Node3D.new()
	_world.name = "MovingWorld"
	add_child(_world)

func _build_tora() -> void:
	# Fora do MovingWorld: a tora não herda a contração do mundo no frame Bob
	_tora = load("res://scenes/world/tora.tscn").instantiate() as Tora
	_tora.name = "Tora"
	_tora.position = Vector3(LOG_RESET_X, LOG_Y, 0.0)
	add_child(_tora)

func _build_ground() -> void:
	# Colisor invisível fixo: sustenta o player quando o galpão (e seu chão
	# trimesh) desliza para trás no referencial de Bob
	var body := StaticBody3D.new()
	body.name = "GroundCollider"
	body.position = Vector3(0.0, -0.1, 0.0)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(80.0, 0.2, 80.0)
	col.shape = shape
	body.add_child(col)
	add_child(body)

func _build_frame_controller() -> void:
	var fc := FrameController.new()
	fc.name = "FrameController"
	fc.setup(_world, _esteira, _tora, _guillotine_left, _guillotine_right)
	add_child(fc)

func _build_structure() -> void:
	_add_static_box("Floor",    Vector3(0, 0, 0),                                   Vector3(GALPAO_LENGTH, 0.2,  GALPAO_WIDTH), Color(0.612, 0.455, 0.259))
	_add_static_box("Ceiling",  Vector3(0, GALPAO_HEIGHT, 0),                       Vector3(GALPAO_LENGTH, 0.2,  GALPAO_WIDTH), Color(0.45,  0.4,   0.35))
	_add_static_box("WallLeft", Vector3(-GALPAO_LENGTH * 0.5, GALPAO_HEIGHT * 0.5, 0), Vector3(0.2, GALPAO_HEIGHT, GALPAO_WIDTH), Color(0.545, 0.494, 0.431))
	_add_static_box("WallRight",Vector3( GALPAO_LENGTH * 0.5, GALPAO_HEIGHT * 0.5, 0), Vector3(0.2, GALPAO_HEIGHT, GALPAO_WIDTH), Color(0.545, 0.494, 0.431))
	_add_static_box("WallBack", Vector3(0, GALPAO_HEIGHT * 0.5, -GALPAO_WIDTH * 0.5),  Vector3(GALPAO_LENGTH, GALPAO_HEIGHT, 0.2), Color(0.545, 0.494, 0.431))

func _build_galpao_mesh() -> void:
	var packed: PackedScene = load("res://assets/models/galpao_estrutura.glb")
	if packed == null:
		push_warning("[Galpao] galpao_estrutura.glb não encontrado — usando geometria procedural")
		_build_structure()
		return
	var mesh_node: Node3D = packed.instantiate()
	mesh_node.name = "GalpaoMesh"
	mesh_node.scale = Vector3(0.25, 0.25, 0.25)
	# Rotação 90°: o eixo longo do GLB (25.6u) alinha com a esteira (eixo X).
	# Sem isso a esteira de 20u atravessa as paredes (interior x era ±7.6).
	# Offset recentra o bbox girado: paredes ficam em x ±12.8, z ±7.6 —
	# folga de ~2.5u nas pontas da esteira para o player passar.
	mesh_node.rotation_degrees = Vector3(0.0, 90.0, 0.0)
	mesh_node.position = Vector3(-3.34, -0.44, -0.06)
	_world.add_child(mesh_node)
	_add_trimesh_collision(mesh_node)

func _add_trimesh_collision(node: Node) -> void:
	for child: Node in node.get_children():
		if child is MeshInstance3D:
			child.create_trimesh_collision()
		_add_trimesh_collision(child)

func _build_skydome() -> void:
	var sphere := MeshInstance3D.new()
	sphere.name = "Skydome"
	sphere.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Centrado no galpão girado (antes acompanhava o offset z=-3 do GLB)
	sphere.position = Vector3(0.0, 12.5, 0.0)

	var mesh := SphereMesh.new()
	mesh.radius = 35.16
	mesh.height = 70.32
	mesh.radial_segments = 64
	mesh.rings = 32
	sphere.mesh = mesh

	var mat := StandardMaterial3D.new()
	# UNSHADED: a HDRI aparece sem ser afetada pelas luzes da cena
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# CULL_FRONT: descarta as faces externas, renderiza pelo lado de dentro
	mat.cull_mode = BaseMaterial3D.CULL_FRONT
	mat.albedo_texture = load("res://assets/textures/hdri_galpao.hdr")
	sphere.set_surface_override_material(0, mat)

	add_child(sphere)

func _build_hud() -> void:
	var hud := HUD.new()
	hud.name = "HUD"
	add_child(hud)

func _build_esteira() -> void:
	_esteira = load("res://scenes/world/esteira.tscn").instantiate() as Esteira
	_esteira.name = "EsteiraNode"
	_world.add_child(_esteira)

func _build_guillotines() -> void:
	var half_sep := GUILLOTINE_SEPARATION * 0.5

	_guillotine_left = Guillotine.new()
	_guillotine_left.name = "GuillotineLeft"
	_guillotine_left.position.x = -half_sep
	_world.add_child(_guillotine_left)

	_guillotine_right = Guillotine.new()
	_guillotine_right.name = "GuillotineRight"
	_guillotine_right.position.x = half_sep
	_world.add_child(_guillotine_right)

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

	# Fallback procedural faz parte da estrutura do galpão → MovingWorld
	_world.add_child(body)
