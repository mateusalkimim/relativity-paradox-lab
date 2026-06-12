# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
class_name Grain

# Acabamento fosco e granulado dos materiais procedurais (look LA Remake):
# normal map de ruído gerada em runtime — sem asset externo — dá o aspecto
# árido que tira o "balão de plástico" das superfícies lisas.

static var _tex: NoiseTexture2D

static func texture() -> NoiseTexture2D:
	if _tex == null:
		var noise := FastNoiseLite.new()
		noise.frequency = 0.08
		_tex = NoiseTexture2D.new()
		_tex.width = 256
		_tex.height = 256
		_tex.noise = noise
		_tex.as_normal_map = true
		_tex.bump_strength = 2.0
	return _tex

# Aplica o acabamento padrão: per-pixel (normal map não funciona em
# per-vertex), sem metallic, specular mínimo, roughness total + granulado.
static func apply(mat: StandardMaterial3D) -> StandardMaterial3D:
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.roughness = 1.0
	mat.metallic = 0.0
	mat.metallic_specular = 0.05
	mat.normal_enabled = true
	mat.normal_texture = texture()
	mat.normal_scale = 0.4
	return mat
