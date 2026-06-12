# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
extends Node3D
class_name Esteira

# 1. Constantes

# Decouples beta [0,1] from visible pixel speed — same constant as conveyor_belt.gd
# so both systems look visually consistent if ever shown side-by-side.
const VISUAL_C: float = 5.0

const BELT_LENGTH: float = 20.0
const UV_SCALE_X: float = 10.0

# Theoretical UV scroll rate: VISUAL_C / (BELT_LENGTH / UV_SCALE_X) = 2.5 UV-units/sec at beta=1.
const UV_SCROLL_RATE: float = VISUAL_C / (BELT_LENGTH / UV_SCALE_X)

# 2. Exportadas

# Tune this in the Inspector while the game runs to visually match belt speed to tora.
# 1.0 = theoretical. Adjust until stripes and tora appear to move at the same rate.
@export var uv_scroll_visual_scale: float = 0.8

# 6. Onready
@onready var _correia: MeshInstance3D = $Correia

# 5. Variáveis privadas
var _mat: StandardMaterial3D

# 7. Funções built-in

func _ready() -> void:
	var src_mat := _correia.get_surface_override_material(0) as StandardMaterial3D
	# Duplicate so each Esteira instance has its own uv1_offset.
	# Sub-resources in .tscn are shared across instances by default — without
	# duplicate(), scrolling one instance would shift all others simultaneously.
	_mat = src_mat.duplicate() as StandardMaterial3D
	# Replace GradientTexture1D (clamp-only) with an ImageTexture that tiles.
	# GradientTexture1D defaults to clamp mode, so UV > 1 showed solid color —
	# the stripe was visible only in the first 2 world-units of the 20u belt.
	_mat.albedo_texture = _create_stripe_texture()
	_correia.set_surface_override_material(0, _mat)

func _process(delta: float) -> void:
	# O scroll roda nos dois referenciais: em ALICE a superfície acompanha a
	# tora; em BOB a estrutura recua a -v enquanto a superfície avança a +v
	# relativa a ela — saldo visual: superfície em repouso com a tora. Correto.
	_scroll_belt(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("speed_up"):
		GameState.increase_speed()
	elif event.is_action_pressed("speed_down"):
		GameState.decrease_speed()

# 9. Funções privadas

func _scroll_belt(delta: float) -> void:
	if _mat == null:
		return
	# UV scroll creates the illusion of belt movement without any node translating.
	# This is preferable to moving geometry: no floating-point drift, no wrap logic,
	# and frame_controller.gd can scale this whole node for Lorentz contraction
	# without disturbing the scroll state.
	# Decreasing uv1_offset.x shifts sampling to lower U values → stripe pattern
	# appears to move in world +X direction (belt "runs forward").
	var offset := _mat.uv1_offset
	offset.x += GameState.belt_beta * UV_SCROLL_RATE * uv_scroll_visual_scale * delta
	_mat.uv1_offset = offset

func _create_stripe_texture() -> ImageTexture:
	# 64×4 px: height irrelevant for a horizontal stripe pattern.
	# Dark band from U=0.69 to U=0.81 — visible at 10× tiling as stripes every 2u.
	# ImageTexture repeats by default in 3D materials, unlike GradientTexture1D.
	var img := Image.create(64, 4, false, Image.FORMAT_RGB8)
	var belt_color := Color(0.22745, 0.22745, 0.22745)
	var stripe_color := Color(0.16471, 0.16471, 0.16471)
	for x in 64:
		var u := float(x) / 64.0
		var color := stripe_color if (u >= 0.69 and u <= 0.81) else belt_color
		for y in 4:
			img.set_pixel(x, y, color)
	return ImageTexture.create_from_image(img)
