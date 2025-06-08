#!/bin/bash
#
# Print banner art.

#######################################
# Print a board. 
# Globals:
#   BG_BROWN
#   NC
#   WHITE
#   CYAN_LIGHT
#   RED
#   GREEN
#   YELLOW
# Arguments:
#   None
#######################################

# Função para desenhar linhas decorativas
draw_line() {
    local char=$1
    local color=$2
    printf "${color}"
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' "$char"
    printf "${COLOR_NC}"
}

# Função para centralizar texto
center_text() {
    local text="$1"
    local color="$2"
    local width=${COLUMNS:-$(tput cols)}
    local padding=$(( (width - ${#text}) / 2 ))
    printf "${color}%*s%s%*s${COLOR_NC}\n" $padding '' "$text" $padding ''
}

# Função para verificar e instalar pacotes necessários
check_dependencies() {
    local packages=("net-tools")
    local missing=()

    for pkg in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $pkg "; then
            missing+=("$pkg")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        print_info "Instalando dependências necessárias..."
        sudo apt-get update -qq > /dev/null 2>&1
        sudo apt-get install -qq -y "${missing[@]}" > /dev/null 2>&1
    fi
}

print_banner() {
    clear
    printf "\n"
    
    # Verificar dependências antes de continuar
    check_dependencies

    # Banner principal
    draw_line "═" "${COLOR_BLUE}"
    printf "\n"
    center_text "╔══════════════════════════════════════════════════════════════╗" "${COLOR_BLUE}"
    center_text "║                   WHATICKET SAAS INSTALLER                   ║" "${COLOR_BLUE}"
    center_text "║                                                             ║" "${COLOR_BLUE}"
    center_text "║                     BY COMUNIDADE 3.0                       ║" "${COLOR_BLUE}"
    center_text "╚══════════════════════════════════════════════════════════════╝" "${COLOR_BLUE}"
    printf "\n"
    draw_line "═" "${COLOR_BLUE}"
    printf "\n"

    # Informações do sistema em uma caixa elegante
    center_text "┌─────────────── Informações do Sistema ───────────────┐" "${COLOR_YELLOW}"
    printf "${COLOR_WHITE}"
    center_text "• Sistema: $(lsb_release -d | cut -f2)" "${COLOR_WHITE}"
    center_text "• Kernel: $(uname -r)" "${COLOR_WHITE}"
    center_text "• Memória: $(free -h | awk '/^Mem:/ {print $2}') total" "${COLOR_WHITE}"
    center_text "• CPU: $(lscpu | grep 'Model name' | cut -f2 -d ':' | sed 's/^[ \t]*//')" "${COLOR_WHITE}"
    center_text "└──────────────────────────────────────────────────────┘" "${COLOR_YELLOW}"
    printf "\n"

    # Status das portas em uma tabela elegante
    center_text "┌─────────────────── Status das Portas ────────────────┐" "${COLOR_YELLOW}"
    check_port() {
        local port=$1
        if netstat -tuln | grep -q ":$port "; then
            echo -e "${COLOR_RED}Em uso${COLOR_NC}"
        else
            echo -e "${COLOR_GREEN}Livre${COLOR_NC}"
        fi
    }

    # Função para mostrar status de range de portas
    check_port_range() {
        local start=$1
        local end=$2
        if netstat -tuln | grep -q ":[$start-$end][0-9]\{2\} "; then
            echo -e "${COLOR_RED}Algumas em uso${COLOR_NC}"
        else
            echo -e "${COLOR_GREEN}Livres${COLOR_NC}"
        fi
    }

    printf "${COLOR_WHITE}"
    center_text "• Porta 80: $(check_port 80)" "${COLOR_WHITE}"
    center_text "• Porta 443: $(check_port 443)" "${COLOR_WHITE}"
    center_text "• Portas 3000-3999: $(check_port_range 3 3)" "${COLOR_WHITE}"
    center_text "• Portas 4000-4999: $(check_port_range 4 4)" "${COLOR_WHITE}"
    center_text "• Portas 5000-5999: $(check_port_range 5 5)" "${COLOR_WHITE}"
    center_text "└──────────────────────────────────────────────────────┘" "${COLOR_YELLOW}"
    printf "\n"

    # Data e hora em uma caixa elegante
    center_text "┌────────────────── Data e Hora do Sistema ───────────────┐" "${COLOR_YELLOW}"
    center_text "$(date '+%d/%m/%Y %H:%M:%S')" "${COLOR_WHITE}"
    center_text "└─────────────────────────────────────────────────────────┘" "${COLOR_YELLOW}"
    printf "\n"
}

# Função para mostrar o menu principal
show_menu() {
    printf "\n"
    center_text "╔════════════════════ Menu Principal ═══════════════════╗" "${COLOR_GREEN}"
    printf "\n"
    
    local options=(
        "📦 Instalar Novo Sistema"
        "🔄 Atualizar Sistema Existente"
        "🗑️ Remover Sistema"
        "🔒 Bloquear Sistema"
        "🔓 Desbloquear Sistema"
        "🌐 Alterar Domínio"
        "💾 Backup do Sistema"
    )
    
    for i in "${!options[@]}"; do
        center_text "   [${COLOR_YELLOW}$i${COLOR_NC}] ${options[$i]}" "${COLOR_WHITE}"
        printf "\n"
    done
    
    center_text "╚══════════════════════════════════════════════════════╝" "${COLOR_GREEN}"
    printf "\n"
    center_text "Digite sua escolha [0-6]:" "${COLOR_YELLOW}"
    printf "\n"
}
