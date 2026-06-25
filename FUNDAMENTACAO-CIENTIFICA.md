# Fundamentação Científica — Paradoxo da Relatividade

> Aprofundamento conceitual, físico e bibliográfico do instrumento. O [`README.md`](README.md)
> cobre a arquitetura técnica do software; este documento cobre a **física e a pedagogia** que
> a justificam.

---

## 1. Artigo de Referência Principal

**Alencar, G., Macedo, J., Maranhão, L., & Carneiro, P. (2023).** *Paradoxos da Relatividade*.
arXiv:2307.05503v1 [physics.pop-ph]. Departamento de Física, Universidade Federal do Ceará.

Este artigo é a **referência cirúrgica** do projeto. Toda decisão pedagógica deve voltar a ele.
Texto extraído para consulta rápida em [`docs/referencia_principal.txt`](docs/referencia_principal.txt)
(PDF em `docs/referencia_principal.pdf`).

---

## 2. Equações Fundamentais Utilizadas

**Fator de Lorentz:**
```
γ = 1 / √(1 - v²/c²)
```

**Transformações de Lorentz (diferenças):**
```
Δx' = γ(Δx - vΔt)
Δt' = γ(Δt - vΔx/c²)
Δy' = Δy
Δz' = Δz
```

**Transformações inversas:**
```
Δx = γ(Δx' + vΔt')
Δt = γ(Δt' + vΔx'/c²)
```

**Contração de Lorentz:**
```
L = L₀ / γ
```
(onde L₀ é o comprimento próprio, medido no referencial de repouso do objeto)

**Dilatação do tempo:**
```
Δt = γ·Δτ
```
(onde Δτ é o tempo próprio)

> Implementação: `scripts/lorentz_transform.gd` (`gamma()`, `contracted_length()`,
> `simultaneity_offset()`).

---

## 3. Conceitos-Chave Que Devem Ser Sentidos Pelo Aluno

1. **Simultaneidade relativa**: Δt' = γ(Δt - vΔx/c²) — eventos simultâneos em S não são em S'
2. **Contração anisotrópica**: contrai apenas na direção do movimento
3. **Velocidade limite da informação**: nada material/informacional supera c
4. **Distinção ponto material vs ponto geométrico**: o segundo pode "se mover" mais rápido que c

---

## 4. Concepções Galileanas a Serem Abandonadas

Conforme o artigo de Alencar et al. (2023), três conceitos galileanos arraigados precisam ser desfeitos:

- **Simultaneidade absoluta** (mesmo "agora" em todos os referenciais)
- **Rigidez dos corpos extensos** (corpos respondem instantaneamente a forças)
- **Propagação instantânea de sinais** (causalidade sem limite de velocidade)

---

## 5. Os Paradoxos em Detalhe

Dos sete paradoxos discutidos no artigo de Alencar et al. (2023), três foram selecionados após
análise de potencial pedagógico, viabilidade técnica e impacto visual. Apenas dois entrarão na
apresentação final de 20 minutos.

### 5.1 PARADOXO PRINCIPAL — A Madeireira Relativística

**Referência no artigo**: Seção III.A, p. 5-6.

**Descrição**: Uma tora de madeira de comprimento próprio L₀ desliza sobre uma esteira a velocidade v. Duas guilhotinas, com distância própria L₀ entre si, descem simultaneamente no referencial da esteira (Alice).

