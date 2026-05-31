#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Mateus Alkimim
# Instala o driver xone (receptor sem fio Xbox) no AlmaLinux 9 via DKMS.
# Testado em: AlmaLinux 9.8 · kernel 5.14.x

set -euo pipefail

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()  { echo -e "${GREEN}[✔]${NC} $*"; }
aviso() { echo -e "${YELLOW}[!]${NC} $*"; }
erro()  { echo -e "${RED}[✘]${NC} $*" >&2; exit 1; }

echo -e "${BOLD}=== Instalação do driver xone (receptor sem fio Xbox) ===${NC}"
echo ""

# ── Segurança ─────────────────────────────────────────────────────────────────
[[ $EUID -eq 0 ]] && erro "Não rode como root. Use seu usuário normal com sudo."
sudo -v || erro "Este script precisa de acesso sudo."

# ── Verificação de distro ──────────────────────────────────────────────────────
if ! grep -qi "almalinux\|rhel\|rocky\|centos" /etc/os-release 2>/dev/null; then
    aviso "Distro não reconhecida como AlmaLinux/RHEL. Ajustes podem ser necessários."
fi

KERNEL_VER=$(uname -r)
info "Kernel detectado: $KERNEL_VER"

# ── Passo 1: Pré-requisitos ────────────────────────────────────────────────────
info "Instalando dkms, kernel-devel, git e cabextract..."
sudo dnf install -y dkms "kernel-devel-${KERNEL_VER}" git cabextract

# Garante que o kernel-devel instalado bate com o kernel em uso
KDEVEL_VER=$(rpm -q --qf "%{VERSION}-%{RELEASE}.%{ARCH}" "kernel-devel-${KERNEL_VER}" 2>/dev/null || true)
if [[ -z "$KDEVEL_VER" ]]; then
    aviso "kernel-devel para ${KERNEL_VER} não encontrado nos repositórios."
    aviso "Tente: sudo dnf install -y kernel-devel  (instala o mais recente disponível)"
    aviso "Se o kernel em uso for mais novo que o disponível, reinicie para o kernel mais antigo e rode novamente."
    erro "Abortando — kernel-devel não instalado."
fi
info "kernel-devel instalado: $KDEVEL_VER"

# ── Passo 2: Clonar xone ──────────────────────────────────────────────────────
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

info "Clonando repositório xone..."
git clone --depth=1 https://github.com/medusalix/xone "$TMPDIR/xone"

# ── Passo 3: Patches de compatibilidade com RHEL 9 (kernel 5.14-el9 backports) ──
info "Aplicando patches de compatibilidade com RHEL 9..."
cd "$TMPDIR/xone"

# [1] from_timer() foi renomeado para timer_container_of() no backport do kernel 6.15
sed -i 's/\bfrom_timer(/timer_container_of(/g' driver/gamepad.c

# [2] bus/bus.c — assinaturas dos callbacks de bus_type mudaram
#     uevent:  struct device *  →  const struct device *
sed -i 's/gip_client_uevent(struct device \*/gip_client_uevent(const struct device */' bus/bus.c
#     match:   struct device_driver *  →  const struct device_driver *
sed -i 's/gip_bus_match(struct device \*dev, struct device_driver \*/gip_bus_match(struct device *dev, const struct device_driver */' bus/bus.c
#     remove:  int →  void  (kernel parou de usar código de retorno no remove)
sed -i 's/^static int gip_bus_remove_compat(/static void gip_bus_remove_compat(/' bus/bus.c
python3 - <<'PYEOF'
import re

with open('bus/bus.c', 'r') as f:
    src = f.read()

# Remove o "return 0;" dentro de gip_bus_remove_compat
src = re.sub(
    r'(static void gip_bus_remove_compat\b[^{]*\{)(.*?)(^\})',
    lambda m: m.group(1) + re.sub(r'\n[ \t]+return\s+\w+\s*;', '', m.group(2)) + m.group(3),
    src, flags=re.DOTALL | re.MULTILINE
)

with open('bus/bus.c', 'w') as f:
    f.write(src)
PYEOF

# [3] transport/dongle.c — drvwrap foi removido de struct usb_driver no backport do kernel 6.6
sed -i '/\.drvwrap\.driver\.shutdown/d' transport/dongle.c

info "Patches aplicados."

# ── Passo 4: Instalar via DKMS ────────────────────────────────────────────────
# Remove instalação anterior (inclusive versões quebradas de tentativas anteriores)
while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    aviso "Removendo entrada DKMS existente: $entry"
    sudo dkms remove "$entry" --all 2>/dev/null || true
done < <(sudo dkms status xone 2>/dev/null | grep -oP 'xone/[^\s:,]+' | sort -u)
# Limpa diretórios residuais em /usr/src que impedem o install.sh de rodar
sudo rm -rf /usr/src/xone-* 2>/dev/null || true

info "Instalando driver xone via DKMS (pode levar alguns minutos)..."
sudo ./install.sh --release

# ── Passo 5: Firmware ─────────────────────────────────────────────────────────
info "Baixando firmware proprietário da Microsoft para o dongle..."
# Tenta encontrar o script de firmware no clone (caminho atual: install/firmware.sh).
FWSRC=$(find "$TMPDIR/xone" -name "firmware.sh" -o -name "xone-get-firmware.sh" 2>/dev/null | head -1)
if [[ -n "$FWSRC" ]]; then
    sudo install -Dm755 "$FWSRC" /usr/sbin/xone-firmware.sh
    info "Script de firmware copiado do clone: $FWSRC"
elif ! [[ -x /usr/sbin/xone-firmware.sh ]]; then
    info "Script não encontrado no clone — baixando do GitHub..."
    sudo curl -fsSL \
        "https://raw.githubusercontent.com/medusalix/xone/master/install/firmware.sh" \
        -o /usr/sbin/xone-firmware.sh \
    || { aviso "Não foi possível baixar o script de firmware."; }
    [[ -s /usr/sbin/xone-firmware.sh ]] && sudo chmod +x /usr/sbin/xone-firmware.sh
fi

if [[ -x /usr/sbin/xone-firmware.sh ]]; then
    sudo /usr/sbin/xone-firmware.sh
else
    aviso "Script de firmware indisponível. Após reiniciar, rode manualmente:"
    aviso "  sudo bash /tmp/xone-check/install/firmware.sh"
fi

# ── Passo 6: Carregar módulo ──────────────────────────────────────────────────
info "Carregando módulo xone-dongle..."
if sudo modprobe xone-dongle 2>/dev/null; then
    info "Módulo carregado com sucesso."
else
    aviso "modprobe falhou — provavelmente requer reinicialização."
fi

# ── Verificação final ─────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}=== Instalação concluída ===${NC}"
echo ""
echo "Próximos passos:"
echo "  1. Conecte o dongle USB"
echo "  2. Ligue o controle Xbox (botão Xbox)"
echo "  3. Verifique se aparece: ls /dev/input/js*"
echo "  4. Teste no Godot ou com:  jstest /dev/input/js0"
echo ""
echo "Se ls /dev/input/js* não mostrar novos dispositivos, reinicie o sistema."
echo ""
echo "No Windows o dongle funciona nativamente — nenhum driver adicional necessário."
