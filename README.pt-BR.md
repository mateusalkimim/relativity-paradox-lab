<!-- idioma: linha gerada por i18n.py -->
> [!NOTE]
> ### 🌍 **[Read this page in English →](README.md)**

# Paradoxo da Relatividade — Instrumento Interativo de Ensino

> *A relatividade não é difícil pela matemática — é difícil porque obriga a trocar de modelo de mundo. Este instrumento não deduz o resultado numa lousa: ele faz o aluno **trocar de referencial com o próprio corpo** e ver o mundo se reconfigurar à sua frente.*

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

Se a barreira é trocar de modelo de mundo, o instrumento mais eficaz é o que faz o aluno *habitar* um referencial de cada vez — não o que compara dois diagramas de fora. Disso decorre tudo abaixo:

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

O conteúdo conceitual deriva de um artigo de referência único:

**Alencar, G., Macedo, J., Maranhão, L., & Carneiro, P. (2023).** *Paradoxos da Relatividade*. arXiv:2307.05503v1 [physics.pop-ph]. UFC.

Equações implementadas em `scripts/lorentz_transform.gd` (referência rápida para o código):

| Grandeza | Equação |
|---|---|
| Fator de Lorentz | γ = 1 / √(1 − v²/c²) |
| Contração de Lorentz | L = L₀ / γ |
| Offset de simultaneidade | Δt' = γ·L₀·v/c² |
| Velocidade do ponto de corte (tesouras) | v = ω·L·csc²(θ) |

> **Aprofundamento físico e bibliográfico** — derivação das equações, transformações de Lorentz completas, os conceitos que o aluno deve *sentir*, as concepções galileanas a abandonar, o glossário e a bibliografia acadêmica estão em [`FUNDAMENTACAO-CIENTIFICA.md`](FUNDAMENTACAO-CIENTIFICA.md). Mantém-se aqui apenas o núcleo técnico necessário ao código.

---

## 3. Paradoxos Selecionados

