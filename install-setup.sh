#!/usr/bin/env bash
source ./install_config.conf

# Verifica se o script está sendo executado como root
[[ $EUID -eq 0 ]] && echo -ne "USER ROOT:\tOK\n" || { echo "USE ACCOUNT ROOT"; exit 1; }

# Verifica se o arquivo de configuração existe e não está vazio
[[ ! -s install_config.conf ]] && { echo "O arquivo de configuração está vazio ou não existe."; exit 1; } || echo -ne "FILE CONF:\tOK\n"

# Detecta a distribuição e versão
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO="$ID"
    VERSION="$VERSION_ID"

    case "$DISTRO" in
        "debian")
            if [[ "$VERSION" == 12.* ]]; then
                echo "VERSION:\tOK"
            else
                echo "VERSION DEBIAN NOT SUPPORTED"
                exit 1
            fi
            ;;
        "ubuntu")
            if [[ "$VERSION" == 24.04 ]]; then
                echo "VERSION:\tOK"
            else
                echo "VERSION UBUNTU NOT SUPPORTED"
                exit 1
            fi
            ;;
        "centos")
            if [[ "$VERSION" == 8.* || "$VERSION" == 9.* ]]; then
                echo "VERSION:\tOK"
            else
                echo "VERSION CENTOS NOT SUPPORTED"
                exit 1
            fi
            ;;
        "rocky")
            if [[ "$VERSION" == 8.* || "$VERSION" == 9.* ]]; then
                echo "VERSION:\tOK"
            else
                echo "VERSION ROCKY NOT SUPPORTED"
                exit 1
            fi
            ;;
        "rhel")
            if [[ "$VERSION" == 8.* || "$VERSION" == 9.* ]]; then
                echo "VERSION:\tOK"
            else
                echo "VERSION RHEL NOT SUPPORTED"
                exit 1
            fi
            ;;
        *)
            echo "Distribuição não reconhecida."
            exit 1
            ;;
    esac
elif [[ -f /etc/redhat-release ]]; then
    DISTRO="centos"
else
    echo "Distribuição não reconhecida."
    exit 1
fi

# Função para atualizar e instalar pacotes com apt
function apt() {
    apt update -y
    apt install -y $install_command_apt
}

# Função para atualizar e instalar pacotes com dnf
function yum() {
    dnf update -y
    dnf install -y $install_command_dnf
}

# Função para instalar o repositório Zabbix
function repo-zabbix() {
    case $DISTRO in
        "centos" | "fedora" | "rhel" | "rocky")
            rpm -Uvh "https://repo.zabbix.com/zabbix/$version_zabbix_base/rhel/9/x86_64/zabbix-release-$version_zabbix_base-5.el9.noarch.rpm"
            ;;
        "ubuntu")
            wget "https://repo.zabbix.com/zabbix/$version_zabbix_base/ubuntu/pool/main/z/zabbix-release/zabbix-release_${version_zabbix_base}-6+ubuntu24.04_all.deb"
            dpkg -i "zabbix-release_${version_zabbix_base}-6+ubuntu24.04_all.deb"
            apt update
            ;;
        "debian")
            wget "https://repo.zabbix.com/zabbix/$version_zabbix_base/debian/pool/main/z/zabbix-release/zabbix-release_${version_zabbix_base}-5+debian12_all.deb"
            dpkg -i "zabbix-release_${version_zabbix_base}-5+debian12_all.deb"
            apt update
            ;;
        *)
            echo "Distribuição não suportada para repositório Zabbix."
            ;;
    esac
}

# Instalação pré-requisitos e repositório Zabbix
case $DISTRO in
    "debian" | "ubuntu")
        clear
        echo -en "\n========================= Install Pre-requ base Debian =========================\n"
        apt
        repo-zabbix
        ;;
    "centos" | "fedora" | "rhel" | "rocky")
        clear
        echo -en "\n========================= Install Pre-requ base RHEL =========================\n"
        yum
        repo-zabbix
        ;;
    *)
        echo "Distribuição não reconhecida."
        exit 1
        ;;
esac
