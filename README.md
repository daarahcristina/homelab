# Meu Homelab com Docker e Acesso Seguro via Twingate

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)
![Twingate](https://img.shields.io/badge/Twingate-3A79F7?style=for-the-badge&logo=twingate&logoColor=white)
![Nextcloud](https://img.shields.io/badge/Nextcloud-0082C9?style=for-the-badge&logo=nextcloud&logoColor=white)
![Jellyfin](https://img.shields.io/badge/Jellyfin-5D4993?style=for-the-badge&logo=jellyfin&logoColor=white)
![Uptime Kuma](https://img.shields.io/badge/Uptime_Kuma-4F46E5?style=for-the-badge)

Este repositório contém a configuração completa para a criação de um homelab versátil e seguro, utilizando Docker para orquestrar os serviços e Twingate para fornecer acesso remoto baseado no princípio de **Zero Trust Network Access (ZTNA)**.

## ✨ Sobre o Projeto

O objetivo deste projeto é demonstrar como criar uma infraestrutura de serviços auto-hospedados (self-hosted) que promova a soberania digital e a privacidade, sem sacrificar a conveniência do acesso remoto. Ao invés de expor portas na internet ou configurar uma VPN complexa, utilizamos o Twingate para criar um perímetro seguro e definido por software, garantindo que apenas usuários autenticados possam acessar os serviços internos.

## 🚀 Principais Funcionalidades

* ☁️ **Nuvem Pessoal com Nextcloud:** Sincronização de arquivos, calendário, contatos e muito mais, sob seu controle total.
* 🎬 **Streaming de Mídia com Jellyfin:** Sua própria Netflix pessoal, organizando e transmitindo sua coleção de filmes, séries e músicas.
* 📊 **Monitoramento com Uptime Kuma:** Um painel de controle elegante para monitorar a disponibilidade de todos os seus serviços, com notificações em tempo real.
* 🔒 **Acesso Remoto Seguro com Twingate:** Acesso a todos os serviços de qualquer lugar do mundo sem expor nenhuma porta do seu servidor à internet.

## 🛠️ Arquitetura do Projeto

A arquitetura é projetada para ser simples e segura:

1.  **Servidor:** Uma máquina física ou VM com Ubuntu Server.
2.  **Docker:** Todos os serviços (Nextcloud, Jellyfin, Uptime Kuma) rodam em contêineres Docker isolados, orquestrados via Docker Compose.
3.  **Rede Interna:** Os contêineres se comunicam em uma rede Docker privada e não são expostos diretamente na rede local ou na internet.
4.  **Twingate Connector:** Um contêiner Docker dedicado atua como um conector para a rede Twingate. Ele inicia uma conexão segura de *saída* para a infraestrutura da Twingate, o que significa que nenhuma porta de *entrada* precisa ser aberta no firewall.
5.  **Acesso do Cliente:** Para acessar os serviços, o usuário utiliza o cliente Twingate em seu dispositivo (notebook, celular), que o autentica e o conecta de forma segura aos recursos liberados.


## ⚙️ Configuração Passo a Passo

### 1. Pré-requisitos

* Um servidor com **Ubuntu Server 22.04 LTS** ou superior.
* **Docker** e **Docker Compose** instalados.
* Uma conta gratuita no **[Twingate](https://www.twingate.com/)**.

### 2. Estrutura de Diretórios

Para uma melhor organização, crie a seguinte estrutura de pastas no seu servidor:

bash
mkdir -p homelab/nextcloud/data homelab/nextcloud/config homelab/jellyfin/config homelab/jellyfin/media homelab/uptime-kuma/data
cd homelab 

### 3. Docker Compose
* Criar um arquivo docker-compose.yml dentro da pasta de cada aplicação a ser subida no homelab.

version: "3.8"

networks:
  homelab-net:
    driver: bridge

services:
  # --- Nuvem Pessoal ---
  nextcloud:
    image: linuxserver/nextcloud:latest
    container_name: nextcloud
    restart: unless-stopped
    networks:
      - homelab-net
    environment:
      - PUID=1000 # Rode 'id -u' no terminal para pegar seu ID
      - PGID=1000 # Rode 'id -g' no terminal para pegar seu ID
      - TZ=America/Sao_Paulo
    volumes:
      - ./nextcloud/config:/config
      - ./nextcloud/data:/data
    depends_on:
      - nextcloud-db

  nextcloud-db:
    image: postgres:15
    container_name: nextcloud-db
    restart: unless-stopped
    networks:
      - homelab-net
    volumes:
      - ./nextcloud/db:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=nextcloud
      - POSTGRES_USER=nextcloud
      - POSTGRES_PASSWORD=sua_senha_forte_aqui # MUDE ISTO

  # --- Servidor de Mídia ---
  jellyfin:
    image: linuxserver/jellyfin:latest
    container_name: jellyfin
    restart: unless-stopped
    networks:
      - homelab-net
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Sao_Paulo
    volumes:
      - ./jellyfin/config:/config
      - ./jellyfin/media:/data/media # Coloque seus filmes/séries aqui

  # --- Monitoramento ---
  uptime-kuma:
    image: louislam/uptime-kuma:1
    container_name: uptime-kuma
    restart: unless-stopped
    networks:
      - homelab-net
    volumes:
      - ./uptime-kuma/data:/app/data

### 4. Configuração do Twingate
  1. Crie uma Rede Remota: No painel do Twingate, vá em Network -> Remote Networks e crie uma nova rede (ex: "Homelab").
  2. Instale o Connector:
    - Dentro da sua nova rede remota, clique em Connectors e adicione um novo conector.
    - Escolha a opção Docker. O Twingate fornecerá um comando docker run com suas chaves de acesso.
    - Execute o comando fornecido pelo Twingate no seu servidor. Isso irá baixar e iniciar o contêiner do conector. Após alguns instantes, você verá o status do conector como "Connected" no painel do Twingate.
  3. Adicione os Recursos (Serviços):
    - Vá para a sua rede remota ("Homelab") e clique em Add Resource.
    - Crie um recurso para cada serviço que você quer acessar. Use o nome do contêiner Docker como o endereço.
      * Recurso 1: Jellyfin
      * Label: Jellyfin
      * DNS Address: jellyfin.homelab.local (este será o endereço que você usará no seu navegador)
      * Private Address: jellyfin:8096 (nome_do_contêiner:porta_interna)
      * Port Restrictions: TCP 8096

      * Recurso 2: Nextcloud
      * Label: Nextcloud
      * DNS Address: nextcloud.homelab.local
      * Private Address: nextcloud:443
      * Port Restrictions: TCP 443

      * Recurso 3: Uptime Kuma
      * Label: Uptime Kuma
      * DNS Address: kuma.homelab.local
      * Private Address: uptime-kuma:3001
      * Port Restrictions: TCP 3001

  4. Dê Permissão de Acesso: Adicione seu usuário aos grupos que têm permissão para acessar esses novos recursos.

### 5. Inicie os serviços com: docker-compose up -d

### 6. Acessando Remotamente
  1. Baixe e instale o cliente Twingate no seu notebook, celular ou outro dispositivo.
  2. Faça login na sua conta.
  3. Agora, basta abrir o navegador e acessar os endereços que você configurou (ex: http://jellyfin.homelab.local, http://kuma.homelab.local). O acesso será transparente e seguro!
  
