#!/bin/bash

get_mysql_root_password() {
    print_banner
    printf "${COLOR_WHITE} 💻 Insira senha para o usuario Deploy e Banco de Dados (Não utilizar caracteres especiais):${COLOR_GRAY_LIGHT}"
    printf "\n\n"
    read -p "> " mysql_root_password
}

get_link_git() {
    print_banner
    printf "${COLOR_WHITE} 💻 Insira o link do Github da sua instalação que deseja instalar:${COLOR_GRAY_LIGHT}"
    printf "\n\n"
    read -p "> " link_git
}

get_instancia_add() {
    print_banner
    printf "${COLOR_WHITE} 💻 Informe um nome para a Instancia/Empresa que será instalada${COLOR_GRAY_LIGHT}"
    printf "\n${COLOR_YELLOW}(Não utilizar espaços ou caracteres especiais, Utilizar Letras minusculas)${COLOR_GRAY_LIGHT}"
    printf "\n\n"
    read -p "> " instancia_add

    # Validar nome da instância
    if [[ ! $instancia_add =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]]; then
        print_error "Nome inválido! Use apenas letras minúsculas, números e hífen."
        sleep 2
        get_instancia_add
        return
    fi

    # Verificar se já existe
    if [ -d "/home/deploy/empresas/$instancia_add" ]; then
        print_error "Uma empresa com este nome já existe!"
        sleep 2
        get_instancia_add
        return
    fi
}

get_max_whats() {
    print_banner
    printf "${COLOR_WHITE} 💻 Informe a Qtde de Conexões/Whats que a ${COLOR_GREEN}${instancia_add}${COLOR_WHITE} poderá cadastrar:${COLOR_GRAY_LIGHT}"
    printf "\n\n"
    read -p "> " max_whats

    # Validar número
    if ! [[ "$max_whats" =~ ^[0-9]+$ ]]; then
        print_error "Por favor, insira apenas números!"
        sleep 2
        get_max_whats
        return
    fi
}

get_max_user() {
    print_banner
    printf "${COLOR_WHITE} 💻 Informe a Qtde de Usuarios/Atendentes que a ${COLOR_GREEN}${instancia_add}${COLOR_WHITE} poderá cadastrar:${COLOR_GRAY_LIGHT}"
    printf "\n\n"
    read -p "> " max_user

    # Validar número
    if ! [[ "$max_user" =~ ^[0-9]+$ ]]; then
        print_error "Por favor, insira apenas números!"
        sleep 2
        get_max_user
        return
    fi
}

get_frontend_url() {
    print_banner
    printf "${COLOR_WHITE} 💻 Digite o domínio do FRONTEND/PAINEL para a ${COLOR_GREEN}${instancia_add}${COLOR_WHITE}:${COLOR_GRAY_LIGHT}"
    printf "\n${COLOR_YELLOW}(Exemplo: painel.seudominio.com.br)${COLOR_GRAY_LIGHT}"
    printf "\n\n"
    read -p "> " frontend_url

    # Validar domínio
    if [[ ! $frontend_url =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
        print_error "Domínio inválido!"
        sleep 2
        get_frontend_url
        return
    fi
}

get_backend_url() {
    print_banner
    printf "${COLOR_WHITE} 💻 Digite o domínio do BACKEND/API para a ${COLOR_GREEN}${instancia_add}${COLOR_WHITE}:${COLOR_GRAY_LIGHT}"
    printf "\n${COLOR_YELLOW}(Exemplo: api.seudominio.com.br)${COLOR_GRAY_LIGHT}"
    printf "\n\n"
    read -p "> " backend_url

    # Validar domínio
    if [[ ! $backend_url =~ ^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]\.[a-zA-Z]{2,}$ ]]; then
        print_error "Domínio inválido!"
        sleep 2
        get_backend_url
        return
    fi
}

get_frontend_port() {
    print_banner
    printf "${COLOR_WHITE} 💻 Digite a porta do FRONTEND para a ${COLOR_GREEN}${instancia_add}${COLOR_WHITE}:${COLOR_GRAY_LIGHT}"
    printf "\n${COLOR_YELLOW}(Utilize portas entre 3000 e 3999)${COLOR_GRAY_LIGHT}"
    printf "\n\n"
    read -p "> " frontend_port

    # Validar porta
    if ! [[ "$frontend_port" =~ ^[0-9]+$ ]] || [ "$frontend_port" -lt 3000 ] || [ "$frontend_port" -gt 3999 ]; then
        print_error "Porta inválida! Use valores entre 3000 e 3999."
        sleep 2
        get_frontend_port
        return
    fi

    # Verificar se a porta está em uso
    if netstat -tuln | grep -q ":$frontend_port "; then
        print_error "Esta porta já está em uso!"
        sleep 2
        get_frontend_port
        return
    fi
}

get_backend_port() {
    print_banner
    printf "${COLOR_WHITE} 💻 Digite a porta do BACKEND para a ${COLOR_GREEN}${instancia_add}${COLOR_WHITE}:${COLOR_GRAY_LIGHT}"
    printf "\n${COLOR_YELLOW}(Utilize portas entre 4000 e 4999)${COLOR_GRAY_LIGHT}"
    printf "\n\n"
    read -p "> " backend_port

    # Validar porta
    if ! [[ "$backend_port" =~ ^[0-9]+$ ]] || [ "$backend_port" -lt 4000 ] || [ "$backend_port" -gt 4999 ]; then
        print_error "Porta inválida! Use valores entre 4000 e 4999."
        sleep 2
        get_backend_port
        return
    fi

    # Verificar se a porta está em uso
    if netstat -tuln | grep -q ":$backend_port "; then
        print_error "Esta porta já está em uso!"
        sleep 2
        get_backend_port
        return
    fi
}

get_redis_port() {
    print_banner
    printf "${COLOR_WHITE} 💻 Digite a porta do REDIS para a ${COLOR_GREEN}${instancia_add}${COLOR_WHITE}:${COLOR_GRAY_LIGHT}"
    printf "\n${COLOR_YELLOW}(Utilize portas entre 5000 e 5999)${COLOR_GRAY_LIGHT}"
    printf "\n\n"
    read -p "> " redis_port

    # Validar porta
    if ! [[ "$redis_port" =~ ^[0-9]+$ ]] || [ "$redis_port" -lt 5000 ] || [ "$redis_port" -gt 5999 ]; then
        print_error "Porta inválida! Use valores entre 5000 e 5999."
        sleep 2
        get_redis_port
        return
    fi

    # Verificar se a porta está em uso
    if netstat -tuln | grep -q ":$redis_port "; then
        print_error "Esta porta já está em uso!"
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
        0) get_urls ;;
        1) 
            software_update 
            exit
            ;;
        2) 
            software_delete 
            exit
            ;;
        3) 
            software_bloquear 
            exit
            ;;
        4) 
            software_desbloquear 
            exit
            ;;
        5) 
            software_dominio 
            exit
            ;;    
        6) 
            backup 
            exit
            ;;            
        *) 
            print_error "Opção inválida!"
            sleep 2
            inquiry_options
            ;;
    esac
}


