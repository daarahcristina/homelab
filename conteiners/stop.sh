#!/bin/bash

# ==============================================================================
# Script para PARAR TODOS os serviços Docker Compose em um projeto
# ==============================================================================

# --- Funções de Cor ---
C_OFF='\033[0m'; C_BLUE='\033[0;34m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[0;33m'; C_RED='\033[0;31m'
info() { echo -e "${C_BLUE}INFO:${C_OFF} $1"; }
success() { echo -e "${C_GREEN}SUCESSO:${C_OFF} $1"; }

# --- Início da Lógica Principal ---
clear
echo "========================================================="
echo "    🛑 Buscando e Parando todos os Serviços Docker 🛑    "
echo "========================================================="
echo

find . -type f -name "docker-compose.yml" -print0 | while IFS= read -r -d '' file; do
    dir=$(dirname "$file")
    info "Encontrado arquivo em: ${C_YELLOW}${dir}${C_OFF}"
    echo "  -> Parando serviços e removendo contêineres..."
    (cd "$dir" && docker-compose down)
    success "Serviços em '${dir}' parados com sucesso."
    echo
done

echo
success "✅ Todos os projetos Docker Compose foram parados."
echo
