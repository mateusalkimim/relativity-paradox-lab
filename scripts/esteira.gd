# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
extends Node3D
class_name Esteira

# 1. Constantes

# Decouples beta [0,1] from visible pixel speed — same constant as conveyor_belt.gd
# so both systems look visually consistent if ever shown side-by-side.
const VISUAL_C: float = 5.0

const BELT_LENGTH: float = 20.0
const BELT_HALF: float = BELT_LENGTH * 0.5

# Sarrafos físicos sobre a correia: transladam com o MESMO passo da tora
# (belt_beta * VISUAL_C * delta, ver FrameController._process) — o movimento
# bate por construção. O UV scroll antigo dependia de um fator de ajuste
# visual e nunca casou com a tora.
const SLAT_COUNT: int = 10
const SLAT_SIZE := Vector3(0.25, 0.03, 1.4)
const COLOR_SLAT: Color = Color(0.16, 0.16, 0.16)

# Paleta §8.2 do README — estrutura metálica, mesmo estilo da guilhotina
const COLOR_RAIL: Color = Color(0.29, 0.33, 0.38)    # #4A5560 aço cinza-azulado
const COLOR_ROLLER: Color = Color(0.42, 0.47, 0.50)  # #6B7780 metal claro
const COLOR_WRAP: Color = Color(0.19, 0.19, 0.19)    # borracha da correia nas pontas
const COLOR_MOTOR: Color = Color(0.18, 0.21, 0.25)   # ferro escuro

# Roletes intermediários: raio menor que os das pontas (0.25), topo tangente
# à face inferior da correia (0.475)
const MID_ROLLER_RADIUS: float = 0.22
const MID_ROLLER_XS: Array[float] = [-7.5, -5.0, -2.5, 0.0, 2.5, 5.0, 7.5]
const LEG_XS: Array[float] = [-5.0, 0.0, 5.0]

# Cenografia do ciclo da tora (sincronizado com FrameController):
# FEED_X = LOG_RESET_X — a tora cai da calha neste x
# PIT_X — centro do poço de descarga onde a tora mergulha na saída
const FEED_X: float = -7.5
const PIT_X: float = 11.35
const COLOR_PIT: Color = Color(0.04, 0.04, 0.05)  # quase-preto: lê como buraco

# 6. Onready
@onready var _correia: MeshInstance3D = $Correia

# 5. Variáveis privadas
var _slats: Array[MeshInstance3D] = []
var _spinners: Array[MeshInstance3D] = []

# 7. Funções built-in

func _ready() -> void:
	_build_slats()
	_build_structure()
	_spinners.append($RoleteEsquerdo as MeshInstance3D)
	_spinners.append($RoleteDireito as MeshInstance3D)

func _process(delta: float) -> void:
	# Movimento só em ALICE: no referencial de Bob a superfície da correia
	# está em repouso com a tora — quem recua é a estrutura (MovingWorld).
	if GameState.current_frame != GameState.Frame.ALICE:
		return
	var step := GameState.belt_beta * VISUAL_C * delta
	for slat in _slats:
		slat.position.x += step
		if slat.position.x > BELT_HALF:
			slat.position.x -= BELT_LENGTH
	# Rolos giram com ω = v/r. Eixo do cilindro = Y local (deitado no mundo Z);
	# sinal negativo: topo do rolo tangencia a correia que anda em +X.
	for spinner in _spinners:
		var radius := (spinner.mesh as CylinderMesh).top_radius
		spinner.rotate_object_local(Vector3.UP, -step / radius)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("speed_up"):
		GameState.increase_speed()
	elif event.is_action_pressed("speed_down"):
		GameState.decrease_speed()

# 9. Funções privadas