- **No referencial de Alice (S)**: a tora está contraída para L₀/γ, cabe entre as guilhotinas, e passa sem ser cortada.
- **No referencial da tora (Bob/S')**: a tora tem comprimento L₀, mas a distância entre as guilhotinas é L₀/γ. A tora não caberia.

**Resolução**: No referencial de Bob, as guilhotinas **não descem simultaneamente**. A diferença temporal é Δt' = γL₀v/c². A guilhotina da direita desce primeiro, a tora continua se movendo, e a da esquerda desce depois — quando a tora já passou.

**Por que este é o paradoxo central do projeto**:
- Unidimensional: geometricamente trivial
- Resultado binário e visceral (tora cortada ou não)
- Força a troca de referencial como mecânica
- Ensina três conceitos centrais (contração, simultaneidade, consistência entre referenciais)
- MVP mais simples de implementar

**Tempo na apresentação**: ~14 minutos (Atos 0-3)

### 5.2 PARADOXO CLÍMAX — Tesouras Superluminais

**Referência no artigo**: Seção VI, p. 11-12.

**Descrição**: Duas lâminas (ou um par de retas) se cruzam. À medida que o ângulo entre elas diminui, o ponto de cruzamento move-se ao longo do eixo com velocidade que pode exceder c.

**Relação geométrica**:
```
v_ponto_corte = ω · L · csc²(θ)
```
onde ω é a velocidade angular constante, L a distância da dobradiça, e θ o ângulo entre as lâminas.

**Resolução**: O ponto de corte **não é um objeto material**. Não carrega informação, massa ou energia. Cada ponto de cruzamento é um evento local independente. Não há ligação causal entre eventos sucessivos do "ponto", então não há violação de causalidade.

**Por que este é o clímax**:
- Pergunta de gancho instantâneo ("algo pode ir mais rápido que a luz?")
- Implementação trivial (puramente geométrica)
- Conexão com astronomia real (jatos relativísticos aparentes)
- Insight filosófico profundo sobre causalidade

**Tempo na apresentação**: ~3 minutos (Ato 4)

### 5.3 PARADOXO DESCARTADO (mas documentado) — Barra e Fenda 2D

**Referência no artigo**: Seção IV.A, p. 7-9.

Visualmente espetacular (rotação relativística), mas exige tempo de setup conceitual incompatível com 20 minutos. **Documentado para possível expansão futura ou versão de TCC**.

### 5.4 EXPANSÃO FUTURA — Barra e Fenda com Gravidade

**Referência no artigo**: Seção IV.B.

Variação do Barra e Fenda em que a barra cai sob gravidade enquanto cruza a fenda: a resolução combina contração de Lorentz com a inclinação relativística da barra no referencial da fenda. Mais rico que o IV.A, porém com os mesmos custos de setup conceitual — fica na fila atrás das tesouras superluminais (Bloco C), candidato natural a versão de TCC.

---

## 6. Glossário Técnico

| Termo | Definição |
|---|---|
| **Referencial inercial** | Sistema de coordenadas em movimento retilíneo uniforme |
| **Comprimento próprio (L₀)** | Comprimento medido no referencial de repouso do objeto |
| **Tempo próprio (τ)** | Tempo medido por um relógio em repouso no mesmo ponto |
| **Fator de Lorentz (γ)** | γ = 1/√(1-v²/c²), sempre ≥ 1 |
| **Contração de Lorentz** | L = L₀/γ, contração na direção do movimento |
| **Dilatação do tempo** | Δt = γ·Δτ, tempo dilatado para observador externo |
| **Simultaneidade relativa** | Eventos simultâneos em um referencial podem não ser em outro |
| **Cone de luz** | Estrutura causal no espaço-tempo de Minkowski |
| **Linha de mundo** | Trajetória de um objeto no espaço-tempo |
| **Frame (no código)** | Sinônimo de referencial inercial; valores: ALICE ou BOB |
| **β (beta)** | Velocidade em frações de c (β = v/c, varia de 0 a 1) |

---

## 7. Referências

### 7.1 Referência Principal

[1] **Alencar, G., Macedo, J., Maranhão, L., & Carneiro, P. (2023).** *Paradoxos da Relatividade*. arXiv:2307.05503v1 [physics.pop-ph]. Departamento de Física, Universidade Federal do Ceará.

### 7.2 Referências Secundárias (Citadas no Artigo Principal)

[2] Rindler, W. (2006). *Relativity: Special, General, and Cosmological* (2ª ed.). Oxford University Press.

[3] Alencar, G. (2023). *Alice no País da Relatividade: teoria da relatividade para o ensino médio*. Editora Livraria da Física: São Paulo. ISBN: 978-65-5563-322-1.

[4] Langevin, P. (1911). Scientia, 10, 31-54.

[5] Rindler, W. (1961). *American Journal of Physics*, 29, 365-366. [Paradoxo da Barra e Fenda com Gravidade]

[6] Shaw, R. (1962). *American Journal of Physics*, 30, 72. [Paradoxo da Barra e Fenda sem Gravidade]

[7] Dewan, E. M. (1963). *American Journal of Physics*, 31, 383-386. [Paradoxo do Celeiro e Barra]

[11] Taylor, E. F., & Wheeler, J. A. (1992). *Spacetime Physics: Introduction to Special Relativity*. W. H. Freeman.

[14] Pierce, E. (2007). *American Journal of Physics*, 75, 610. [Paradoxo da Chave e Fechadura]

[24] Rothman, M. A. (1960). *Scientific American*, 203, 142-153. [Paradoxo das Tesouras]

[26] Kaushal, N., & Nemiroff, R. J. (2019). *Physics Education*, 54(6), 065008. [Análise moderna das tesouras]

---

*Companheiro do [`README.md`](README.md) (referência técnica). As referências de inspiração
visual/game design e as ferramentas utilizadas permanecem no `README.md`.*
