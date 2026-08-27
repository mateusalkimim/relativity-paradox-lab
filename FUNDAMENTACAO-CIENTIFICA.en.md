<!-- idioma: linha gerada por i18n.py -->
*[Leia em português](FUNDAMENTACAO-CIENTIFICA.en.md)*

# Scientific Foundation — Relativity Paradox

> Conceptual, physical, and bibliographic deepening of the instrument. The [`README.md`](README.en.md)  
> covers the technical architecture of the software; this document covers the **physics and pedagogy**  
> that justify it.

---

## 1. Primary Reference Article

**Alencar, G., Macedo, J., Maranhão, L., & Carneiro, P. (2023).** *Paradoxos da Relatividade* [Paradoxes of Relativity].
arXiv:2307.05503v1 [physics.pop-ph]. Departamento de Física, Universidade Federal do Ceará.

This article is the **surgical reference** of the project. Every pedagogical decision should refer back to it.  
Text extracted for quick consultation in [`docs/referencia_principal.txt`](docs/referencia_principal.txt)  
(PDF in `docs/referencia_principal.pdf`).

---

## 2. Fundamental Equations Used

**Lorentz Factor:**  
```
γ = 1 / √(1 - v²/c²)
```

**Lorentz Transformations (differences):**  
```
Δx' = γ(Δx - vΔt)
Δt' = γ(Δt - vΔx/c²)
Δy' = Δy
Δz' = Δz
```

**Inverse Transformations:**  
```
Δx = γ(Δx' + vΔt')
Δt = γ(Δt' + vΔx'/c²)
```

**Lorentz Contraction:**  
```
L = L₀ / γ
```  
(where L₀ is the proper length, measured in the object's rest frame)

**Time Dilation:**  
```
Δt = γ·Δτ
```
(where Δτ is the proper time)

> Implementation: `scripts/lorentz_transform.gd` (`gamma()`, `contracted_length()`,  
> `simultaneity_offset()`).

---

## 3. Key Concepts That Should Be Understood by the Student

1. **Relative Simultaneity**: Δt' = γ(Δt - vΔx/c²) — events simultaneous in S are not in S'  
2. **Anisotropic Contraction**: contracts only in the direction of motion  
3. **Speed Limit of Information**: nothing material/informational exceeds c  
4. **Distinction between Material Point vs Geometric Point**: the latter can "move" faster than c

---

## 4. Galilean Conceptions to Be Abandoned

As per the article by Alencar et al. (2023), three ingrained Galilean concepts need to be undone:

- **Absolute simultaneity** (same "now" in all reference frames)  
- **Rigidity of extended bodies** (bodies respond instantaneously to forces)  
- **Instant propagation of signals** (causality without speed limit)

---

## 5. The Paradoxes in Detail

Of the seven paradoxes discussed in the article by Alencar et al. (2023), three were selected after analysis of pedagogical potential, technical feasibility, and visual impact. Only two will be included in the final 20-minute presentation.

### 5.1 PARADOX — The Relativistic Sawmill

**Reference in the article**: Section III.A, p. 5-6.

**Description**: A log of wood of proper length L₀ slides over a conveyor belt at speed v. Two guillotines, with proper distance L₀ between them, descend simultaneously in the conveyor belt's reference frame (Alice).

- **In Alice's reference frame (S)**: the bar is contracted to L₀/γ, fits between the guillotines, and passes without being cut.  
- **In the bar's reference frame (Bob/S')**: the bar has length L₀, but the distance between the guillotines is L₀/γ. The bar would not fit.

**Resolution**: In Bob's reference frame, the saws **do not descend simultaneously**. The time difference is Δt' = γL₀v/c². The right saw descends first, the log continues moving, and the left saw descends later — when the log has already passed.

**Why this is the central paradox of the project**:  
- One-dimensional: geometrically trivial  
- Binary and visceral result (torus cut or not)  
- Forces reference frame change as mechanics  
- Teaches three central concepts (contraction, simultaneity, consistency between reference frames)  
- Simplest MVP to implement

**Time in Presentation**: ~14 minutes (Acts 0-3)

### 5.2 CLIMAX PARADOX — Superluminal Scissors

**Reference in the article**: Section VI, p. 11-12.