# Estrutura procedural complementar ao .tscn — placeholder estilizado
# enquanto esteira.glb (Hyper3D) está pendente. Tudo aditivo: a Correia
# (UV scroll) e o plano de apoio da tora (y=0.5) não mudam.
func _build_structure() -> void:
	# Capas das pontas: a correia "envolvendo" os roletes externos.
	# Raio 0.28 = rolete (0.25) + espessura visual da borracha.
	_add_wrap_cap("WrapLeft", -BELT_LENGTH * 0.5)
	_add_wrap_cap("WrapRight", BELT_LENGTH * 0.5)

	# Roletes intermediários visíveis sob a correia — giram junto com o belt
	for i: int in MID_ROLLER_XS.size():
		_spinners.append(_add_cylinder("MidRoller%d" % i,
				Vector3(MID_ROLLER_XS[i], 0.475 - MID_ROLLER_RADIUS, 0.0),
				MID_ROLLER_RADIUS, 1.5, COLOR_ROLLER, 0.6))

	# Trilhos laterais na altura da correia: escondem a borda do belt
	# (belt edge em z=±0.75; trilho centrado em ±0.79 encosta nela)
	_add_box("RailL", Vector3(0.0, 0.47, -0.79), Vector3(BELT_LENGTH + 0.4, 0.12, 0.08), COLOR_RAIL, 0.3)
	_add_box("RailR", Vector3(0.0, 0.47, 0.79), Vector3(BELT_LENGTH + 0.4, 0.12, 0.08), COLOR_RAIL, 0.3)

	# Chassis: longarinas que carregam os roletes, apoiadas nos pés
	_add_box("ChassisL", Vector3(0.0, 0.34, -0.70), Vector3(BELT_LENGTH - 0.4, 0.10, 0.10), COLOR_RAIL, 0.3)
	_add_box("ChassisR", Vector3(0.0, 0.34, 0.70), Vector3(BELT_LENGTH - 0.4, 0.10, 0.10), COLOR_RAIL, 0.3)

	# Pés intermediários (as pontas já têm os 4 suportes do .tscn)
	for i: int in LEG_XS.size():
		_add_box("LegL%d" % i, Vector3(LEG_XS[i], 0.15, -0.675), Vector3(0.12, 0.30, 0.12), COLOR_RAIL)
		_add_box("LegR%d" % i, Vector3(LEG_XS[i], 0.15, 0.675), Vector3(0.12, 0.30, 0.12), COLOR_RAIL)

	# Bloco do motor na ponta de saída — dá direção visual à esteira
	_add_box("Motor", Vector3(9.6, 0.30, 1.05), Vector3(0.7, 0.55, 0.5), COLOR_MOTOR, 0.4)

	_build_hopper()
	_build_discharge_pit()

# Calha de alimentação: rack de aço sobre a entrada da esteira de onde a
# tora nova cai (FrameController._spawn_tora). Pernas fora da correia (z ±1.0).
func _build_hopper() -> void:
	for i: int in 4:
		var sx: float = -1.9 if i < 2 else 1.9
		var sz: float = -1.0 if i % 2 == 0 else 1.0
		_add_box("HopperLeg%d" % i, Vector3(FEED_X + sx, 1.1, sz),
				Vector3(0.12, 2.2, 0.12), COLOR_RAIL)
	_add_box("HopperRailL", Vector3(FEED_X, 2.25, -1.0), Vector3(3.95, 0.10, 0.10), COLOR_RAIL, 0.3)
	_add_box("HopperRailR", Vector3(FEED_X, 2.25, 1.0), Vector3(3.95, 0.10, 0.10), COLOR_RAIL, 0.3)
	# Calha em V: placas inclinadas com vão central por onde a tora é liberada
	_add_sloped_plate("HopperPlateL", Vector3(FEED_X, 2.6, -0.42), 40.0)
	_add_sloped_plate("HopperPlateR", Vector3(FEED_X, 2.6, 0.42), -40.0)

