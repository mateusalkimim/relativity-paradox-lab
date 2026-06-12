# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
extends Node3D
class_name Tora

# 1. Constantes
# 8 lados: mínimo para ser lida como cilindro com o look faceted low-poly desejado.
# Menos de 8 parece poligonal demais; mais de 8 perde o caráter low-poly.
const RADIAL_SEGMENTS: int = 8

# 1. Constantes
# Margem mínima do ponto de corte até as pontas: evita "fatia" degenerada
const CUT_EDGE_MARGIN: float = 0.3
const CUT_SEPARATION: float = 0.35
const CUT_SETTLE_Y: float = -0.05
const CUT_TILT_RAD: float = 0.06
const CUT_ANIM_DURATION: float = 0.6

# 2. Exportadas
# L₀: comprimento próprio medido no referencial de repouso da tora (seção 2.2 do README).
# frame_controller.gd aplica scale.x = 1/γ no Node3D raiz desta cena.
# O pivot está no centro geométrico: a contração ocorre simetricamente em ambas as pontas,
# o que é fisicamente correto (L = L₀/γ centrado no mesmo ponto médio).
@export var rest_length: float = 4.0
@export var diameter: float = 0.5

# 3. Sinais
signal was_cut

# 4. Variáveis públicas
var is_cut: bool = false

# 5. Variáveis privadas
var _halves: Array[MeshInstance3D] = []

# 6. Onready
@onready var _mesh: MeshInstance3D = $Mesh
@onready var _cap_left: MeshInstance3D = $CapLeft
@onready var _cap_right: MeshInstance3D = $CapRight

# 7. Funções built-in
func _ready() -> void:
	# Pivot no centro geométrico: scale.x = 1/γ contrai simetricamente nos dois lados
	print("[Tora] L₀=%.1f u  diâmetro=%.1f u" % [rest_length, diameter])
	# Granulado de madeira árida nos materiais do .tscn (corpo + tampas
	# compartilham 2 materiais; aplicar de novo é idempotente). As metades
	# do corte herdam via cópia do material do Mesh em _spawn_half.
	for mi: MeshInstance3D in [_mesh, _cap_left, _cap_right]:
		Grain.apply(mi.get_surface_override_material(0) as StandardMaterial3D)

# 8. Funções públicas

# Contrai visualmente para o referencial de Alice: scale.x = 1/γ.
# Chamado pelo frame_controller; não anima — aplica estado final para o Tween interpolar.
func set_lorentz_scale(gamma: float) -> void:
	scale.x = 1.0 / gamma

# Restaura comprimento próprio ao entrar no referencial de Bob (tora em repouso).
func reset_lorentz_scale() -> void:
	scale.x = 1.0

# Corta a tora no ponto local_x (coordenada local, eixo do comprimento).
# Esconde a malha original e cria duas metades que se separam e assentam —
# resultado binário e visceral do paradoxo (README §3.1).
func cut_at(local_x: float) -> void:
	if is_cut:
		return
	is_cut = true
	var half_len := rest_length * 0.5
	local_x = clampf(local_x, -half_len + CUT_EDGE_MARGIN, half_len - CUT_EDGE_MARGIN)
	_mesh.visible = false
	_cap_left.visible = false
	_cap_right.visible = false
	_spawn_half(-half_len, local_x, -1.0)
	_spawn_half(local_x, half_len, 1.0)
	was_cut.emit()

# Remove as metades e restaura a tora inteira (chamado no wrap e no reset)
func restore() -> void:
	for half in _halves:
		half.queue_free()
	_halves.clear()
	_mesh.visible = true
	_cap_left.visible = true
	_cap_right.visible = true
	is_cut = false

# 9. Funções privadas

func _spawn_half(from_x: float, to_x: float, dir: float) -> void:
	var length := to_x - from_x
	var mi := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = diameter * 0.5
	mesh.bottom_radius = diameter * 0.5
	# 0.98: pequeno respiro no ponto de corte para as faces não coincidirem
	mesh.height = length * 0.98
	mesh.radial_segments = RADIAL_SEGMENTS
	mesh.rings = 1
	mi.mesh = mesh
	# Mesma rotação do Mesh original: eixo Y do cilindro alinhado ao X local
	mi.rotation.z = -PI / 2.0
	mi.position = Vector3((from_x + to_x) * 0.5, 0.0, 0.0)
	mi.set_surface_override_material(0, _mesh.get_surface_override_material(0))
	add_child(mi)
	_halves.append(mi)

	# As metades se afastam do corte, assentam e tombam levemente para fora
	var tween := create_tween().set_parallel(true) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(mi, "position:x", mi.position.x + dir * CUT_SEPARATION, CUT_ANIM_DURATION)
	tween.tween_property(mi, "position:y", CUT_SETTLE_Y, CUT_ANIM_DURATION)
	tween.tween_property(mi, "rotation:z", mi.rotation.z + dir * CUT_TILT_RAD, CUT_ANIM_DURATION)
