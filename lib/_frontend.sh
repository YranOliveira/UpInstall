#!/bin/bash
# 
# functions for setting up app frontend

#######################################
# installed node packages
# Arguments:
#   None
#######################################
frontend_node_dependencies() {
  print_banner
  printf "${WHITE}🔄 Instalando dependências do frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Verificar dependências
  check_frontend_dependencies

  cd /home/deploy/empresas/$instancia_add/frontend
  
  # Limpar cache e node_modules
  if [ -d "node_modules" ]; then
    show_progress 10 "Removendo node_modules antigo..."
    rm -rf node_modules
  fi
  
  # Limpar cache do npm
  npm cache clean --force
  
  # Instalar dependências
  show_progress 30 "Instalando pacotes com npm..."
  npm install
  
  # Verificar se a instalação foi bem sucedida
  if [ $? -eq 0 ]; then
    printf "${GREEN}✅ Dependências do frontend instaladas com sucesso${NC}\n"
  else
    printf "${RED}❌ Erro ao instalar dependências do frontend${NC}\n"
    exit 1
  fi
}

#######################################
# compiles frontend code
# Arguments:
#   None
#######################################
frontend_node_build() {
  print_banner
  printf "${WHITE}🔄 Compilando o frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # Verificar espaço em disco
  check_disk_space

  cd /home/deploy/empresas/$instancia_add/frontend
  
  # Limpar build anterior se existir
  if [ -d "build" ]; then
    show_progress 10 "Removendo build anterior..."
    rm -rf build
  fi
  
  # Executar build
  show_progress 40 "Executando build do frontend..."
  npm run build
  
  # Verificar se o build foi bem sucedido
  if [ $? -eq 0 ] && [ -d "build" ]; then
    printf "${GREEN}✅ Build do frontend concluído com sucesso${NC}\n"
  else
    printf "${RED}❌ Erro ao fazer build do frontend${NC}\n"
    exit 1
  fi
}

#######################################
# updates frontend code
# Arguments:
#   None
#######################################
frontend_update() {
  print_banner
  printf "${WHITE} 💻 Atualizando o frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  su - deploy <<EOF
  cd /home/deploy/${empresa_atualizar}
  pm2 stop ${empresa_atualizar}-frontend
  git fetch
  git pull
  cd /home/deploy/${empresa_atualizar}/frontend
  npm install --force
  rm -rf build
  npm run build
  pm2 start ${empresa_atualizar}-frontend --max-memory-restart 512M
  pm2 save
EOF

  sleep 2
}


#######################################
# sets frontend environment variables
# Arguments:
#   None
#######################################
frontend_set_env() {
  print_banner
  printf "${WHITE} 💻 Configurando variáveis de ambiente (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  # ensure idempotency
  backend_url=$(echo "${backend_url/https:\/\/}")
  backend_url=${backend_url%%/*}
  backend_url=https://$backend_url

  su - deploy << EOF
  cat <<[-]EOF > /home/deploy/${instancia_add}/frontend/.env
REACT_APP_BACKEND_URL=${backend_url}
REACT_APP_HOURS_CLOSE_TICKETS_AUTO=
REACT_APP_LOCALE=pt-br
REACT_APP_TIMEZONE=America/Sao_Paulo
REACT_APP_TRIALEXPIRATION=7
[-]EOF
EOF

  sleep 2

  su - deploy << EOF
  cat <<[-]EOF > /home/deploy/${instancia_add}/frontend/server.js
const express = require("express");
const path = require("path");
const app = express();

app.use(express.static(path.join(__dirname, "build"), {
	dotfiles: 'deny', // Não permitir acesso a arquivos dotfiles
	index: false, // Desabilitar listagem de diretório
}));

app.get("/*", function (req, res) {
	res.sendFile(path.join(__dirname, "build", "index.html"), {
		dotfiles: 'deny', // Mesma regra para arquivos dotfiles aqui
	});
});
app.listen(${frontend_port});

[-]EOF
EOF

  sleep 2
}

#######################################
# starts pm2 for frontend
# Arguments:
#   None
#######################################
frontend_start_pm2() {
  print_banner
  printf "${WHITE}🔄 Iniciando servidor do frontend...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  cd /home/deploy/empresas/$instancia_add/frontend
  
  # Verificar se já existe uma instância rodando
  if pm2 list | grep -q "frontend-$instancia_add"; then
    show_progress 10 "Parando instância anterior..."
    pm2 delete "frontend-$instancia_add"
  fi
  
  # Iniciar nova instância
  show_progress 20 "Iniciando nova instância do frontend..."
  pm2 start server.js --name "frontend-$instancia_add" --max-memory-restart 250M
  
  # Verificar se o processo está rodando
  if pm2 list | grep -q "frontend-$instancia_add.*online"; then
    printf "${GREEN}✅ Servidor do frontend iniciado com sucesso${NC}\n"
    
    # Salvar configuração do PM2
    pm2 save
    
    # Gerar script de inicialização
    pm2 startup
  else
    printf "${RED}❌ Erro ao iniciar servidor do frontend${NC}\n"
    exit 1
  fi
}

#######################################
# sets up nginx for frontend
# Arguments:
#   None
#######################################
frontend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (frontend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  frontend_hostname=$(echo "${frontend_url/https:\/\/}")

 su - root << EOF

cat > /etc/nginx/sites-available/${instancia_add}-frontend << 'END'
server {
  server_name $frontend_hostname;

  location / {
    proxy_pass http://127.0.0.1:${frontend_port};
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

ln -s /etc/nginx/sites-available/${instancia_add}-frontend /etc/nginx/sites-enabled
EOF

  sleep 2
}

# Função para verificar e instalar dependências do frontend
check_frontend_dependencies() {
    local required_packages=("npm" "yarn" "serve")
    local missing_packages=()
    
    for package in "${required_packages[@]}"; do
        if ! command -v $package &> /dev/null; then
            missing_packages+=($package)
        fi
    done
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        printf "${RED}❌ Dependências do frontend faltando: ${missing_packages[*]}${NC}\n"
        printf "Instalando dependências...\n"
        
        if ! command -v npm &> /dev/null; then
            curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
            sudo apt-get install -y nodejs
        fi
        
        sudo npm install -g yarn serve
    fi
}

# Função para verificar espaço em disco para build
check_disk_space() {
    local required_space=5 # 5GB mínimo para build
    local available_space=$(df -BG /home/deploy | awk 'NR==2 {print $4}' | sed 's/G//')
    
    if [ $available_space -lt $required_space ]; then
        printf "${RED}❌ Espaço em disco insuficiente para build do frontend!${NC}\n"
        printf "Necessário: ${required_space}GB, Disponível: ${available_space}GB\n"
        exit 1
    fi
}