func _add_sloped_plate(node_name: String, pos: Vector3, tilt_deg: float) -> void:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.position = pos
	mi.rotation_degrees.x = tilt_deg
	var mesh := BoxMesh.new()
	mesh.size = Vector3(4.2, 0.06, 1.0)
	mi.mesh = mesh
	mi.set_surface_override_material(0, _make_metal_material(COLOR_RAIL, 0.3))
	add_child(mi)

# Poço de descarga: abertura escura no chão depois da ponta da esteira.
# A tora mergulha nele na saída e o interior quase-preto mascara o despawn.
func _build_discharge_pit() -> void:
	# Compacto para caber entre o fim da esteira (x=10.3) e a mureta da
	# fachada aberta do galpão (face interna em x=12.54)
	# Interior: caixa escura com topo no nível do chão — lê como buraco
	_add_box("PitInterior", Vector3(PIT_X, -0.7, 0.0), Vector3(2.0, 1.4, 1.8), COLOR_PIT)
	# Bordas metálicas emolduram a abertura
	_add_box("PitRimFront", Vector3(PIT_X, 0.06, -1.0), Vector3(2.4, 0.12, 0.2), COLOR_RAIL, 0.3)
	_add_box("PitRimBack", Vector3(PIT_X, 0.06, 1.0), Vector3(2.4, 0.12, 0.2), COLOR_RAIL, 0.3)
	_add_box("PitRimLeft", Vector3(PIT_X - 1.1, 0.06, 0.0), Vector3(0.2, 0.12, 2.2), COLOR_RAIL, 0.3)
	_add_box("PitRimRight", Vector3(PIT_X + 1.1, 0.06, 0.0), Vector3(0.2, 0.12, 2.2), COLOR_RAIL, 0.3)

# Sarrafos: filhos da Correia — saem do MovingWorld junto com ela no reparent
# do galpao.gd. y local 0.04 = topo da correia + 0.015 de relevo.
func _build_slats() -> void:
	var spacing := BELT_LENGTH / SLAT_COUNT
	for i: int in SLAT_COUNT:
		var mi := MeshInstance3D.new()
		mi.name = "Slat%d" % i
		mi.position = Vector3(-BELT_HALF + spacing * (i + 0.5), 0.04, 0.0)
		var mesh := BoxMesh.new()
		mesh.size = SLAT_SIZE
		mi.mesh = mesh
		mi.set_surface_override_material(0, _make_metal_material(COLOR_SLAT, 0.0))
		_correia.add_child(mi)
		_slats.append(mi)

func _add_wrap_cap(node_name: String, x: float) -> void:
	var cap := _add_cylinder(node_name, Vector3(x, 0.25, 0.0), 0.28, 1.52, COLOR_WRAP, 0.0)
	_spinners.append(cap)
	# Pino de contraste na superfície: o giro de um cilindro liso é invisível
	var pin := MeshInstance3D.new()
	pin.name = "Pin"
	pin.position = Vector3(0.27, 0.0, 0.0)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.035, 1.45, 0.05)
	pin.mesh = mesh
	pin.set_surface_override_material(0, _make_metal_material(COLOR_ROLLER, 0.0))
	cap.add_child(pin)

func _add_cylinder(node_name: String, pos: Vector3, radius: float, length: float,
		color: Color, metallic: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.position = pos
	# Eixo Y do cilindro deitado ao longo do mundo Z (mesma orientação dos roletes do .tscn)
	mi.rotation_degrees.x = 90.0
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = length
	mesh.radial_segments = 8
	mesh.rings = 1
	mi.mesh = mesh
	mi.set_surface_override_material(0, _make_metal_material(color, metallic))
	add_child(mi)
	return mi

func _add_box(node_name: String, pos: Vector3, size: Vector3,
		color: Color, metallic: float = 0.0) -> void:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.set_surface_override_material(0, _make_metal_material(color, metallic))
	add_child(mi)

func _make_metal_material(color: Color, metallic: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mat.roughness = 0.85
	mat.metallic = metallic
	return mat