Dos sete paradoxos do artigo de referência, **dois** entram na apresentação. Resolução física detalhada, justificativa pedagógica e seções/páginas do artigo: [`FUNDAMENTACAO-CIENTIFICA.md §5`](FUNDAMENTACAO-CIENTIFICA.md#5-os-paradoxos-em-detalhe).

### 3.1 Principal — A Madeireira Relativística

Tora (comprimento próprio `L₀`) desliza sobre a esteira a `v`; duas guilhotinas separadas por `L₀` descem. Em **Alice**, a tora está contraída (`L₀/γ`) e passa; em **Bob**, tem tamanho próprio e "não caberia" — resolvido porque, em Bob, as guilhotinas não são simultâneas (`Δt' = γ·L₀·v/c²`).

- **Implementação**: `frame_controller.gd`, `esteira.gd`, `guillotine.gd`, `tora.gd`
- **Status**: ✅ implementado (Atos 0-3) · ~14 min

### 3.2 Clímax — Tesouras Superluminais

O ponto de cruzamento de duas lâminas pode exceder `c` (`v = ω·L·csc²θ`) sem violar causalidade — por não ser objeto material, não carrega informação.

- **Implementação prevista**: `scissors.gd`, `observatorio.tscn`
- **Status**: ⬜ pendente (Semana 5, Ato 4) · ~3 min

### 3.3 Fora de escopo

Barra-e-Fenda 2D (descartado por custo de *setup* conceitual) e Barra-e-Fenda com gravidade (expansão futura / TCC) — documentados na fundamentação.

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

> Cada ação também possui atalho de teclado equivalente (WASD para mover, Q trocar referencial, E/Z velocidade, Espaço ação, O overlay, P câmera lenta, R reset, V vista, N próxima cena) para desenvolvimento. O teclado não é usado durante a apresentação.

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
├── setup-xbox-linux.sh             # Instala o driver xone (dongle Xbox no Linux)
│
├── scenes/
│   ├── main.tscn                   # Cena raiz, entrada do jogo
│   ├── world/
│   │   ├── galpao.tscn             # Cenário da madeireira (Atos 0-3)
│   │   ├── esteira.tscn            # Esteira transportadora (correia física, instancia tora.tscn)
│   │   └── tora.tscn               # Tora reutilizável (CylinderMesh procedural, L₀=4u)
│   └── player/
│       └── player.tscn             # Câmera primeira pessoa + movimento
│   # observatorio.tscn (Ato 4) — pendente, Semana 5
│
├── scripts/
│   ├── input_manager.gd            # Autoload InputBus: abstração de input
│   ├── game_state.gd               # Autoload GameState: estado global
│   ├── player.gd                   # Movimento, câmera e encarnação em 1ª pessoa
│   ├── frame_controller.gd         # Lógica de troca de referencial
│   ├── lorentz_transform.gd        # Cálculos relativísticos (γ, contração, offset temporal)
│   ├── esteira.gd                  # Esteira: correia física (sarrafos + rolos), instancia tora.tscn
│   ├── conveyor_belt.gd            # Legado — substituído por esteira.gd/esteira.tscn (a remover na Semana 5)
│   ├── tora.gd                     # Tora: @export L₀, diâmetro; set_lorentz_scale(); corte em duas metades
│   ├── guillotine.gd               # Comportamento das guilhotinas
│   ├── galpao.gd                   # Cenário: skydome HDRI, WorldEnvironment, iluminação estilizada
│   ├── avatar.gd                   # Avatares Bob (Barbarian) e Alice (Rogue) — KayKit animado
│   ├── grain.gd                    # Granulado procedural (normal map de ruído em runtime)
│   └── hud.gd                      # HUD: velocímetro, γ e referencial (Labels; sprite pendente)
│   # simultaneity_lines.gd (overlay) — pendente, Semana 4
│   # scissors.gd (tesouras, Ato 4) — pendente, Semana 5
│
├── assets/
│   ├── models/                     # .glb gerados no Hyper3D + personagens KayKit
│   │   ├── galpao_estrutura.glb    # ✅ integrado com colisão trimesh (+ texturas PBR)
│   │   ├── tora.glb                # presente; tora usa cena procedural (tora.tscn)
│   │   ├── esteira.glb             # pendente
│   │   ├── guilhotina.glb          # pendente
│   │   ├── observatorio.glb        # pendente (Ato 4)
│   │   └── characters/             # KayKit (CC0): Barbarian.glb, Rogue.glb, axe_1handed, anims/
│   ├── packages/                   # Zips KayKit originais — fora do versionamento (ver .gitignore)
│   ├── textures/                   # Texturas auxiliares
│   │   └── hdri_galpao.hdr         # HDRI equiretangular para skydome do galpão
│   ├── sprites/                    # Pixel art (PixelLab) — pendente
│   └── audio/                      # pendente
│       ├── music/
│       └── sfx/
│
├── shaders/                        # Reservado para Fase 3+ (vazio)
│
└── docs/
    ├── referencia_principal.pdf    # Artigo de Alencar et al. (2023)
    └── referencia_principal.txt    # Texto extraído do artigo (referência rápida)
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

**Status**: 🟡 planejado — a ação `toggle_overlay` (Botão Y) está mapeada, mas `simultaneity_lines.gd` ainda não foi implementado (pendência da Semana 4). No Ato 3, a simultaneidade já é demonstrada pelo offset temporal das guilhotinas + câmera lenta; o overlay é a camada visual complementar.

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
- Velocidade ajustável de 0 a 0.99c (D-Pad ↑↓); soft-cap β ≤ 0.9 no referencial de Bob (a 0.99c o offset de simultaneidade excederia a duração da passada)
- Movimento visual via **correia física**: sarrafos transladam com o mesmo passo da tora (`belt_beta × VISUAL_C × delta`), com wrap nas pontas e rolos girando (ω = v/r) — substituiu o UV scroll antigo, que dependia de fator de ajuste e não casava com a tora
- Instancia `tora.tscn` e a move ao longo do eixo X
- A esteira inteira pertence ao grupo `MovingWorld`: em `Frame.BOB`, a tora fica parada e o galpão (com a esteira) contrai e desliza a −v

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

**Status**: ⬜ não implementado — `scissors.gd` e `observatorio.tscn` previstos para a Semana 5. A ação `next_scene` (Botão Menu) já está mapeada para a transição.

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
- [x] Mira do corte precisa — corte calculado no instante em que a lâmina cruza o topo da tora, com queda quase instantânea (~0.06s, no limite da percepção): a tora anda < 0.1u entre o gatilho e o cruzamento. Lâmina com gume em cunha (PrismMesh); retração e pausa embaixo também rápidas
- [x] Reset da cena (Botão B) — `reset_session()` + reload
- [x] Cena do paradoxo funcionando completa em ambos os frames
- [x] Avatares Bob e Alice (`avatar.gd`) — Bob viaja na correia atrás da tora (contrai com ela em ALICE); Alice no posto ao lado da esteira (contrai com o mundo em BOB)
- [x] Modelos KayKit animados nos avatares — Bob = Barbarian com machado de uma lâmina no `handslot.r` (lenhador a 0.9c), Alice = Rogue sem capa, idle do Rig_Medium (`general/Idle_A`); fallback low-poly procedural se o GLB faltar; `tools/Sawing` e `Working_A/B/C` disponíveis pra cenografia futura
- [x] Encarnação em primeira pessoa — o operador É a Alice em ALICE e o Bob em BOB: corpo visível olhando pra baixo (tronco, braços, pernas; cabeça oculta pra câmera), animações de andar/parar, machado na mão do Bob; no meio da transição o player teleporta pro posto do referencial novo e o NPC encarnado some
- [x] Soft-cap de velocidade em BOB (β ≤ 0.9) — a 0.99c o offset de simultaneidade excederia a duração da passada; 0.99c fica reservado ao Ato 1 em ALICE
- [x] Correia física — sarrafos transladam com o mesmo passo da tora (`belt_beta × VISUAL_C × delta`) com wrap nas pontas e rolos girando (ω = v/r); substituiu o UV scroll, que dependia de fator de ajuste e não casava com a tora. Esteira inteira no MovingWorld (contrai e acompanha o galpão em BOB); em BOB os sarrafos andam a v·γ em coordenada local, ficando em repouso com a tora no espaço do mundo
- [x] Bob completa o ciclo da madeira — segue até o fim da correia, mergulha no poço atrás da tora e cai da calha junto com a tora nova
- [x] Iluminação estilizada (ref. Zelda Link's Awakening Remake) — WorldEnvironment com ambiente difuso quente + tonemap Filmic, ajustes de saturação (1.2) e brilho (0.95), sol moderado com penumbra macia (`light_angular_distance` + `shadow_blur`), materiais foscos sem metallic e com granulado procedural (`grain.gd`: normal map de ruído em runtime — aspecto árido, anti "balão de plástico")
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
- Limpeza técnica: remover `scripts/conveyor_belt.gd` legado (substituído pela correia física em `esteira.gd`; resta só uma referência em comentário)

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

Termos do código relevantes para a implementação:

| Termo | Definição |
|---|---|
| **Frame (no código)** | Referencial inercial; valores: `ALICE` ou `BOB` |
| **β (beta)** | Velocidade em frações de c (β = v/c, 0 a 1) — `belt_beta` no `GameState` |
| **γ (gamma)** | Fator de Lorentz, 1/√(1−β²), sempre ≥ 1 — `get_gamma()` |
| **L₀** | Comprimento próprio (tora = 4 u; distância entre guilhotinas = 4 u) |
| **MovingWorld** | Grupo de nós (galpão + esteira + guilhotinas) que contrai/desliza em `BOB` |

Glossário físico completo (referencial inercial, tempo próprio, cone de luz, linha de mundo, simultaneidade relativa): [`FUNDAMENTACAO-CIENTIFICA.md §6`](FUNDAMENTACAO-CIENTIFICA.md#6-glossário-técnico).

---

## 13. Referências

### 13.1 Referência Científica

[1] **Alencar, G., Macedo, J., Maranhão, L., & Carneiro, P. (2023).** *Paradoxos da Relatividade*. arXiv:2307.05503v1 [physics.pop-ph]. UFC.

> A bibliografia acadêmica completa (referências secundárias citadas no artigo: Rindler, Dewan, Taylor & Wheeler, Rothman, Kaushal & Nemiroff etc.) está em [`FUNDAMENTACAO-CIENTIFICA.md §7`](FUNDAMENTACAO-CIENTIFICA.md#7-referências).

### 13.2 Referências de Inspiração Visual e de Game Design

- **A Slower Speed of Light** (MIT Game Lab, 2012) — primeira pessoa com efeitos visuais relativísticos
- **Velocity Raptor** (TestTubeGames) — plataforma 2D com contração de Lorentz
- **Universe Sandbox** — modelo de "instrumento de palco" para fenômenos físicos
- **Manifold Garden** — puzzle como exploração conceitual de geometria não-euclidiana
- **Bret Victor — Stop Drawing Dead Fish** — referência sobre instrumentos interativos para demonstração

### 13.3 Ferramentas Utilizadas

- **Godot Engine 4.x** — https://godotengine.org
- **Hyper3D.ai (Rodin)** — Geração de modelos 3D via IA — https://hyper3d.ai
- **PixelLab.ai** — Geração de pixel art via IA — https://pixellab.ai

### 13.4 Documentação Técnica de Referência

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

**Fase**: Semana 4 — Simultaneidade e Resolução (🟡 parcial)
**Ambiente de desenvolvimento**: AlmaLinux 9.8 + Godot 4.6.3 + VS Code 1.122.0 (ambos via Flatpak) — configurado e funcional.
**Concluído (Atos 0-3 rodam de ponta a ponta)**:
- Troca de referencial ALICE↔BOB com contração de Lorentz animada (Tween cúbico, bloqueio de input na transição)
- Correia física (sarrafos + rolos) substituindo o UV scroll; tora se move e é cortada na mira do operador
- Guilhotinas com offset temporal de simultaneidade em BOB + modo câmera lenta (Botão X) e reset (Botão B)
- Avatares KayKit (Bob/Alice) com encarnação em 1ª pessoa e iluminação estilizada
**Pendências da Semana 4**:
- Overlay de linhas de simultaneidade (`simultaneity_lines.gd`, sprites pixel art)
- Som ambiente do galpão e efeitos sonoros pontuais
**Pendências de assets**: `esteira.glb`, `guilhotina.glb`, `observatorio.glb` (Hyper3D); sprites do HUD (PixelLab)
**Próximos passos imediatos**:
1. Sistema de linhas de simultaneidade (Botão Y) — última peça conceitual do Ato 3
2. Camada de áudio (ambiente + SFX de esteira, guilhotinas e transição)
3. Iniciar Semana 5: cena `observatorio.tscn` e lógica das tesouras superluminais (`scissors.gd`)

---

> *O instrumento não termina quando a tora passa. Termina quando o aluno entende **por que** ela passou — e descobre que não precisou de um mundo de fantasia para se espantar: o nosso, descrito com honestidade, já bastava.*

*Última atualização: 24 de junho de 2026*
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
