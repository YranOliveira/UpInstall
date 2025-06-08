#!/bin/bash

get_mysql_root_password() {
    print_banner
    show_input "Digite a senha para o usuário Deploy e Banco de Dados" "deploy123"
}

get_link_git() {
    print_banner
    show_input "Digite o link do Github da sua instalação"
}

get_instancia_add() {
    print_banner
    show_input "Digite o nome para a Instancia/Empresa" ""
    local instancia_add=$response

    # Validar nome da instância
    if [[ ! $instancia_add =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]]; then
        error_message "Nome inválido! Use apenas letras minúsculas, números e hífen."
        sleep 2
        get_instancia_add
        return
    fi

    # Verificar se já existe
    if [ -d "/home/deploy/empresas/$instancia_add" ]; then
        error_message "Uma empresa com este nome já existe!"
        sleep 2
        get_instancia_add
        return
    fi
}

get_max_whats() {
    print_banner
    show_input "Digite a quantidade de conexões WhatsApp para ${instancia_add}" "3"
    local max_whats=$response

    # Validar número
    if ! [[ "$max_whats" =~ ^[0-9]+$ ]]; then
        error_message "Por favor, insira apenas números!"
        sleep 2
        get_max_whats
        return
    fi
}

get_max_user() {
    print_banner
    show_input "Digite a quantidade de usuários/atendentes para ${instancia_add}" "3"
    local max_user=$response

    # Validar número
    if ! [[ "$max_user" =~ ^[0-9]+$ ]]; then
        error_message "Por favor, insira apenas números!"
        sleep 2
        get_max_user
        return
    fi
}

get_frontend_url() {
    print_banner
    show_input "Digite o domínio do FRONTEND/PAINEL para ${instancia_add}" "painel.seudominio.com.br"
    local frontend_url=$response

    # Validar domínio - expressão regular mais flexível
    if [[ ! $frontend_url =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]\.[a-zA-Z.]{2,}$ ]]; then
        error_message "Domínio inválido! Formato esperado: exemplo.dominio.com.br"
        sleep 2
        get_frontend_url
        return
    fi
}

get_backend_url() {
    print_banner
    show_input "Digite o domínio do BACKEND/API para ${instancia_add}" "api.seudominio.com.br"
    local backend_url=$response

    # Validar domínio - expressão regular mais flexível
    if [[ ! $backend_url =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*[a-zA-Z0-9]\.[a-zA-Z.]{2,}$ ]]; then
        error_message "Domínio inválido! Formato esperado: api.dominio.com.br"
        sleep 2
        get_backend_url
        return
    fi
}

get_frontend_port() {
    print_banner
    show_input "Digite a porta do FRONTEND para ${instancia_add}" "3000"
    local frontend_port=$response

    # Validar porta
    if ! [[ "$frontend_port" =~ ^[0-9]+$ ]] || [ "$frontend_port" -lt 3000 ] || [ "$frontend_port" -gt 3999 ]; then
        error_message "Porta inválida! Use valores entre 3000 e 3999."
        sleep 2
        get_frontend_port
        return
    fi

    # Verificar se a porta está em uso
    if netstat -tuln | grep -q ":$frontend_port "; then
        error_message "Esta porta já está em uso!"
        sleep 2
        get_frontend_port
        return
    fi
}

get_backend_port() {
    print_banner
    show_input "Digite a porta do BACKEND para ${instancia_add}" "4000"
    local backend_port=$response

    # Validar porta
    if ! [[ "$backend_port" =~ ^[0-9]+$ ]] || [ "$backend_port" -lt 4000 ] || [ "$backend_port" -gt 4999 ]; then
        error_message "Porta inválida! Use valores entre 4000 e 4999."
        sleep 2
        get_backend_port
        return
    fi

    # Verificar se a porta está em uso
    if netstat -tuln | grep -q ":$backend_port "; then
        error_message "Esta porta já está em uso!"
        sleep 2
        get_backend_port
        return
    fi
}

