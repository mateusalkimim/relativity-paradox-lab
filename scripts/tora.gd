# scripts/tora.gd
extends Node3D
class_name Tora

# 1. Constantes
# 8 lados: mínimo para ser lida como cilindro com o look faceted low-poly desejado.
# Menos de 8 parece poligonal demais; mais de 8 perde o caráter low-poly.
const RADIAL_SEGMENTS: int = 8

# 2. Exportadas
# L₀: comprimento próprio medido no referencial de repouso da tora (seção 2.2 do README).
# frame_controller.gd aplica scale.x = 1/γ no Node3D raiz desta cena.
# O pivot está no centro geométrico: a contração ocorre simetricamente em ambas as pontas,
# o que é fisicamente correto (L = L₀/γ centrado no mesmo ponto médio).
@export var rest_length: float = 4.0
@export var diameter: float = 0.5

# 6. Onready
@onready var _mesh: MeshInstance3D = $Mesh

# 7. Funções built-in
func _ready() -> void:
	# Pivot no centro geométrico: scale.x = 1/γ contrai simetricamente nos dois lados
	print("[Tora] L₀=%.1f u  diâmetro=%.1f u" % [rest_length, diameter])

# 8. Funções públicas

# Contrai visualmente para o referencial de Alice: scale.x = 1/γ.
# Chamado pelo frame_controller; não anima — aplica estado final para o Tween interpolar.
func set_lorentz_scale(gamma: float) -> void:
	scale.x = 1.0 / gamma

# Restaura comprimento próprio ao entrar no referencial de Bob (tora em repouso).
func reset_lorentz_scale() -> void:
	scale.x = 1.0
