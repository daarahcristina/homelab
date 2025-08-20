#!/bin/bash

# ==============================================================================
# Script para INICIAR TODOS os serviços Docker Compose em um projeto
#
# Ele encontra recursivamente todos os arquivos 'docker-compose.yml' a partir
# do diretório atual e executa 'docker-compose up -d' em cada um.
# ==============================================================================

# --- Funções de Cor para Melhor Visualização ---
C_OFF='\033[0m'
C_BLUE='\033[0;34m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'

info() {
    echo -e "${C_BLUE}INFO:${C_OFF} $1"
}

success() {
    echo -e "${C_GREEN}SUCESSO:${C_OFF} $1"
}

warning() {
    echo -e "${C_YELLOW}AVISO:${C_OFF} $1"
}

error() {
    echo -e "${C_RED}ERRO:${C_OFF} $1" >&2
}

# --- Início da Lógica Principal ---
clear
echo "=========================================================="
echo "    🚀 Buscando e Iniciando todos os Serviços Docker 🚀    "
echo "=========================================================="
echo

# Encontra todos os arquivos docker-compose.yml, -print0 e o while read -r -d ''
# garantem que o script funcione mesmo com espaços nos nomes das pastas.
find . -type f -name "docker-compose.yml" -print0 | while IFS= read -r -d '' file; do
    
    # Pega o nome do diretório onde o arquivo foi encontrado
    dir=$(dirname "$file")
    
    info "Encontrado arquivo em: ${C_YELLOW}${dir}${C_OFF}"
    echo "  -> Iniciando serviços..."

    # Usa um subshell () para executar os comandos sem sair do diretório atual do script
    (cd "$dir" && docker-compose up -d)
    
    # Verifica se o comando anterior foi executado com sucesso
    if [ $? -eq 0 ]; then
        success "Serviços em '${dir}' iniciados com sucesso."
    else
        error "Falha ao iniciar serviços em '${dir}'."
        error "O script será interrompido. Verifique os logs para mais detalhes."
        exit 1 # Interrompe o script no primeiro erro
    fi
    echo # Linha em branco para separar

done

echo
success "🎉 Todos os projetos Docker Compose foram iniciados!"
echo