get_redis_port() {
    print_banner
    show_input "Digite a porta do REDIS para ${instancia_add}" "5000"
    local redis_port=$response

    # Validar porta
    if ! [[ "$redis_port" =~ ^[0-9]+$ ]] || [ "$redis_port" -lt 5000 ] || [ "$redis_port" -gt 5999 ]; then
        error_message "Porta inválida! Use valores entre 5000 e 5999."
        sleep 2
        get_redis_port
        return
    fi

    # Verificar se a porta está em uso
    if netstat -tuln | grep -q ":$redis_port "; then
        error_message "Esta porta já está em uso!"
        sleep 2
        get_redis_port
        return
    fi
}

get_empresa_delete() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que será Deletada (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_delete
}

get_empresa_atualizar() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Atualizar (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_atualizar
}

get_empresa_bloquear() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Bloquear (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_bloquear
}

get_empresa_desbloquear() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Desbloquear (Digite o mesmo nome de quando instalou):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_desbloquear
}

get_empresa_dominio() {
  
  print_banner
  printf "${WHITE} 💻 Digite o nome da Instancia/Empresa que deseja Alterar os Dominios (Atenção para alterar os dominios precisa digitar os 2, mesmo que vá alterar apenas 1):${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " empresa_dominio
}

get_alter_frontend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o NOVO domínio do FRONTEND/PAINEL para a ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_url
}

get_alter_backend_url() {
  
  print_banner
  printf "${WHITE} 💻 Digite o NOVO domínio do BACKEND/API para a ${empresa_dominio}:${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_url
}

get_alter_frontend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do FRONTEND da Instancia/Empresa ${empresa_dominio}; A porta deve ser o mesma informada durante a instalação ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_frontend_port
}


get_alter_backend_port() {
  
  print_banner
  printf "${WHITE} 💻 Digite a porta do BACKEND da Instancia/Empresa ${empresa_dominio}; A porta deve ser o mesma informada durante a instalação ${GRAY_LIGHT}"
  printf "\n\n"
  read -p "> " alter_backend_port
}


get_urls() {
    get_mysql_root_password
    get_link_git
    get_instancia_add
    get_max_whats
    get_max_user
    get_frontend_url
    get_backend_url
    get_frontend_port
    get_backend_port
    get_redis_port
}

software_update() {
  get_empresa_atualizar
  frontend_update
  backend_update
}

software_delete() {
  get_empresa_delete
  deletar_tudo
}

software_bloquear() {
  get_empresa_bloquear
  configurar_bloqueio
}

software_desbloquear() {
  get_empresa_desbloquear
  configurar_desbloqueio
}

software_dominio() {
  get_empresa_dominio
  get_alter_frontend_url
  get_alter_backend_url
  get_alter_frontend_port
  get_alter_backend_port
  configurar_dominio
}

backup() {
  executar_backup
}

inquiry_options() {
    print_banner
    show_menu
    read -p "> " option

    case "${option}" in
        0) 
            info_message "Iniciando instalação do sistema..."
            get_urls 
            ;;
        1) 
            if show_confirmation "Deseja atualizar o sistema?"; then
                info_message "Iniciando atualização do sistema..."
                software_update 
            fi
            exit
            ;;
        2) 
            if show_confirmation "Tem certeza que deseja remover o sistema?"; then
                warning_message "Iniciando remoção do sistema..."
                software_delete 
            fi
            exit
            ;;
        3) 
            if show_confirmation "Deseja bloquear o sistema?"; then
                info_message "Bloqueando sistema..."
                software_block 
            fi
            exit
            ;;
        4) 
            if show_confirmation "Deseja desbloquear o sistema?"; then
                info_message "Desbloqueando sistema..."
                software_unblock 
            fi
            exit
            ;;
        5) 
            if show_confirmation "Deseja alterar o domínio do sistema?"; then
                info_message "Iniciando alteração de domínio..."
                software_domain 
            fi
            exit
            ;;    
        6) 
            if show_confirmation "Deseja fazer backup do sistema?"; then
                info_message "Iniciando backup do sistema..."
                backup 
            fi
            exit
            ;;            
        *) 
            error_message "Opção inválida!"
            sleep 2
            inquiry_options
            ;;
    esac
}


