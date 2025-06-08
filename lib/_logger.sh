#!/bin/bash

# Diretório de logs
LOG_DIR="/var/log/whaticket"
LOG_FILE="${LOG_DIR}/install.log"

# Criar diretório de logs se não existir
if [ ! -d "$LOG_DIR" ]; then
    sudo mkdir -p "$LOG_DIR"
    sudo chmod 755 "$LOG_DIR"
fi

# Função para registrar mensagem no log
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Criar arquivo de log se não existir
    if [ ! -f "$LOG_FILE" ]; then
        sudo touch "$LOG_FILE"
        sudo chmod 644 "$LOG_FILE"
    fi
    
    # Registrar mensagem
    echo "[$timestamp] [$level] $message" | sudo tee -a "$LOG_FILE" > /dev/null
}

# Função para registrar sucesso
log_success() {
    log_message "SUCCESS" "$1"
    print_success "$1"
}

# Função para registrar erro
log_error() {
    log_message "ERROR" "$1"
    print_error "$1"
}

# Função para registrar aviso
log_warning() {
    log_message "WARNING" "$1"
    print_warning "$1"
}

# Função para registrar informação
log_info() {
    log_message "INFO" "$1"
    print_info "$1"
}

# Função para limpar logs antigos (manter últimos 7 dias)
clean_old_logs() {
    find "$LOG_DIR" -name "*.log" -type f -mtime +7 -exec rm {} \;
}

# Função para exibir últimos logs
show_recent_logs() {
    local lines=${1:-50}
    if [ -f "$LOG_FILE" ]; then
        tail -n "$lines" "$LOG_FILE"
    else
        log_warning "Arquivo de log não encontrado"
    fi
}

# Função para rotacionar log quando atingir tamanho máximo (10MB)
rotate_log() {
    if [ -f "$LOG_FILE" ]; then
        local size=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE")
        if [ $size -gt 10485760 ]; then # 10MB em bytes
            local timestamp=$(date '+%Y%m%d_%H%M%S')
            sudo mv "$LOG_FILE" "${LOG_FILE}.${timestamp}"
            sudo touch "$LOG_FILE"
            sudo chmod 644 "$LOG_FILE"
            clean_old_logs
        fi
    fi
}

# Registrar início da instalação
log_info "Iniciando nova instalação do Whaticket SAAS"
rotate_log 