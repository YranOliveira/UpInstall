# 🚀 Whaticket SAAS Installer

Sistema de instalação automatizada do Whaticket SAAS com recursos avançados de verificação e monitoramento.

## ⚡ Comandos de Instalação

### 📥 Primeira Instalação
```bash
sudo apt install -y git && git clone https://github.com/anozapvirus/instalandoprimeiravez.git && cd instalandoprimeiravez && sudo chmod +x install_primaria && sudo ./install_primaria
```

### ➕ Instalações Adicionais
```bash
cd /root/instalandoprimeiravez && sudo chmod +x install_primaria && sudo ./install_primaria
```

## 📋 Requisitos do Sistema

- Sistema Operacional: Ubuntu 20.04 ou superior
- Memória RAM: 4GB ou superior
- Processador: 2 cores ou superior
- Armazenamento: 20GB de espaço livre
- Acesso: Usuário root ou sudo

## 🔌 Portas Utilizadas

| Serviço | Porta | Descrição |
|---------|-------|-----------|
| Nginx | 80, 443 | Proxy Reverso |
| Frontend | 3000-3999 | Interface Web |
| Backend | 4000-4999 | API |
| Redis | 5000-5999 | Cache |

## 📂 Estrutura de Diretórios

```
/home/deploy/empresas/    # Instalações das empresas
├── empresa1/            # Primeira empresa
│   ├── frontend/       # Frontend da empresa
│   └── backend/        # Backend da empresa
├── empresa2/           # Segunda empresa
└── ...                 # Outras empresas

/var/log/whaticket/     # Logs do sistema
├── install.log        # Log de instalação
└── error.log         # Log de erros

/root/whaticket_backups/ # Backups automáticos
```

## 🛠️ Comandos Úteis

### 📊 Monitoramento
```bash
pm2 list                    # Lista todos os serviços
pm2 logs                    # Logs em tempo real
pm2 monit                   # Monitor de recursos
htop                        # Monitor do sistema
```

### 📝 Logs
```bash
tail -f /var/log/whaticket/install.log    # Log de instalação
tail -f /var/log/nginx/error.log          # Log de erros do Nginx
```

### 🔍 Verificação de Portas
```bash
sudo netstat -tlpn          # Lista todas as portas em uso
sudo lsof -i :porta        # Verifica processo usando a porta
```

### 🔄 Serviços
```bash
sudo systemctl restart nginx    # Reinicia Nginx
pm2 restart all                # Reinicia todos os serviços
pm2 save                       # Salva configuração do PM2
```

## ⚠️ Solução de Problemas

### Erro de Porta em Uso
1. Verifique qual processo está usando a porta:
   ```bash
   sudo lsof -i :porta
   ```
2. Encerre o processo ou escolha outra porta

### Problemas de Memória
1. Verifique o uso de memória:
   ```bash
   free -h
   ```
2. Monitore os processos:
   ```bash
   pm2 monit
   ```

### Certificado SSL
1. Renovar certificados:
   ```bash
   sudo certbot renew
   ```
2. Reiniciar Nginx:
   ```bash
   sudo systemctl restart nginx
   ```

## 🔒 Recursos de Segurança

- ✅ Verificação automática de portas
- ✅ Validação de domínios
- ✅ Backup automático
- ✅ Proteção contra duplicação
- ✅ Monitoramento de recursos
- ✅ Logs detalhados
- ✅ Certificados SSL

## 📱 Acesso após Instalação

- Frontend: `https://seudominio.com.br`
- Admin: `https://admin.seudominio.com.br`
- API: `https://api.seudominio.com.br`

## 🆘 Suporte

1. Verifique os logs em `/var/log/whaticket/`
2. Monitore os serviços com `pm2 list`
3. Verifique recursos com `htop`
4. Consulte logs do Nginx

## 📝 Notas Importantes

- Faça backup antes de atualizações
- Mantenha o sistema atualizado
- Monitore uso de recursos
- Verifique logs regularmente
- Renove certificados SSL

## 🤝 Contribuição

Para contribuir com o projeto:
1. Faça um Fork
2. Crie sua Feature Branch
3. Faça o Commit
4. Envie um Pull Request

## 📞 Contato

- Website: [seu-site.com.br]
- Email: [seu-email@dominio.com]
- WhatsApp: [seu-numero]

---
⭐ Se este projeto ajudou você, considere dar uma estrela no GitHub!