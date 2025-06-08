#!/bin/bash

# Mensagens de erro
export ERR_INVALID_PORT="Porta inválida ou já em uso"
export ERR_INVALID_DOMAIN="Domínio inválido"
export ERR_INVALID_COMPANY="Nome da empresa inválido"
export ERR_COMPANY_EXISTS="Uma empresa com este nome já existe"
export ERR_INSUFFICIENT_MEMORY="Memória RAM insuficiente"
export ERR_INSUFFICIENT_DISK="Espaço em disco insuficiente"
export ERR_MISSING_DEPENDENCY="Dependência faltando"
export ERR_BUILD_FAILED="Falha na compilação"
export ERR_DB_CONNECTION="Erro na conexão com o banco de dados"
export ERR_REDIS_CONNECTION="Erro na conexão com o Redis"
export ERR_PM2_START="Erro ao iniciar o serviço com PM2"
export ERR_NGINX_CONFIG="Erro na configuração do Nginx"
export ERR_SSL_CERT="Erro ao gerar certificado SSL"
export ERR_BACKUP_FAILED="Erro ao criar backup"
export ERR_RESTORE_FAILED="Erro ao restaurar backup"

# Mensagens de sucesso
export SUCCESS_INSTALL="Instalação concluída com sucesso"
export SUCCESS_UPDATE="Atualização concluída com sucesso"
export SUCCESS_DELETE="Sistema removido com sucesso"
export SUCCESS_BLOCK="Sistema bloqueado com sucesso"
export SUCCESS_UNBLOCK="Sistema desbloqueado com sucesso"
export SUCCESS_DOMAIN_CHANGE="Domínio alterado com sucesso"
export SUCCESS_BACKUP="Backup criado com sucesso"
export SUCCESS_RESTORE="Backup restaurado com sucesso"
export SUCCESS_PORT_CHECK="Todas as portas estão disponíveis"
export SUCCESS_COMPANY_CHECK="Nome da empresa disponível"
export SUCCESS_SYSTEM_CHECK="Requisitos do sistema atendidos"
export SUCCESS_DB_CREATE="Banco de dados criado com sucesso"
export SUCCESS_REDIS_CONFIG="Redis configurado com sucesso"
export SUCCESS_PM2_START="Serviço iniciado com sucesso"
export SUCCESS_NGINX_CONFIG="Nginx configurado com sucesso"
export SUCCESS_SSL_CERT="Certificado SSL gerado com sucesso"

# Mensagens de informação
export INFO_CHECKING_SYSTEM="Verificando requisitos do sistema..."
export INFO_CHECKING_PORTS="Verificando portas em uso..."
export INFO_CHECKING_COMPANY="Verificando nome da empresa..."
export INFO_INSTALLING_DEPS="Instalando dependências..."
export INFO_CONFIGURING_DB="Configurando banco de dados..."
export INFO_CONFIGURING_REDIS="Configurando Redis..."
export INFO_BUILDING_FRONTEND="Compilando frontend..."
export INFO_BUILDING_BACKEND="Compilando backend..."
export INFO_STARTING_SERVICES="Iniciando serviços..."
export INFO_CONFIGURING_NGINX="Configurando Nginx..."
export INFO_GENERATING_SSL="Gerando certificado SSL..."
export INFO_CREATING_BACKUP="Criando backup..."
export INFO_RESTORING_BACKUP="Restaurando backup..."

# Mensagens de aviso
export WARN_HIGH_CPU="Alto uso de CPU detectado"
export WARN_HIGH_MEMORY="Alto uso de memória detectado"
export WARN_LOW_DISK="Pouco espaço em disco disponível"
export WARN_OLD_BACKUP="Backup antigo encontrado"
export WARN_PM2_MEMORY="Alto uso de memória no PM2"
export WARN_NGINX_LOAD="Alto número de conexões no Nginx"

# Função para mostrar mensagem de sucesso com estilo
success_message() {
    local message=$1
    printf "\n"
    center_text "┌─────────────────── ✅ Sucesso ───────────────────┐" "${COLOR_GREEN}"
    center_text "$message" "${COLOR_WHITE}"
    center_text "└──────────────────────────────────────────────────┘" "${COLOR_GREEN}"
    printf "\n"
}

# Função para mostrar mensagem de erro com estilo
error_message() {
    local message=$1
    printf "\n"
    center_text "┌──────────────────── ❌ Erro ────────────────────┐" "${COLOR_RED}"
    center_text "$message" "${COLOR_WHITE}"
    center_text "└─────────────────────────────────────────────────┘" "${COLOR_RED}"
    printf "\n"
}

# Função para mostrar mensagem de aviso com estilo
warning_message() {
    local message=$1
    printf "\n"
    center_text "┌─────────────────── ⚠️ Aviso ───────────────────┐" "${COLOR_YELLOW}"
    center_text "$message" "${COLOR_WHITE}"
    center_text "└─────────────────────────────────────────────────┘" "${COLOR_YELLOW}"
    printf "\n"
}

# Função para mostrar mensagem de informação com estilo
info_message() {
    local message=$1
    printf "\n"
    center_text "┌────────────────── ℹ️ Info ────────────────────┐" "${COLOR_BLUE}"
    center_text "$message" "${COLOR_WHITE}"
    center_text "└────────────────────────────────────────────────┘" "${COLOR_BLUE}"
    printf "\n"
}

# Função para mostrar progresso
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    printf "\r${COLOR_BLUE}["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] ${percentage}%%${COLOR_NC}"
}

# Função para mostrar spinner de carregamento
show_spinner() {
    local message=$1
    local pid=$2
    local spin='-\|/'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i + 1) % 4 ))
        printf "\r${COLOR_BLUE}${message} ${spin:$i:1}${COLOR_NC}"
        sleep .1
    done
    printf "\r"
}

# Função para mostrar caixa de confirmação
show_confirmation() {
    local message=$1
    printf "\n"
    center_text "┌─────────────── Confirmação ───────────────┐" "${COLOR_YELLOW}"
    center_text "$message" "${COLOR_WHITE}"
    center_text "└────────────────────────────────────────────┘" "${COLOR_YELLOW}"
    center_text "[S]im / [N]ão" "${COLOR_GREEN}"
    printf "\n"
    read -p "> " response
    case "$response" in
        [Ss]* ) return 0 ;;
        * ) return 1 ;;
    esac
}

# Função para mostrar caixa de entrada
show_input() {
    local message=$1
    local default=$2
    printf "\n"
    center_text "┌─────────────── Entrada ───────────────┐" "${COLOR_BLUE}"
    center_text "$message" "${COLOR_WHITE}"
    if [ ! -z "$default" ]; then
        center_text "(Padrão: $default)" "${COLOR_GRAY_LIGHT}"
    fi
    center_text "└────────────────────────────────────────┘" "${COLOR_BLUE}"
    printf "\n"
    read -p "> " response
    if [ -z "$response" ] && [ ! -z "$default" ]; then
        echo "$default"
    else
        echo "$response"
    fi
}
