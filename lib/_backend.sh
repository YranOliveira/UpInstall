#!/bin/bash
#
# functions for setting up app backend
#######################################
# creates REDIS db using docker
# Arguments:
#   None
#######################################
backend_redis_create() {
  print_banner
  printf "${WHITE}🔄 Configurando Redis...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Verificar se o Redis já está instalado
  if ! command -v redis-cli &> /dev/null; then
    sudo apt-get install redis-server -y
  fi

  # Configurar Redis
  sudo sed -i "s/port 6379/port $redis_port/" /etc/redis/redis.conf
  sudo systemctl restart redis-server

  # Testar conexão
  if redis-cli -p $redis_port ping | grep -q "PONG"; then
    printf "${GREEN}✅ Redis configurado com sucesso na porta $redis_port${NC}\n"
  else
    printf "${RED}❌ Erro ao configurar Redis${NC}\n"
    exit 1
  fi
}

#######################################
# sets environment variable for backend.
# Arguments:
#   None
#######################################
backend_set_env() {
  print_banner
  printf "${WHITE} 💻 Configurando variáveis de ambiente (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # ensure idempotency
  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

  # ensure idempotency
  frontend_url=$(echo "${frontend_url/https:\/\/}")
  frontend_url=${frontend_url%%/*}
  frontend_url=https://$frontend_url

  su - deploy << EOF
  cat <<[-]EOF > /home/deploy/${instancia_add}/backend/.env
NODE_ENV=
BACKEND_URL=${backend_url}
FRONTEND_URL=${frontend_url}
PROXY_PORT=443
PORT=${backend_port}

DB_HOST=localhost
DB_DIALECT=postgres
DB_USER=${instancia_add}
DB_PASS=${mysql_root_password}
DB_NAME=${instancia_add}
DB_PORT=5432
JWT_SECRET=${jwt_secret}
JWT_REFRESH_SECRET=${jwt_refresh_secret}

REDIS_URI=redis://:${mysql_root_password}@127.0.0.1:${redis_port}
REDIS_OPT_LIMITER_MAX=1
REDIS_OPT_LIMITER_DURATION=3000
REDIS_HOST=127.0.0.1
REDIS_PORT=${redis_port}
REDIS_PASSWORD=${mysql_root_password}

REDIS_AUTHSTATE_SERVER=127.0.0.1
REDIS_AUTHSTATE_PORT=${redis_port}
REDIS_AUTHSTATE_PWD=${mysql_root_password}
REDIS_AUTHSTATE_DATABASE=

USER_LIMIT=${max_user}
CONNECTIONS_LIMIT=${max_whats}
CLOSED_SEND_BY_ME=true

GERENCIANET_SANDBOX=false
GERENCIANET_CLIENT_ID=sua-id
GERENCIANET_CLIENT_SECRET=sua_chave_secreta
GERENCIANET_PIX_CERT=nome_do_certificado
GERENCIANET_PIX_KEY=chave_pix_gerencianet

STRIPE_PUB=
STRIPE_PRIVATE=
STRIPE_OK_URL=
STRIPE_CANCEL_URL=

MP_ACCESS_TOKEN=
MP_PUBLIC_KEY=
MP_CLIENT_ID=
MP_CLIENT_SECRET=
MP_NOTIFICATION_URL=

[-]EOF
EOF

  sleep 2
}

#######################################
# installs node.js dependencies
# Arguments:
#   None
#######################################
backend_node_dependencies() {
  print_banner
  printf "${WHITE}🔄 Instalando dependências do backend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Verificar dependências do Node.js
  check_node_dependencies

  cd /home/deploy/${instancia_add}/backend
  
  # Limpar cache do npm
  npm cache clean --force
  
  # Instalar dependências
  show_progress 30 "Instalando pacotes com npm..."
  npm install
  
  # Verificar se a instalação foi bem sucedida
  if [ $? -eq 0 ]; then
    printf "${GREEN}✅ Dependências instaladas com sucesso${NC}\n"
  else
    printf "${RED}❌ Erro ao instalar dependências${NC}\n"
    exit 1
  fi
}

#######################################
# compiles backend code
# Arguments:
#   None
#######################################
backend_node_build() {
  print_banner
  printf "${WHITE} 💻 Compilando o código do backend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  su - deploy <<EOF
  cd /home/deploy/${instancia_add}/backend
  npm run build
EOF

  sleep 2
}

#######################################
# updates frontend code
# Arguments:
#   None
#######################################
backend_update() {
  print_banner
  printf "${WHITE} 💻 Atualizando o backend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  su - deploy <<EOF
  cd /home/deploy/${empresa_atualizar}
  pm2 stop ${empresa_atualizar}-backend
  git pull
  cd /home/deploy/${empresa_atualizar}/backend
  npm install
  npm update
  npm install @types/fs-extra
  rm -rf dist 
  npm run build
  npx sequelize db:migrate
  npx sequelize db:seed
  pm2 start ${empresa_atualizar}-backend
  pm2 save 
EOF

  sleep 2
}

#######################################
# runs db migrate
# Arguments:
#   None
#######################################
backend_db_migrate() {
  print_banner
  printf "${WHITE}🔄 Executando migrations do banco de dados...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Verificar e criar banco de dados
  check_and_create_db

  cd /home/deploy/${instancia_add}/backend
  
  # Executar migrations
  show_progress 20 "Executando migrations..."
  npx sequelize db:migrate
  
  # Verificar se as migrations foram bem sucedidas
  if [ $? -eq 0 ]; then
    printf "${GREEN}✅ Migrations executadas com sucesso${NC}\n"
  else
    printf "${RED}❌ Erro ao executar migrations${NC}\n"
    exit 1
  fi
}

#######################################
# runs db seed
# Arguments:
#   None
#######################################
backend_db_seed() {
  print_banner
  printf "${WHITE} 💻 Executando db:seed...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  su - deploy <<EOF
  cd /home/deploy/${instancia_add}/backend
  npx sequelize db:seed:all
EOF

  sleep 2
}

#######################################
# starts backend using pm2 in 
# production mode.
# Arguments:
#   None
#######################################
backend_start_pm2() {
  print_banner
  printf "${WHITE} 💻 Iniciando pm2 (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  su - deploy <<EOF
  cd /home/deploy/${instancia_add}/backend
  pm2 start dist/server.js --name ${instancia_add}-backend --max-memory-restart 512M
  pm2 save
EOF

  sleep 2
}

#######################################
# updates frontend code
# Arguments:
#   None
#######################################
backend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  backend_hostname=$(echo "${backend_url/https:\/\/}")

su - root << EOF
cat > /etc/nginx/sites-available/${instancia_add}-backend << 'END'
server {
  server_name $backend_hostname;
  location / {
    proxy_pass http://127.0.0.1:${backend_port};
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;
  }
}
END
ln -s /etc/nginx/sites-available/${instancia_add}-backend /etc/nginx/sites-enabled
EOF

  sleep 2
}

# Função para mostrar progresso
show_progress() {
    local duration=$1
    local message=$2
    local elapsed=0
    
    echo -ne "\n${message} "
    while [ $elapsed -lt $duration ]; do
        echo -ne "▓"
        sleep 0.1
        elapsed=$((elapsed + 1))
    done
    echo -e " ✅\n"
}

# Função para verificar dependências do Node.js
check_node_dependencies() {
    local required_packages=("npm" "yarn" "pm2")
    local missing_packages=()
    
    for package in "${required_packages[@]}"; do
        if ! command -v $package &> /dev/null; then
            missing_packages+=($package)
        fi
    done
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        printf "${RED}❌ Dependências faltando: ${missing_packages[*]}${NC}\n"
        printf "Instalando dependências...\n"
        
        if ! command -v npm &> /dev/null; then
            curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
            sudo apt-get install -y nodejs
        fi
        
        sudo npm install -g yarn pm2
    fi
}

# Função para verificar e criar banco de dados
check_and_create_db() {
    local db_name="$instancia_add"
    
    if mysql -u root -p"$mysql_root_password" -e "USE $db_name" 2>/dev/null; then
        printf "${RED}❌ Banco de dados '$db_name' já existe!${NC}\n"
        exit 1
    fi
    
    printf "${GREEN}✅ Criando banco de dados '$db_name'...${NC}\n"
    mysql -u root -p"$mysql_root_password" -e "CREATE DATABASE $db_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
}
