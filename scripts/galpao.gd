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
var _bob_avatar: Avatar
var _alice_avatar: Avatar
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
	_build_avatars()
	_build_ground()
	_build_boundary_walls()
	_build_belt_walkway()
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
	# Colisor invisível fixo: único piso físico do player — a estrutura
	# visual do galpão não tem colisão (ver _build_galpao_mesh)
	var body := StaticBody3D.new()
	body.name = "GroundCollider"
	body.position = Vector3(0.0, -0.1, 0.0)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(80.0, 0.2, 80.0)
	col.shape = shape
	body.add_child(col)
	add_child(body)

# Contenção invisível e estática do player, fora do MovingWorld — alinhada
# às faces internas das paredes do GLB em escala 1 (x ±12.3/12.4, z ±7.1).
# Nota: em BOB o galpão visual contrai/desliza e deixa de coincidir com
# estes limites; o objetivo é só impedir o operador de sair do palco.
func _build_boundary_walls() -> void:
	_add_boundary("BoundXNeg", Vector3(-12.5, 3.0, 0.0), Vector3(0.4, 6.0, 15.0))
	_add_boundary("BoundXPos", Vector3(12.6, 3.0, 0.0), Vector3(0.4, 6.0, 15.0))
	_add_boundary("BoundZNeg", Vector3(0.0, 3.0, -7.3), Vector3(25.6, 6.0, 0.4))
	_add_boundary("BoundZPos", Vector3(0.0, 3.0, 7.3), Vector3(25.6, 6.0, 0.4))

func _add_boundary(node_name: String, pos: Vector3, size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = pos
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	body.add_child(col)
	add_child(body)

# Piso físico invisível sobre a correia: o player anda na esteira nos dois
# referenciais. Estático e fora do MovingWorld, como os boundary walls —
# a Correia visual não tem colisão e a estrutura da esteira escala em BOB.
# Topo em y=0.5 (face superior da correia).
func _build_belt_walkway() -> void:
	_add_boundary("BeltWalkway", Vector3(0.0, 0.25, 0.0), Vector3(20.0, 0.5, 1.5))

func _build_avatars() -> void:
	# Bob: viaja na correia atrás da tora — fora do MovingWorld, como a tora,
	# para não herdar a escala do mundo. O FrameController o move/contrai em
	# ALICE e o faz mergulhar no poço junto com a madeira no fim da passada.
	# Sempre visível: o operador é o observador, não encarna ninguém.
	_bob_avatar = Avatar.new()
	_bob_avatar.name = "BobAvatar"
	_bob_avatar.model_file = "Barbarian.glb"
	_bob_avatar.attach_file = "axe_1handed.gltf"  # lenhador a 0.9c
	_bob_avatar.attach_rotation_degrees = Vector3(0.0, 0.0, 180.0)  # gume pra baixo
	_bob_avatar.position = Vector3(LOG_RESET_X - 2.4, 0.5, 0.0)
	_bob_avatar.rotation.y = -PI / 2  # frente -Z vira +X: olha o sentido da viagem
	add_child(_bob_avatar)

	# Alice: posto de operação ao lado da correia, em repouso no galpão —
	# dentro do MovingWorld (contrai/desliza em BOB com o resto do mundo).
	# Sempre visível, como o Bob.
	_alice_avatar = Avatar.new()
	_alice_avatar.name = "AliceAvatar"
	_alice_avatar.model_file = "Rogue.glb"
	_alice_avatar.hide_meshes = PackedStringArray(["Rogue_Cape"])  # Alice sem capa
	# Cores: só valem se o GLB faltar e o fallback procedural assumir
	_alice_avatar.shirt_color = Color(0.30, 0.45, 0.60)
	_alice_avatar.helmet_color = Color(0.85, 0.85, 0.88)
	_alice_avatar.position = Vector3(0.0, 0.0, -2.0)
	_alice_avatar.rotation.y = PI  # frente -Z vira +Z: olhando para a esteira
	_world.add_child(_alice_avatar)

func _build_frame_controller() -> void:
	var fc := FrameController.new()
	fc.name = "FrameController"
	fc.setup(_world, _tora, _guillotine_left, _guillotine_right, _bob_avatar, _alice_avatar)
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
	# SEM colisão trimesh: a estrutura é filha do MovingWorld, que escala na
	# transição e desliza em BOB — colisão móvel empurrava/arrastava o player.
	# Estrutura interna (postes, vigas) é só visual; a contenção do player
	# fica nas paredes invisíveis estáticas (_build_boundary_walls).
	_world.add_child(mesh_node)

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
	# A superfície da correia está em repouso com a TORA, não com o galpão:
	# em BOB ela não pode contrair nem deslizar junto com a estrutura. Sai do
	# MovingWorld já pronta (reparent preserva o transform global; a referência
	# _correia interna da Esteira continua válida — é o mesmo nó).
	_esteira.get_node("Correia").reparent(self)

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

# Look Link's Awakening Remake: diorama de brinquedo — ambiente difuso forte
# preenchendo tudo, sol moderado com penumbra macia, quase nenhum specular
# (a parte de material fica nos helpers de esteira/guilhotina: metallic 0)
func _setup_lighting() -> void:
	var env := Environment.new()
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.93, 0.91, 0.86)  # branco quente
	env.ambient_light_energy = 0.7
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnv"
	world_env.environment = env
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.name = "SunLight"
	sun.rotation_degrees = Vector3(-50.0, 30.0, 0.0)
	sun.light_color = Color(1.0, 0.92, 0.75)
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	sun.shadow_bias = 0.05
	# Penumbra: tamanho angular do sol + blur suavizam a borda da sombra
	sun.light_angular_distance = 3.5
	sun.shadow_blur = 2.0
	add_child(sun)

	# Fill discreto: o ambiente já preenche; só quebra o teto escuro
	var fill := DirectionalLight3D.new()
	fill.name = "FillLight"
	fill.rotation_degrees = Vector3(-20.0, -150.0, 0.0)
	fill.light_color = Color(0.5, 0.6, 0.8)
	fill.light_energy = 0.15
	fill.shadow_enabled = false
	add_child(fill)

# Fallback procedural: só visual (sem colisão), pelo mesmo motivo do GLB —
# está no MovingWorld; a contenção do player é dos boundary walls estáticos
func _add_static_box(node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
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
	_world.add_child(mi)
