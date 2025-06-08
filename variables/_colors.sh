#!/bin/bash

# Cores principais
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_BLUE='\033[0;34m'
COLOR_YELLOW='\033[1;33m'
COLOR_WHITE='\033[1;37m'
COLOR_GRAY_LIGHT='\033[0;37m'
COLOR_NC='\033[0m' # No Color

# Estilos
STYLE_BOLD='\033[1m'
STYLE_DIM='\033[2m'
STYLE_UNDERLINE='\033[4m'
STYLE_BLINK='\033[5m'
STYLE_REVERSE='\033[7m'
STYLE_HIDDEN='\033[8m'

# Cores de fundo
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_BLUE='\033[44m'
BG_YELLOW='\033[43m'

# Função para imprimir texto colorido
print_color() {
    local color=$1
    local text=$2
    echo -e "${color}${text}${COLOR_NC}"
}

# Função para imprimir texto com estilo
print_style() {
    local style=$1
    local text=$2
    echo -e "${style}${text}${COLOR_NC}"
}

# Função para imprimir texto com cor de fundo
print_bg() {
    local bg_color=$1
    local text=$2
    echo -e "${bg_color}${text}${COLOR_NC}"
}

# Função para imprimir mensagem de sucesso
print_success() {
    print_color "$COLOR_GREEN" "✅ $1"
}

# Função para imprimir mensagem de erro
print_error() {
    print_color "$COLOR_RED" "❌ $1"
}

# Função para imprimir mensagem de aviso
print_warning() {
    print_color "$COLOR_YELLOW" "⚠️ $1"
}

# Função para imprimir mensagem de informação
print_info() {
    print_color "$COLOR_BLUE" "ℹ️ $1"
} 