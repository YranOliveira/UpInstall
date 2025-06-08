#!/bin/bash

# Função para validar domínio
validate_domain() {
    local domain=$1
    local domain_regex="^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$"
    
    if [[ ! $domain =~ $domain_regex ]]; then
        log_error "$ERR_INVALID_DOMAIN"
        return 1
    fi
    return 0
}

# Função para validar porta
validate_port() {
    local port=$1
    local min_port=${2:-1024}
    local max_port=${3:-65535}
    
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt $min_port ] || [ "$port" -gt $max_port ]; then
        log_error "$ERR_INVALID_PORT"
        return 1
    fi
    
    if netstat -tuln | grep -q ":$port "; then
        log_error "$ERR_INVALID_PORT"
        return 1
    fi
    
    return 0
}

# Função para validar nome da empresa
validate_company_name() {
    local company=$1
    local company_regex="^[a-z0-9][a-z0-9-]*[a-z0-9]$"
    
    if [[ ! $company =~ $company_regex ]]; then
        log_error "$ERR_INVALID_COMPANY"
        return 1
    fi
    
    if [ -d "/home/deploy/empresas/$company" ]; then
        log_error "$ERR_COMPANY_EXISTS"
        return 1
    fi
    
    return 0
}

# Função para verificar dependência
check_dependency() {
    local dependency=$1
    local install_cmd=${2:-""}
    
    if ! command -v "$dependency" &> /dev/null; then
        if [ -n "$install_cmd" ]; then
            log_warning "$ERR_MISSING_DEPENDENCY: $dependency"
            log_info "Instalando $dependency..."
            eval "$install_cmd"
            if [ $? -ne 0 ]; then
                log_error "Falha ao instalar $dependency"
                return 1
            fi
        else
            log_error "$ERR_MISSING_DEPENDENCY: $dependency"
            return 1
        fi
    fi
    return 0
}

# Função para verificar serviço
check_service() {
    local service=$1
    
    if ! systemctl is-active --quiet "$service"; then
        log_warning "Serviço $service não está rodando"
        log_info "Iniciando $service..."
        sudo systemctl start "$service"
        if [ $? -ne 0 ]; then
            log_error "Falha ao iniciar $service"
            return 1
        fi
    fi
    return 0
}

# Função para fazer backup de arquivo
backup_file() {
    local file=$1
    local backup_dir=${2:-"/root/whaticket_backups"}
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    
    if [ -f "$file" ]; then
        mkdir -p "$backup_dir"
        cp "$file" "${backup_dir}/$(basename "$file").${timestamp}"
        return 0
    fi
    return 1
}

# Função para verificar espaço em disco
check_disk_space() {
    local path=${1:-"/"}
    local min_space=${2:-5} # GB
    
    local free_space=$(df -BG "$path" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$free_space" -lt "$min_space" ]; then
        log_warning "$WARN_LOW_DISK"
        return 1
    fi
    return 0
}

# Função para verificar uso de memória
check_memory_usage() {
    local min_free=${1:-1024} # MB
    local free_mem=$(free -m | awk '/^Mem:/ {print $4}')
    
    if [ "$free_mem" -lt "$min_free" ]; then
        log_warning "$WARN_HIGH_MEMORY"
        return 1
    fi
    return 0
}

# Função para verificar uso de CPU
check_cpu_usage() {
    local max_load=${1:-80} # porcentagem
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    
    if [ "$cpu_usage" -gt "$max_load" ]; then
        log_warning "$WARN_HIGH_CPU"
        return 1
    fi
    return 0
}

# Função para verificar conexões do Nginx
check_nginx_connections() {
    local max_conn=${1:-500}
    local curr_conn=$(netstat -an | grep :80 | wc -l)
    
    if [ "$curr_conn" -gt "$max_conn" ]; then
        log_warning "$WARN_NGINX_LOAD"
        return 1
    fi
    return 0
}

# Função para verificar uso de memória do PM2
check_pm2_memory() {
    local max_mem=${1:-500} # MB
    local processes=$(pm2 jlist)
    
    if [ -n "$processes" ]; then
        local total_mem=$(echo "$processes" | jq -r '.[].monit.memory' | awk '{sum+=$1} END {print sum/1024/1024}')
        if [ "${total_mem%.*}" -gt "$max_mem" ]; then
            log_warning "$WARN_PM2_MEMORY"
            return 1
        fi
    fi
    return 0
}

# Função para limpar arquivos temporários
cleanup_temp_files() {
    local temp_dir=${1:-"/tmp"}
    local days_old=${2:-7}
    
    find "$temp_dir" -type f -mtime +"$days_old" -delete
    return 0
}

# Função para verificar certificado SSL
check_ssl_cert() {
    local domain=$1
    local days_warning=${2:-30}
    
    if [ -f "/etc/letsencrypt/live/$domain/cert.pem" ]; then
        local expiry=$(openssl x509 -enddate -noout -in "/etc/letsencrypt/live/$domain/cert.pem" | cut -d= -f2)
        local expiry_date=$(date -d "$expiry" +%s)
        local current_date=$(date +%s)
        local days_left=$(( ($expiry_date - $current_date) / 86400 ))
        
        if [ "$days_left" -lt "$days_warning" ]; then
            log_warning "Certificado SSL para $domain expira em $days_left dias"
            return 1
        fi
    else
        log_error "Certificado SSL não encontrado para $domain"
        return 1
    fi
    return 0
} 