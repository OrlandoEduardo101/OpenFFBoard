#!/bin/bash

# Script wrapper para executar OpenFFBoard no macOS
# Resolve problemas de permissão e configuração

APP_DIR="/Users/orlandoeduardo101/Projects/arduino/OpenFFBoard/Configurator/OpenFFBoard"
APP_EXE="$APP_DIR/OpenFFBoard"

# Mudar para o diretório do aplicativo
cd "$APP_DIR"

# Configurar variáveis de ambiente Python
export PYTHONHOME="$APP_DIR/_internal"
export PYTHONPATH="$APP_DIR/_internal"

# Executar o aplicativo
exec "$APP_EXE" "$@"

