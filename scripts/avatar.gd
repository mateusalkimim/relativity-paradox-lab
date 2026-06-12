# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
extends Node3D
class_name Avatar

# Figura humana low-poly procedural — Bob (na esteira) e Alice (no posto
# da guilhotina). Briefing 2026-06-12: ancoragem narrativa dos referenciais.
# Pés na origem (y=0); ~1.4u de altura; frente = -Z (padrão Godot).

# 2. Exportadas (definir antes de add_child — _ready constrói com elas)
@export var shirt_color: Color = Color(0.75, 0.45, 0.2)
@export var pants_color: Color = Color(0.25, 0.30, 0.40)
@export var skin_color: Color = Color(0.87, 0.67, 0.51)
@export var helmet_color: Color = Color(0.90, 0.75, 0.20)

# 7. Funções built-in

func _ready() -> void:
	_box("LegL", Vector3(-0.10, 0.25, 0.0), Vector3(0.16, 0.50, 0.16), pants_color)
	_box("LegR", Vector3(0.10, 0.25, 0.0), Vector3(0.16, 0.50, 0.16), pants_color)
	_box("Torso", Vector3(0.0, 0.78, 0.0), Vector3(0.40, 0.56, 0.24), shirt_color)
	_box("ArmL", Vector3(-0.27, 0.75, 0.0), Vector3(0.12, 0.50, 0.14), shirt_color)
	_box("ArmR", Vector3(0.27, 0.75, 0.0), Vector3(0.12, 0.50, 0.14), shirt_color)
	_box("Head", Vector3(0.0, 1.20, 0.0), Vector3(0.24, 0.26, 0.24), skin_color)
	_box("Helmet", Vector3(0.0, 1.36, 0.0), Vector3(0.30, 0.10, 0.30), helmet_color)

# 9. Funções privadas

func _box(node_name: String, pos: Vector3, size: Vector3, color: Color) -> void:
	var mi := MeshInstance3D.new()
	mi.name = node_name
	mi.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	mat.roughness = 0.9
	mi.mesh = mesh
	mi.set_surface_override_material(0, mat)
	add_child(mi)