**Description**: Two blades (or a pair of lines) intersect. As the angle between them decreases, the intersection point moves along the axis with a velocity that can exceed c.

**Geometric Relation:**  
```
v_ponto_corte = ω · L · csc²(θ)
```  
where ω is the constant angular velocity, L the distance from the hinge, and θ the angle between the blades.

**Resolution**: The cut point **is not a material object**. It does not carry information, mass, or energy. Each crossing point is a local independent event. There is no causal link between successive "point" events, so there is no violation of causality.

**Why this is the climax**:  
- Instant hook question ("Can something go faster than light?")  
- Trivial implementation (purely geometric)  
- Connection with real astronomy (apparent relativistic jets)  
- Deep philosophical insight into causality

**Time in Presentation**: ~3 minutes (Act 4)

### 5.3 PARADOX DISCARDED (but documented) — Bar and Slit 2D

**Reference in the article**: Section IV.A, p. 7-9.

Visually spectacular (relativistic rotation), but requires conceptual setup time incompatible with 20 minutes. **Documented for possible future expansion or thesis version**.

### 5.4 FUTURE EXPANSION — Slit-and-Gravitational-Field

**Reference in the article**: Section IV.B.

Bar and Slit Variation in which the bar falls under gravity while crossing the slit: the resolution combines Lorentz contraction with the relativistic tilt of the bar in the slit's reference frame. Richer than IV.A, yet with the same conceptual setup costs — stays in line behind the superluminal scissors (Block C), natural candidate for a thesis version.

---

## 6. Technical Glossary

| Term | Definition |
|---|---|
| **Inertial Frame** | A coordinate system in uniform rectilinear motion |
| **Proper Length (L₀)** | Length measured in the object's rest frame |
| **Proper Time (τ)** | Time measured by a clock at rest at the same point |
| **Lorentz Factor (γ)** | γ = 1/√(1-v²/c²), always ≥ 1 |
| **Lorentz Contraction** | L = L₀/γ, contraction in the direction of motion |
| **Time Dilation** | Δt = γ·Δτ, time dilated for an external observer |
| **Relative Simultaneity** | Events simultaneous in one frame may not be in another |
| **Light Cone** | Causal structure in Minkowski spacetime |
| **Worldline** | Trajectory of an object in spacetime |
| **Frame (in code)** | Synonym for inertial frame; values: ALICE or BOB |
| **β (beta)** | Speed in fractions of c (β = v/c, varies from 0 to 1) |

---

## 7. References

### 7.1 Primary Reference

[1] **Alencar, G., Macedo, J., Maranhão, L., & Carneiro, P. (2023).** *Paradoxos da Relatividade* [Paradoxes of Relativity]. arXiv:2307.05503v1 [physics.pop-ph]. Departamento de Física, Universidade Federal do Ceará.

### 7.2 Secondary References (Cited in the Main Article)

[2] Rindler, W. (2006). *Relativity: Special, General, and Cosmological* (2nd ed.). Oxford University Press.

[3] Alencar, G. (2023). *Alice no País da Relatividade: teoria da relatividade para o ensino médio* [Alice in the Land of Relativity: relativity for high school]. Editora Livraria da Física: São Paulo. ISBN: 978-65-5563-322-1.

[4] Langevin, P. (1911). Scientia, 10, 31-54.

[5] Rindler, W. (1961). *American Journal of Physics*, 29, 365-366. [Slit-and-Gravitational-Field Paradox]

[6] Shaw, R. (1962). *American Journal of Physics*, 30, 72. [Twin Paradox without Gravity]

[7] Dewan, E. M. (1963). *American Journal of Physics*, 31, 383-386. [Barn-and-Bar Paradox]

[11] Taylor, E. F., & Wheeler, J. A. (1992). *Spacetime Physics: Introduction to Special Relativity*. W. H. Freeman.

[14] Pierce, E. (2007). *American Journal of Physics*, 75, 610. [Key and Lock Paradox]

[24] Rothman, M. A. (1960). *Scientific American*, 203, 142-153. [Scissors Paradox]

[26] Kaushal, N., & Nemiroff, R. J. (2019). *Physics Education*, 54(6), 065008. [Modern analysis of scissors]

---

*Companion to [`README.md`](README.en.md) (technical reference). The visual/game design inspirations and tools used remain in `README.md`.*