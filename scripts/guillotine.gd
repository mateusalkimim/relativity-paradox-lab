# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
extends Node3D
class_name Guillotine

enum State { READY, FALLING, DOWN, RETRACTING }

# Emitido uma vez por queda, no instante em que a lâmina cruza o topo da
# tora (CUT_PLANE_Y). O FrameController decide se há madeira sob a lâmina.
signal blade_crossed_cut_plane

# 14: queda pesada porém rápida (~0.21s até o plano de corte) — a mira não
# depende dela (o ponto é marcado no disparo), mas a resposta fica imediata
const FALL_SPEED: float = 14.0
const RETRACT_SPEED: float = 3.0
const DOWN_DURATION: float = 1.5

const FRAME_HEIGHT: float = 5.0
const BLADE_RAISED_Y: float = 4.0
const BLADE_DOWN_Y: float = 0.7
# Topo da tora: LOG_Y (0.75) + raio (0.25)
const CUT_PLANE_Y: float = 1.0

# Paleta §8.2 do README — guilhotina industrial
const COLOR_FRAME:  Color = Color(0.29, 0.33, 0.38)   # #4A5560 aço cinza-azulado
const COLOR_BLADE:  Color = Color(0.62, 0.66, 0.70)   # prata — face cortante
const COLOR_WEIGHT: Color = Color(0.18, 0.21, 0.25)   # ferro escuro — bloco de peso

var state: State = State.READY
var _blade_assembly: Node3D
var _down_timer: float = 0.0
var _crossed_emitted: bool = false

func _ready() -> void:
	_build_frame()
	_build_blade()

func _process(delta: float) -> void:
	match state:
		State.FALLING:
			_blade_assembly.position.y = move_toward(
					_blade_assembly.position.y, BLADE_DOWN_Y, FALL_SPEED * delta)
			if not _crossed_emitted and _blade_assembly.position.y <= CUT_PLANE_Y:
				_crossed_emitted = true
				blade_crossed_cut_plane.emit()
			if _blade_assembly.position.y <= BLADE_DOWN_Y:
				_blade_assembly.position.y = BLADE_DOWN_Y
				state = State.DOWN
				_down_timer = DOWN_DURATION

		State.DOWN:
			_down_timer -= delta
			if _down_timer <= 0.0:
				state = State.RETRACTING

		State.RETRACTING:
			_blade_assembly.position.y = move_toward(
					_blade_assembly.position.y, BLADE_RAISED_Y, RETRACT_SPEED * delta)
			if _blade_assembly.position.y >= BLADE_RAISED_Y:
				_blade_assembly.position.y = BLADE_RAISED_Y
				state = State.READY

func drop() -> void:
	if state == State.READY:
		_crossed_emitted = false
		state = State.FALLING

func reset() -> void:
	state = State.READY
	_blade_assembly.position.y = BLADE_RAISED_Y
	_down_timer = 0.0
	_crossed_emitted = false

func _build_frame() -> void:
	# Dois montantes verticais (os trilhos do H)
	_mesh(self, "PostLeft",  Vector3(0.0, FRAME_HEIGHT * 0.5, -1.0), Vector3(0.18, FRAME_HEIGHT, 0.18), COLOR_FRAME)
	_mesh(self, "PostRight", Vector3(0.0, FRAME_HEIGHT * 0.5,  1.0), Vector3(0.18, FRAME_HEIGHT, 0.18), COLOR_FRAME)

	# Viga superior conectando os montantes
	_mesh(self, "TopBeam", Vector3(0.0, FRAME_HEIGHT - 0.12, 0.0), Vector3(0.20, 0.24, 2.36), COLOR_FRAME)

	# Base: travessa central + dois pés que dão estabilidade lateral
	_mesh(self, "BaseCross", Vector3(0.0, 0.11, 0.0),  Vector3(0.24, 0.22, 2.36), COLOR_FRAME)
	_mesh(self, "BaseFootL", Vector3(0.0, 0.11, -1.0), Vector3(0.54, 0.22, 0.22), COLOR_FRAME)
	_mesh(self, "BaseFootR", Vector3(0.0, 0.11,  1.0), Vector3(0.54, 0.22, 0.22), COLOR_FRAME)

	# Guias internas — calhas onde a lâmina desliza
	_mesh(self, "GuideL", Vector3(0.0, FRAME_HEIGHT * 0.5, -0.91), Vector3(0.06, FRAME_HEIGHT, 0.05), COLOR_WEIGHT)
	_mesh(self, "GuideR", Vector3(0.0, FRAME_HEIGHT * 0.5,  0.91), Vector3(0.06, FRAME_HEIGHT, 0.05), COLOR_WEIGHT)

func _build_blade() -> void:
	_blade_assembly = Node3D.new()
	_blade_assembly.name = "BladeAssembly"
	_blade_assembly.position.y = BLADE_RAISED_Y
	add_child(_blade_assembly)

	# Corpo da lâmina — face cortante prateada, desliza entre as guias
	_mesh(_blade_assembly, "BladeBody",
			Vector3(0.0, 0.0, 0.0), Vector3(0.10, 0.55, 1.76), COLOR_BLADE, 0.3)

	# Bloco de peso — ferro escuro sobre a lâmina, dá massa visual ao conjunto
	_mesh(_blade_assembly, "BladeWeight",
			Vector3(0.0, 0.50, 0.0), Vector3(0.28, 0.45, 1.60), COLOR_WEIGHT)

func _mesh(parent: Node3D, node_name: String, pos: Vector3, size: Vector3,
		color: Color, metallic: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mat.roughness = 0.85
	mat.metallic = metallic
	mi.mesh = mesh
	mi.set_surface_override_material(0, mat)
	parent.add_child(mi)
	return mi
