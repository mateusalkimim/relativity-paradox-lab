# Paradoxo da Relatividade — Instrumento Interativo de Ensino

> Uma experiência interativa em primeira pessoa para apresentação ao vivo, projetada para ensinar paradoxos da Relatividade Restrita a estudantes do ensino médio através de demonstração teatral conduzida por um orientador.

---

## Sumário

1. [Visão Geral do Projeto](#1-visão-geral-do-projeto)
2. [Fundamentação Científica](#2-fundamentação-científica)
3. [Paradoxos Selecionados](#3-paradoxos-selecionados)
4. [Arquitetura da Apresentação](#4-arquitetura-da-apresentação)
5. [Stack Técnica](#5-stack-técnica)
6. [Estrutura do Projeto](#6-estrutura-do-projeto)
7. [Sistemas Centrais](#7-sistemas-centrais)
8. [Diretrizes Visuais](#8-diretrizes-visuais)
9. [Roadmap de Desenvolvimento](#9-roadmap-de-desenvolvimento)
10. [Princípios de Execução](#10-princípios-de-execução)
11. [Convenções de Código](#11-convenções-de-código)
12. [Glossário Técnico](#12-glossário-técnico)
13. [Referências](#13-referências)

---

## 1. Visão Geral do Projeto

### 1.1 Natureza do Projeto

Este **não é um jogo no sentido tradicional**. É um **instrumento de palco**: uma ferramenta de software interativa operada ao vivo por um orientador/professor, enquanto a audiência (estudantes do ensino médio) assiste em uma tela grande. O modelo mental correto é o de um *planetário portátil de relatividade* ou um *experimento científico moderno* — análogo às demonstrações de Faraday no século XIX, modernizadas.

### 1.2 Formato da Apresentação

- **Duração**: 20 minutos
- **Audiência**: Estudantes do ensino médio (~14-17 anos)
- **Operador**: Um único professor/orientador conduzindo
- **Controle**: Gamepad Xbox (não teclado/mouse durante apresentação)
- **Tela**: Projetor ou TV grande
- **Sem dependência de internet**: executável standalone

### 1.3 Filosofia de Design

- **Teatro sobre simulação**: quando física exata brigar com clareza visual, clareza visual ganha
- **Sem UI textual pesada**: a voz do orientador substitui menus e tutoriais
- **Mecânica única e forte**: a *troca de referencial* é o coração da experiência
- **Sandbox controlado**: o orientador pode pausar, ajustar, repetir, responder perguntas em tempo real
- **Coerência visual**: 3D low-poly + sprites pixel art com paleta unificada

### 1.4 Objetivos Pedagógicos

Ao final da apresentação, o estudante deve ter:

1. Abandonado a **simultaneidade absoluta** como conceito intuitivo
2. Compreendido visualmente a **contração de Lorentz**
3. Entendido que objetos rígidos **não existem** na relatividade
4. Aceitado que **velocidades superluminais aparentes** existem sem violar causalidade
5. Reconhecido que descrições diferentes do mesmo evento físico podem coexistir consistentemente

---

## 2. Fundamentação Científica

### 2.1 Artigo de Referência Principal

**Alencar, G., Macedo, J., Maranhão, L., & Carneiro, P. (2023).** *Paradoxos da Relatividade*. arXiv:2307.05503v1 [physics.pop-ph]. Departamento de Física, Universidade Federal do Ceará.

Este artigo é a **referência cirúrgica** do projeto. Toda decisão pedagógica deve voltar a ele.

### 2.2 Equações Fundamentais Utilizadas

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

### 2.3 Conceitos-Chave Que Devem Ser Sentidos Pelo Aluno

1. **Simultaneidade relativa**: Δt' = γ(Δt - vΔx/c²) — eventos simultâneos em S não são em S'
2. **Contração anisotrópica**: contrai apenas na direção do movimento
3. **Velocidade limite da informação**: nada material/informacional supera c
4. **Distinção ponto material vs ponto geométrico**: o segundo pode "se mover" mais rápido que c

### 2.4 Concepções Galileanas a Serem Abandonadas

Conforme o artigo de Alencar et al. (2023), três conceitos galileanos arraigados precisam ser desfeitos:

- **Simultaneidade absoluta** (mesmo "agora" em todos os referenciais)
- **Rigidez dos corpos extensos** (corpos respondem instantaneamente a forças)
- **Propagação instantânea de sinais** (causalidade sem limite de velocidade)

---

## 3. Paradoxos Selecionados

Dos sete paradoxos discutidos no artigo de Alencar et al. (2023), três foram selecionados após análise de potencial pedagógico, viabilidade técnica e impacto visual. Apenas dois entrarão na apresentação final de 20 minutos.

### 3.1 PARADOXO PRINCIPAL — A Madeireira Relativística

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

### 3.2 PARADOXO CLÍMAX — Tesouras Superluminais

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

### 3.3 PARADOXO DESCARTADO (mas documentado) — Barra e Fenda 2D

**Referência no artigo**: Seção IV.A, p. 7-9.

Visualmente espetacular (rotação relativística), mas exige tempo de setup conceitual incompatível com 20 minutos. **Documentado para possível expansão futura ou versão de TCC**.

### 3.4 EXPANSÃO FUTURA — Barra e Fenda com Gravidade

**Referência no artigo**: Seção IV.B.

Variação do Barra e Fenda em que a barra cai sob gravidade enquanto cruza a fenda: a resolução combina contração de Lorentz com a inclinação relativística da barra no referencial da fenda. Mais rico que o IV.A, porém com os mesmos custos de setup conceitual — fica na fila atrás das tesouras superluminais (Bloco C), candidato natural a versão de TCC.

---

## 4. Arquitetura da Apresentação

### 4.1 Estrutura Narrativa (20 minutos)

#### **Ato 0 — Apresentação do Mundo Galileano** (2 min)

- Cena abre lentamente no galpão da madeireira
- Esteira parada, tora parada, guilhotinas paradas
- Orientador caminha em primeira pessoa, estabelece dimensões
- Liga a esteira em **velocidade baixa** (0.05c)
- Tora passa, é cortada normalmente
- **Função**: estabelecer normalidade galileana antes da quebra

#### **Ato 1 — A Aceleração** (5 min)

- Orientador aumenta velocidade da esteira (D-Pad Up)
- v = 0.3c → 0.5c → 0.7c
- Contração de Lorentz começa a ser visível
- v = 0.9c: tora passa pelas guilhotinas com folga clara
- Audiência aceita: "ok, ela passou"

#### **Ato 2 — O Paradoxo** (6 min)

- "E se eu subisse na esteira?"
- **Troca de referencial** (Bumper Esquerdo — LB)
- Transição animada de ~2 segundos
- Mundo se reconfigura: tora volta a L₀, galpão e guilhotinas contraem
- A tora **não cabe** entre as guilhotinas
- Cliffhanger: "ela deveria ser cortada — mas vocês viram passar"

#### **Ato 3 — Resolução pela Simultaneidade** (4 min)

- Ativação do **modo overlay** (Botão Y)
- Linhas de simultaneidade aparecem como sprites pixel art
- Replay em câmera lenta (Botão X)
- No referencial de Bob, guilhotinas descem em momentos diferentes
- Guilhotina direita primeiro → tora segue → guilhotina esquerda depois (tora já saiu)
- Retorno ao referencial de Alice: tudo simultâneo
- Mensagem: "o que muda não é o que acontece. É o que significa 'ao mesmo tempo'."

#### **Ato 4 — Clímax Cósmico (Tesouras)** (3 min)

- Transição para segundo cenário (observatório cósmico, paleta noturna)
- Duas lâminas cruzando
- Orientador manipula ângulo
- Velocímetro do ponto de corte: 0.5c → 0.9c → c → 2c → 10c
- Visualização do cone de luz mostrando que causalidade está preservada
- Encerramento

### 4.2 Mapeamento de Controle Xbox

| Input | Função |
|---|---|
| Analógico Esquerdo | Movimento (WASD) |
| Analógico Direito | Olhar (mouse look) |
| Bumper Esquerdo (LB) | **Trocar referencial** |
| D-Pad ↑ | Aumentar velocidade da esteira |
| D-Pad ↓ | Diminuir velocidade da esteira |
| Gatilho Direito (RT) | Acionar guilhotinas / Ação principal |
| Botão Y | Toggle overlay (linhas de simultaneidade) |
| Botão X | Pausar / Câmera lenta |
| Botão B | Reset da cena |
| Botão View | Toggle vista isométrica / primeira pessoa |
| Botão Menu | Próxima cena (Tesouras) |

---

## 5. Stack Técnica

### 5.1 Tecnologias Confirmadas

- **Engine**: Godot 4.x
- **Linguagem**: GDScript
- **Plataformas-alvo**: Windows e Linux (executável standalone nas duas)
- **Ambiente de desenvolvimento**: AlmaLinux 9.8 (GNOME X11) — desenvolvimento primário
- **Controle**: Gamepad Xbox (testado nativamente no Godot 4)
- **Versionamento**: Git
- **Geração de assets 3D**: Hyper3D.ai (Rodin) — exportação em GLB
- **Personagens e animações**: KayKit (Kay Lousberg, kaylousberg.com) — CC0; Adventurers 2.0 FREE + Character Animations 1.1 (Rig_Medium), extraídos em `assets/models/characters/` (zips originais em `assets/packages/`, fora do versionamento)
- **Geração de assets 2D**: PixelLab.ai — pixel art para sprites
- **Pipeline de áudio**: a definir (Freesound, geração própria)

### 5.2 Decisões Arquiteturais

**Implementação da contração de Lorentz**: **Caminho A — Contração Lógica** (não shader-based)
- Duas representações do mundo (referencial S e S')
- Ao trocar de frame, animar transição entre estados pré-calculados
- Mais simples, mais previsível, suficiente para o show
- Caminho B (shaders) descartado para evitar 2 semanas de debug

**Velocidade da luz no jogo**: `C = 1.0` unidade/segundo

**Escala do mundo**:
- Galpão: ~20 unidades de comprimento
- Tora: 4 unidades (comprimento próprio L₀)
- Distância entre guilhotinas: 4 unidades (comprimento próprio L₀)
- Velocidade máxima visualmente utilizada: 0.99c

### 5.3 Compatibilidade Cross-Platform (Restrição Rígida)

O executável final deve rodar em **Windows e Linux** sem modificações. Apresentações acontecem em escolas (tipicamente Windows); desenvolvimento ocorre em AlmaLinux 9.8.

**Regras que se aplicam ao código:**
- **Caminhos de arquivo**: usar exclusivamente `res://`, `user://` e APIs do Godot (`OS.get_user_data_dir()`, `ProjectSettings.globalize_path()`). Nunca caminhos absolutos do sistema operacional.
- **Nomes de asset**: apenas caracteres ASCII sem acentos ou espaços — sistemas Windows são case-insensitive e têm restrições de caracteres que o Linux não tem.
- **Chamadas de sistema** (`OS.execute`, `OS.shell_open`): só usar se testado nas duas plataformas.
- **Export templates**: ao chegar na Semana 5, gerar templates para `Windows Desktop` (.exe) e `Linux/X11` (.x86_64) a partir do mesmo projeto.
- **Gamepad Xbox**: funciona nativamente via XInput (Windows). No Linux, controle **com fio** funciona via SDL/xpad sem configuração; receptor **USB sem fio (dongle)** requer o driver `xone` (DKMS) — instalar com `sudo bash setup-xbox-linux.sh` (AlmaLinux 9 / RHEL). Sem código condicional de plataforma no Godot.

### 5.4 Ambiente de Desenvolvimento

| Ferramenta | Versão | Instalação |
|---|---|---|
| Godot 4 | 4.6.3 stable | Flatpak (usuário) — `godot4` |
| VS Code | 1.122.0 | Flatpak (usuário) — `code` |
| godot-tools | 2.6.1 | Extensão VS Code |
| Claude Code | — | `~/.local/bin/claude` |
| Driver xone (dongle Xbox) | DKMS | `sudo bash setup-xbox-linux.sh` (deps: dkms, kernel-devel, git, cabextract) |

**Launcher**: `~/Área de trabalho/Lab Relatividade.desktop` — abre Godot → aguarda LSP (porta 6005) → VS Code → terminal com Claude Code, tudo no diretório do projeto. Se o terminal com Claude já estiver aberto, foca a janela existente em vez de abrir uma nova.

**Nota Flatpak**: VS Code e Godot rodam em sandboxes separadas. A comunicação entre eles (abrir arquivo no editor externo) usa o wrapper `~/.local/bin/godot4-vscode` via `flatpak-spawn --host`. O Language Server conecta normalmente via localhost:6005.

---

## 6. Estrutura do Projeto

```
ParadoxoRelatividade/
├── README.md                       # Este arquivo
├── .gitignore                      # Git ignore para Godot 4
├── project.godot                   # Arquivo principal do Godot
│
├── scenes/
│   ├── main.tscn                   # Cena raiz, entrada do jogo
│   ├── world/
│   │   ├── galpao.tscn             # Cenário da madeireira (Atos 0-3)
│   │   ├── esteira.tscn            # Esteira transportadora (Esteira class, UV scroll)
│   │   ├── tora.tscn               # Tora reutilizável (CylinderMesh procedural, L₀=4u)
│   │   └── observatorio.tscn       # Cenário das tesouras (Ato 4)
│   └── player/
│       └── player.tscn             # Câmera primeira pessoa + movimento
│
├── scripts/
│   ├── input_manager.gd            # Autoload: abstração de input
│   ├── game_state.gd               # Autoload: estado global
│   ├── player.gd                   # Movimento + câmera
│   ├── frame_controller.gd         # Lógica de troca de referencial
│   ├── lorentz_transform.gd        # Cálculos relativísticos (γ, contração, offset temporal)
│   ├── esteira.gd                  # Esteira transportadora (UV scroll, instancia tora.tscn)
│   ├── conveyor_belt.gd            # Legado — substituído por esteira.gd/esteira.tscn
│   ├── tora.gd                     # Tora: @export L₀, diâmetro; set_lorentz_scale() pronto
│   ├── guillotine.gd               # Comportamento das guilhotinas
│   ├── hud.gd                      # HUD: velocímetro, indicador de γ e referencial
│   ├── simultaneity_lines.gd       # Overlay de linhas de simultaneidade
│   └── scissors.gd                 # Lógica das tesouras (Ato 4)
│
├── assets/
│   ├── models/                     # .glb gerados no Hyper3D
│   │   ├── galpao_estrutura.glb    # ✅ integrado com colisão trimesh
│   │   ├── tora.glb                # presente; tora usa cena procedural (tora.tscn)
│   │   ├── esteira.glb             # pendente
│   │   ├── guilhotina.glb          # pendente
│   │   └── observatorio.glb        # pendente
│   ├── textures/                   # Texturas auxiliares
│   │   └── hdri_galpao.hdr         # HDRI equiretangular para skydome do galpão
│   ├── sprites/                    # Pixel art (PixelLab)
│   │   ├── hud_velocimetro.png
│   │   ├── linha_simultaneidade.png
│   │   └── indicador_gamma.png
│   └── audio/
│       ├── music/
│       └── sfx/
│
├── shaders/                        # Reservado para Fase 3+ (opcional)
│
└── docs/
    ├── apresentacao_script.md      # Script narrado da apresentação
    └── referencias.md              # Referências bibliográficas extras
```

---

## 7. Sistemas Centrais

### 7.1 Sistema de Referencial (`game_state.gd` + `frame_controller.gd`)

**Responsabilidade**: Gerenciar o referencial ativo (ALICE ou BOB) e disparar transições visuais ao trocar.

**Estados possíveis**:
- `Frame.ALICE`: referencial de repouso da esteira (galpão estacionário)
- `Frame.BOB`: referencial de repouso da tora (esteira em movimento aparente)

**Operações**:
- `toggle_frame()`: alterna referencial atual
- `get_gamma()`: retorna fator de Lorentz baseado em `belt_velocity_fraction`
- `is_transitioning`: bloqueia inputs durante transição animada
- Sinais: `frame_changed`, `velocity_changed`

### 7.2 Sistema de Transformação Visual

**Função**: Aplicar contração visual nos objetos conforme referencial e velocidade.

**Em `Frame.ALICE`**:
- Tora visualmente contraída: `tora.scale.x = 1.0 / gamma`
- Galpão e guilhotinas em escala normal
- Guilhotinas descem simultaneamente

**Em `Frame.BOB`**:
- Tora em escala normal: `tora.scale.x = 1.0`
- Galpão e guilhotinas contraídos: `scale.x = 1.0 / gamma`
- Guilhotinas descem com offset temporal `Δt' = γ·L₀·v/c²`

**Transição entre frames**:
- Duração: 1.5 a 2.0 segundos
- Easing: `Tween.EASE_IN_OUT`, `Tween.TRANS_CUBIC`
- Bloqueia outros inputs durante transição

### 7.3 Sistema de Simultaneidade (Overlay)

**Função**: Visualizar a relatividade da simultaneidade no Ato 3.

**Implementação**:
- Sprites pixel art 2D sobrepostos ao mundo 3D (via `Sprite3D` ou `Decal`)
- Linhas horizontais flutuantes representando "fatias de tempo"
- No referencial de Alice: linhas paralelas, eventos alinhados
- No referencial de Bob: linhas inclinadas no espaço-tempo

**Ativação**: Botão Y (toggle)

### 7.4 Sistema de Câmera

**Função**: Câmera em primeira pessoa controlável + modo isométrico opcional.

**Modos**:
- **First-person**: padrão durante toda a apresentação
- **Isométrico**: ativado por Botão View — mostra a cena toda como diorama, útil para explicações geométricas

**Detalhes**:
- Yaw aplicado ao `CharacterBody3D` (rotaciona corpo)
- Pitch aplicado ao `CameraPivot` (apenas câmera)
- Sensibilidade configurável (gamepad e mouse separados)
- Clamp de pitch entre -π/2 + 0.05 e π/2 - 0.05
- Input de gamepad ignorado quando nenhum joystick está conectado (evita drift do dongle Xbox sem controle na mão)
- Eventos de mouse descartados por 100 ms após captura e quando delta > 0.5 rad (artefato de warp X11)

**Limitação conhecida**: mouse via AnyDesk não movimenta a câmera — o AnyDesk injeta eventos sintéticos (XTest) que não passam pelo pointer grab do Godot em `MOUSE_MODE_CAPTURED`. Touchpad e mouse USB físicos funcionam normalmente.

### 7.5 Sistema de Esteira e Guilhotinas

**Esteira (`esteira.gd` + `esteira.tscn`)**:
- Velocidade ajustável de 0 a 0.99c (D-Pad ↑↓)
- Movimento visual via UV scroll na textura da correia (sem translação de geometria — estável para contração de Lorentz)
- Instancia `tora.tscn` e a move ao longo do eixo X
- Em `Frame.BOB`, a tora fica parada e o galpão se move

**Guilhotinas (`guillotine.gd`)**:
- Duas instâncias: esquerda e direita
- Estado: `READY`, `FALLING`, `DOWN`, `RETRACTING`
- Em `Frame.ALICE`: descem simultaneamente quando RT é apertado
- Em `Frame.BOB`: descem com offset temporal calculado

### 7.6 Sistema de Tesouras (Ato 4)

**Função**: Visualizar o paradoxo das tesouras superluminais.

**Implementação**:
- Duas linhas (lâminas) em um plano
- Uma estática (eixo X), outra rotacionando em torno de um ponto pivô
- Ponto de corte calculado geometricamente
- Velocímetro do ponto de corte exibido em HUD
- Cone de luz visualizado quando `v_ponto > c`

---

## 8. Diretrizes Visuais

### 8.1 Estilo Visual Híbrido

**3D Low-Poly Flat Shaded para**:
- Cenário (galpão, esteira, paredes, vigas)
- Objetos físicos (tora, guilhotinas, lâminas)
- Personagem em primeira pessoa (apenas mãos visíveis, opcional)

**Pixel Art 2D para**:
- HUD: velocímetro, slider de γ, indicador de referencial
- Linhas de simultaneidade (sobrepostas ao mundo 3D)
- Diagrama de Minkowski (canto da tela, opcional)
- Faíscas, partículas, efeitos de impacto
- Texto pontual ("γ = 4.2", "RT para soltar")

**Justificativa da divisão**:
- 3D representa **fenômeno físico** (coisas que existem no mundo)
- 2D representa **abstrações de medida** (observações, instrumentos, conceitos)
- Essa separação reforça didaticamente a diferença entre realidade e medição

### 8.2 Paleta de Cores

**Cenário 1 — Galpão Madeireira (Atos 0-3)**:
- Madeira: tons quentes terrosos (#8B7355, #A0826D, #6B4423)
- Metal das guilhotinas: cinza azulado (#4A5560, #6B7780)
- Concreto do chão: cinza claro (#9C9C9C)
- Luz ambiente: dourada quente (#FFD89B)

**Cenário 2 — Observatório Cósmico (Ato 4)**:
- Espaço: azul profundo / negro (#0A0E27, #1B2845)
- Lâminas: branco luminoso com brilho (#FFFFFF + bloom)
- Cone de luz: azul ciano translúcido (#00D9FF)
- Estrelas: amarelo pálido (#FFF8DC)

### 8.3 Efeitos de Pós-Processamento

**Globais**:
- SSAO ativado (peso visual no low-poly)
- Bloom suave (especialmente no Ato 4)
- Sombras direcionais 4096px

**Contextual**:
- Motion blur sutil em alta velocidade (v > 0.7c)
- Distorção cromática leve durante transição de referencial
- Vinheta sutil no modo câmera lenta

### 8.4 Prompts de Geração no Hyper3D

**Modificador de estilo padrão** (anexar a todos os prompts):
> `"low poly, flat shaded, no textures, warm earth tones, simple geometry, game-ready, clean topology, 18k quads max"`

**Assets principais a gerar**:

1. **Galpão estrutural**: *"Low poly industrial sawmill warehouse interior, wooden support beams, corrugated metal walls, concrete floor"*

2. **Tora de madeira**: *"Low poly wooden log, cylindrical, bark suggested by faceted geometry, brown and tan colors, 200 polygons max"*

3. **Guilhotina industrial**: *"Low poly industrial guillotine blade mechanism, vertical metal blade in wooden frame, sawmill cutter"*

4. **Esteira transportadora**: *"Low poly conveyor belt with metal rollers, industrial style, dark grey belt, metallic supports"*

5. **Observatório (Ato 4)**: *"Low poly cosmic observatory platform, minimalist circular structure, floating in space, dark blue palette"*

---

## 9. Roadmap de Desenvolvimento

### Semana 1 — Fundação ✅ Concluída

**Objetivos**:
- [x] Setup do projeto Godot 4
- [x] Configuração de Input Map (17 ações)
- [x] Estrutura de pastas
- [x] Git inicializado com `.gitignore`
- [x] Autoloads (`InputBus`, `GameState`) funcionando
- [x] Cena `player.tscn` com câmera FPS funcional
- [x] Cena `galpao.tscn` com primitivos
- [x] Cena `main.tscn` rodando
- [x] Caminhar pelo galpão com Xbox

**Marco**: Caminhar pelo galpão vazio em primeira pessoa.

### Semana 2 — Mundo Galileano ✅ Concluída

**Objetivos**:
- [x] Importar assets do Hyper3D (parcial: `galpao_estrutura.glb` integrado com colisão trimesh; `esteira.glb`, `guilhotina.glb` pendentes)
- [x] Esteira animada com velocidade ajustável (D-Pad ↑↓) — `esteira.gd` + `esteira.tscn` (UV scroll; substitui `conveyor_belt.gd`)
- [x] Tora se movendo ao longo da esteira — instanciada via `esteira.gd`
- [x] `tora.tscn` criada como cena reutilizável — `tora.gd` (CylinderMesh procedural, L₀=4u, diâmetro=0.5; `set_lorentz_scale()` preparado para Semana 3)
- [x] Skydome com HDRI adicionado ao galpão — `galpao.gd`
- [x] Duas guilhotinas descendo ao apertar RT — `guillotine.gd`
- [x] Caso galileano trivial (v baixa) funcionando
- [x] HUD básica: velocímetro texto (β, γ, barra, referencial) — `hud.gd`; sprite pixel art pendente
- [x] Bugfix: `lorentz_transform.gd` — inferência de tipo em `clamp()` tratada como erro (`var b: float`)

**Marco**: Apresentar Atos 0 e início do Ato 1. ✅ Atingido (sem assets Hyper3D).

### Semana 3 — Coração: Troca de Referencial ✅ Concluída

**Objetivos**:
- [x] Lógica de `Frame.ALICE` vs `Frame.BOB` em `GameState`
- [x] Contração de Lorentz aplicada via escala anisotrópica — `frame_controller.gd` (tora `1/γ` em ALICE; grupo `MovingWorld` com galpão+guilhotinas+esteira `1/γ` em BOB)
- [x] Transição animada de 2s com easing (`TRANS_CUBIC`/`EASE_IN_OUT`)
- [x] Indicador de γ na HUD atualizando dinamicamente
- [x] Bloqueio de inputs durante transição (`is_transitioning` guarda frame e velocidade)
- [x] Efeito visual sutil durante transição (tint azulado em pulso senoidal)
- [x] Movimento relativo coerente em BOB: tora em repouso, mundo desliza a -v (chão colisor invisível fixo sustenta o player)

**Marco**: Trocar de referencial e ver o "efeito wow".

### Semana 4 — Simultaneidade e Resolução 🟡 Parcial

**Objetivos**:
- [ ] Sistema de linhas de simultaneidade (sprites pixel art)
- [x] Modo câmera lenta (Botão X) — `Engine.time_scale = 0.25`, desacelera inclusive o offset das guilhotinas (útil no replay do Ato 3)
- [x] Guilhotinas com offset temporal em `Frame.BOB` — direita desce primeiro, esquerda após `Δt' = γ·L₀·v/c²` (convertido pela escala visual)
- [x] Detecção e visual de corte — lâmina cruza o plano da tora, corte geométrico, tora se separa em duas metades animadas; indicador na HUD
- [x] Mira do corte corrigida — o ponto de corte é marcado em coordenada local da tora no instante do gatilho (intenção do operador) e executado quando a lâmina desce; antes a tora andava durante a queda e o corte caía fora da mira. Em BOB cada lâmina marca quando ela dispara, preservando a pedagogia da simultaneidade
- [x] Reset da cena (Botão B) — `reset_session()` + reload
- [x] Cena do paradoxo funcionando completa em ambos os frames
- [x] Avatares Bob e Alice (`avatar.gd`) — Bob viaja na correia atrás da tora (contrai com ela em ALICE); Alice no posto ao lado da esteira (contrai com o mundo em BOB)
- [x] Modelos KayKit animados nos avatares — Bob = Barbarian com machado de uma lâmina no `handslot.r` (lenhador a 0.9c), Alice = Rogue sem capa, idle do Rig_Medium (`general/Idle_A`); fallback low-poly procedural se o GLB faltar; `tools/Sawing` e `Working_A/B/C` disponíveis pra cenografia futura
- [x] Troca de corpo no meio da transição — no pico do tint o player teleporta para o posto do referencial novo e os avatares trocam de visibilidade
- [x] Soft-cap de velocidade em BOB (β ≤ 0.9) — a 0.99c o offset de simultaneidade excederia a duração da passada; 0.99c fica reservado ao Ato 1 em ALICE
- [x] Correia fora do MovingWorld + scroll só em ALICE — a superfície da correia está em repouso com a tora, não com o galpão
- [ ] Som ambiente do galpão
- [ ] Efeitos sonoros pontuais (esteira, guilhotinas, transição)

**Marco**: Atos 0-3 rodam completos de ponta a ponta. ✅ Atingido (sem áudio e sem overlay de linhas).

### Semana 5 — Tesouras e Polimento

**Objetivos**:
- Cena `observatorio.tscn` (Ato 4)
- Lógica das tesouras superluminais
- Velocímetro do ponto de corte
- Visualização do cone de luz
- Transição entre cenas
- Polimento visual (bloom, motion blur)
- Ensaio cronometrado da apresentação completa
- Ajustes finos

**Marco**: Show completo de 20 minutos rodando.

---

## 10. Princípios de Execução

Aplicáveis em qualquer momento do desenvolvimento:

### 10.1 Cada dia termina com algo rodável

Nada de "vou fazer a arquitetura toda primeiro". Sempre há algo para mostrar. Mesmo que feio.

### 10.2 Assets antes de código bonito

Um boneco de palito andando no galpão é mais valioso que um sistema de física perfeito sem visual. Visual valida cedo.

### 10.3 Hardcode primeiro, generalize depois

Parâmetros do paradoxo (velocidade, comprimento, etc) ficam hardcoded até a Fase 4. Só depois viram configuráveis. Otimização prematura mata projeto.

### 10.4 Teatro > simulação

Quando física exata brigar com clareza visual, **clareza visual ganha**. Este é um instrumento de palco, não um simulador.

### 10.5 Commit por milestone visual

Sempre que algo funcionar visualmente, commit. Histórico de progresso vira material útil para TCC e apresentação posterior.

### 10.6 Foco no momento "wow"

A mecânica de troca de referencial (Semana 3) é a coisa mais importante do projeto. Se essa transição estiver perfeita, o resto pode ser modesto e ainda assim funciona.

---

## 11. Convenções de Código

### 11.1 GDScript Style Guide

- Seguir convenções oficiais do Godot 4: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- Indentação: tabs (padrão Godot)
- Snake_case para variáveis, funções, sinais
- PascalCase para classes e nodes no editor
- SCREAMING_SNAKE_CASE para constantes

### 11.2 Estrutura de Scripts

```gdscript
# scripts/exemplo.gd
extends Node3D

# 1. Constantes
const MAX_SPEED: float = 10.0

# 2. Exportadas (configuráveis no editor)
@export var some_value: float = 1.0

# 3. Sinais
signal something_happened

# 4. Variáveis públicas
var current_state: int = 0

# 5. Variáveis privadas (prefixo _)
var _internal_counter: int = 0

# 6. Onready (referências de nodes)
@onready var some_node: Node = $SomeNode

# 7. Funções built-in (ordem do ciclo de vida)
func _ready() -> void: pass
func _process(delta: float) -> void: pass
func _physics_process(delta: float) -> void: pass
func _input(event: InputEvent) -> void: pass

# 8. Funções públicas
func do_something() -> void: pass

# 9. Funções privadas
func _internal_helper() -> void: pass
```

### 11.3 Type Hints Obrigatórios

Sempre tipar argumentos e retornos de funções:

```gdscript
# ✅ Correto
func calculate_gamma(velocity_fraction: float) -> float:
    return 1.0 / sqrt(1.0 - velocity_fraction * velocity_fraction)

# ❌ Evitar
func calculate_gamma(velocity_fraction):
    return 1.0 / sqrt(1.0 - velocity_fraction * velocity_fraction)
```

### 11.4 Sinais para Comunicação Entre Sistemas

Preferir sinais em vez de referências diretas entre sistemas independentes. O autoload `InputBus` é o exemplo central desse padrão.

### 11.5 Comentários

- Comentar **por que**, não **o quê**
- Documentar funções públicas com comentário de uma linha acima
- Equações relativísticas devem ter referência ao artigo (ex: `# Eq. 13 do artigo de Alencar et al.`)

---

## 12. Glossário Técnico

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

## 13. Referências

### 13.1 Referência Principal

[1] **Alencar, G., Macedo, J., Maranhão, L., & Carneiro, P. (2023).** *Paradoxos da Relatividade*. arXiv:2307.05503v1 [physics.pop-ph]. Departamento de Física, Universidade Federal do Ceará.

### 13.2 Referências Secundárias (Citadas no Artigo Principal)

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

### 13.3 Referências de Inspiração Visual e de Game Design

- **A Slower Speed of Light** (MIT Game Lab, 2012) — primeira pessoa com efeitos visuais relativísticos
- **Velocity Raptor** (TestTubeGames) — plataforma 2D com contração de Lorentz
- **Universe Sandbox** — modelo de "instrumento de palco" para fenômenos físicos
- **Manifold Garden** — puzzle como exploração conceitual de geometria não-euclidiana
- **Bret Victor — Stop Drawing Dead Fish** — referência sobre instrumentos interativos para demonstração

### 13.4 Ferramentas Utilizadas

- **Godot Engine 4.x** — https://godotengine.org
- **Hyper3D.ai (Rodin)** — Geração de modelos 3D via IA — https://hyper3d.ai
- **PixelLab.ai** — Geração de pixel art via IA — https://pixellab.ai

### 13.5 Documentação Técnica de Referência

- Godot 4 Documentation: https://docs.godotengine.org/en/stable/
- GDScript Style Guide: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
- Godot Input System: https://docs.godotengine.org/en/stable/tutorials/inputs/index.html

---

## Notas Finais para Claude Code

### Como Tratar Este Projeto

1. **Sempre validar mudanças contra o artigo de Alencar et al. (2023)**. Se uma decisão técnica conflitar com a explicação científica do artigo, a explicação científica vence.

2. **Priorizar clareza visual sobre exatidão numérica**. Este não é um simulador científico — é um instrumento didático teatral.

3. **Manter os 20 minutos como restrição rígida**. Se algo não couber no tempo, cortar. O paradoxo da Barra e Fenda 2D foi descartado por esse motivo.

4. **Foco absoluto na troca de referencial como mecânica central**. Tudo gira em torno desse momento. Outras decisões podem ser modestas.

5. **A audiência são adolescentes do ensino médio**. Linguagem visual e narrativa devem refletir isso — sem jargão técnico desnecessário, com momentos de impacto visual claros.

6. **O orientador é o único "usuário"**. Não há tutoriais, sem onboarding para o aluno. Tudo deve ser pensado para alguém que sabe usar a ferramenta operá-la ao vivo.

7. **Commit early, commit often**. Cada milestone visual merece um commit. O histórico vira documentação do progresso.

8. **Em caso de dúvida sobre arquitetura, escolher a opção mais simples que funciona**. Refatorar é fácil depois que algo está rodando.

9. **Compatibilidade Windows ↔ Linux é restrição rígida** (ver Seção 5.3). Nunca usar caminhos absolutos, nomes de arquivo com acentos nos assets, ou chamadas de sistema sem teste cross-platform. Desenvolvimento ocorre em AlmaLinux 9.8; apresentações em Windows.

### Estado Atual do Projeto

**Fase**: Semana 3 — Coração: Troca de Referencial
**Ambiente de desenvolvimento**: AlmaLinux 9.8 + Godot 4.6.3 + VS Code 1.122.0 (ambos via Flatpak) — configurado e funcional.
**Pendência da Semana 2**:
- `esteira.glb`, `guilhotina.glb` do Hyper3D ainda pendentes (galpão integrado; esteira usa UV scroll procedural; tora usa cena procedural)
**Ganchos já implementados para Semana 3**:
- `tora.gd`: `set_lorentz_scale(gamma)` e `reset_lorentz_scale()` prontos — `frame_controller.gd` só precisa chamá-los
- `lorentz_transform.gd`: `gamma()`, `contracted_length()`, `simultaneity_offset()` implementados e funcionando
**Próximos passos imediatos**:
1. `frame_controller.gd`: switch ALICE↔BOB com escala anisotrópica (1/γ) usando os ganchos acima
2. Transição animada de 1.5–2s com Tween (easing cúbico)
3. Bloqueio de inputs durante transição
4. Efeito visual sutil na transição (vinheta / distorção cromática)

---

*Última atualização: 31 de maio de 2026*
*Projeto desenvolvido como instrumento de ensino de Relatividade Especial para o ensino médio brasileiro.*

---

## 14. Licença

Este projeto usa uma **licença dupla**:

| Componente | Licença | Arquivo |
|---|---|---|
| Código-fonte (`scripts/`, `scenes/`, `project.godot`) | [GNU GPL v3](https://www.gnu.org/licenses/gpl-3.0.html) | `LICENSE` |
| Assets e documentação (`assets/`, `docs/`, `README.md`) | [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/) | `LICENSE-ASSETS` |

**Em resumo:** você pode usar, estudar e modificar este projeto para fins educacionais e não-comerciais, desde que mantenha a atribuição ao autor original e distribua derivados sob as mesmas licenças.

Copyright (C) 2026 Mateus Alkimim
