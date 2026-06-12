# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
extends Node3D
class_name Avatar

# Figura humana — Bob (na esteira) e Alice (no posto da guilhotina).
# Carrega um personagem KayKit (CC0, Kay Lousberg — kaylousberg.com) com as
# animações do Rig_Medium; sem modelo configurado (ou arquivo ausente), cai
# na figura low-poly procedural de 7 caixas.
# Pés na origem (y=0); frente = -Z (padrão Godot).

# 1. Constantes

const MODEL_DIR := "res://assets/models/characters/"
# Bibliotecas de animação do Rig_Medium: a hierarquia interna dos GLBs de
# animação espelha a dos personagens (raiz "Rig_Medium"), então os tracks
# resolvem por caminho relativo, sem retarget.
const ANIM_LIBS: Dictionary = {
	"general": MODEL_DIR + "anims/Rig_Medium_General.glb",
	"movement": MODEL_DIR + "anims/Rig_Medium_MovementBasic.glb",
	"tools": MODEL_DIR + "anims/Rig_Medium_Tools.glb",
}

# 2. Exportadas (definir antes de add_child — _ready constrói com elas)

@export var model_file: String = ""  # ex.: "Barbarian.glb"; vazio = procedural
@export var target_height: float = 1.4  # bind pose KayKit tem ~2.2-2.4u
@export var model_yaw_degrees: float = 180.0  # KayKit olha +Z; Avatar usa -Z
@export var hide_meshes: PackedStringArray = []  # ex.: ["Rogue_Cape"]
# Prop preso à mão via BoneAttachment3D — o rig KayKit tem ossos dedicados
# "handslot.r"/"handslot.l" e os props encaixam neles sem offset
@export var attach_file: String = ""  # ex.: "axe_1handed.gltf"; vazio = nada
@export var attach_bone: String = "handslot.r"
# Orientação do prop dentro do slot (ajuste fino no Inspector se necessário)
@export var attach_rotation_degrees: Vector3 = Vector3.ZERO
@export var idle_animation: String = "general/Idle_A"
# Cores — usadas apenas no fallback procedural
@export var shirt_color: Color = Color(0.75, 0.45, 0.2)
@export var pants_color: Color = Color(0.25, 0.30, 0.40)
@export var skin_color: Color = Color(0.87, 0.67, 0.51)
@export var helmet_color: Color = Color(0.90, 0.75, 0.20)

# 5. Variáveis privadas

var _anim_player: AnimationPlayer

# 7. Funções built-in

func _ready() -> void:
	if model_file != "" and ResourceLoader.exists(MODEL_DIR + model_file):
		_build_model()
		return
	if model_file != "":
		push_warning("[Avatar] %s não encontrado — usando figura procedural" % model_file)
	_build_procedural()

# 8. Funções públicas

# Toca um clipe por nome qualificado ("biblioteca/Clipe", ex.: "tools/Sawing").
# Clipes glTF não trazem flag de loop; este Avatar só toca poses cíclicas
# (idle/walk/work), então o loop é ligado no que for tocado.
func play(anim: String) -> void:
	if _anim_player == null or not _anim_player.has_animation(anim):
		return
	_anim_player.get_animation(anim).loop_mode = Animation.LOOP_LINEAR
	_anim_player.play(anim)

# 9. Funções privadas

func _build_model() -> void:
	var model := (load(MODEL_DIR + model_file) as PackedScene).instantiate() as Node3D
	model.name = "Model"
	model.rotation.y = deg_to_rad(model_yaw_degrees)
	var s := target_height / maxf(_bind_pose_height(model), 0.01)
	model.scale = Vector3(s, s, s)
	for mesh_name in hide_meshes:
		var mesh := model.find_child(mesh_name, true, false) as MeshInstance3D
		if mesh != null:
			mesh.visible = false
	add_child(model)
	_attach_prop(model)
	_setup_animations(model)

func _attach_prop(model: Node3D) -> void:
	if attach_file == "" or not ResourceLoader.exists(MODEL_DIR + attach_file):
		if attach_file != "":
			push_warning("[Avatar] prop %s não encontrado" % attach_file)
		return
	var skeleton := model.find_children("*", "Skeleton3D", true, false)
	if skeleton.is_empty() or (skeleton[0] as Skeleton3D).find_bone(attach_bone) < 0:
		push_warning("[Avatar] osso %s não existe no rig de %s" % [attach_bone, model_file])
		return
	var mount := BoneAttachment3D.new()
	mount.name = "PropMount"
	mount.bone_name = attach_bone
	skeleton[0].add_child(mount)
	var prop := (load(MODEL_DIR + attach_file) as PackedScene).instantiate() as Node3D
	prop.rotation_degrees = attach_rotation_degrees
	mount.add_child(prop)

# Altura do bind pose pela união dos AABBs dos meshes — nos personagens
# KayKit os meshes ficam no transform identidade sob o Skeleton3D, então o
# AABB do mesh já está no espaço do modelo.
func _bind_pose_height(model: Node3D) -> float:
	var merged := AABB()
	for mesh: MeshInstance3D in model.find_children("*", "MeshInstance3D", true, false):
		var aabb := mesh.get_aabb()
		merged = aabb if merged.size == Vector3.ZERO else merged.merge(aabb)
	return merged.size.y

# Personagens KayKit 2.0 vêm sem AnimationPlayer; as animações moram em GLBs
# próprios. Transplanta a AnimationLibrary de cada um para um player novo no
# personagem — as duas cenas têm a mesma hierarquia, os tracks resolvem.
func _setup_animations(model: Node3D) -> void:
	_anim_player = AnimationPlayer.new()
	_anim_player.name = "AnimationPlayer"
	model.add_child(_anim_player)
	for lib_name: String in ANIM_LIBS:
		var packed := load(ANIM_LIBS[lib_name]) as PackedScene
		if packed == null:
			push_warning("[Avatar] biblioteca de animação ausente: %s" % ANIM_LIBS[lib_name])
			continue
		var donor := packed.instantiate()
		var donor_player := donor.find_child("AnimationPlayer", true, false) as AnimationPlayer
		if donor_player != null:
			for sub_name in donor_player.get_animation_library_list():
				_anim_player.add_animation_library(lib_name,
						donor_player.get_animation_library(sub_name))
		donor.free()
	play(idle_animation)

func _build_procedural() -> void:
	_box("LegL", Vector3(-0.10, 0.25, 0.0), Vector3(0.16, 0.50, 0.16), pants_color)
	_box("LegR", Vector3(0.10, 0.25, 0.0), Vector3(0.16, 0.50, 0.16), pants_color)
	_box("Torso", Vector3(0.0, 0.78, 0.0), Vector3(0.40, 0.56, 0.24), shirt_color)
	_box("ArmL", Vector3(-0.27, 0.75, 0.0), Vector3(0.12, 0.50, 0.14), shirt_color)
	_box("ArmR", Vector3(0.27, 0.75, 0.0), Vector3(0.12, 0.50, 0.14), shirt_color)
	_box("Head", Vector3(0.0, 1.20, 0.0), Vector3(0.24, 0.26, 0.24), skin_color)
	_box("Helmet", Vector3(0.0, 1.36, 0.0), Vector3(0.30, 0.10, 0.30), helmet_color)

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
