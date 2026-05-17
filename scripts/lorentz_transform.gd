class_name LorentzTransform

const C: float = 1.0
const BETA_MAX: float = 0.99

static func gamma(beta: float) -> float:
	var b := clamp(beta, 0.0, BETA_MAX)
	return 1.0 / sqrt(1.0 - b * b)

static func contracted_length(proper_length: float, beta: float) -> float:
	return proper_length / gamma(beta)

# Δt' = γ·L₀·v/c² — offset temporal entre guilhotinas no referencial da tora
# Alencar et al. (2023), Seção III.A, p. 5-6
static func simultaneity_offset(proper_separation: float, beta: float) -> float:
	return gamma(beta) * proper_separation * beta / (C * C)

static func dilated_time(proper_time: float, beta: float) -> float:
	return gamma(beta) * proper_time
