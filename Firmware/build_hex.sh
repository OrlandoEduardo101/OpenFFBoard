#!/bin/bash

# Script para compilar o firmware e gerar o arquivo .hex
# Para F407VG

set -e  # Para na primeira erro

echo "🔨 Compilando firmware OpenFFBoard_F407VG..."

# Verifica se o newlib está instalado
if ! find /opt/homebrew -path "*/arm-none-eabi/include/stdint.h" 2>/dev/null | grep -q "newlib"; then
    echo "⚠️  Newlib não encontrado. Tentando instalar..."

    # Tenta instalar o newlib
    if ! brew install arm-none-eabi-newlib 2>/dev/null; then
        echo "❌ Não foi possível instalar arm-none-eabi-newlib automaticamente."
        echo ""
        echo "Por favor, execute manualmente:"
        echo "  brew install arm-none-eabi-newlib"
        echo ""
        echo "Ou instale o toolchain completo:"
        echo "  brew install gcc-arm-embedded"
        echo ""
        exit 1
    fi
fi

# Limpa builds anteriores
echo "🧹 Limpando builds anteriores..."
make MCU_TARGET=F407VG clean

# Compila o firmware
echo "🔨 Compilando firmware..."
make MCU_TARGET=F407VG

# Verifica se o arquivo .hex foi gerado
HEX_FILE="build/OpenFFBoard_F407VG.hex"
if [ -f "$HEX_FILE" ]; then
    echo ""
    echo "✅ Compilação concluída com sucesso!"
    echo ""
    echo "📁 Arquivo .hex gerado em:"
    echo "   $(pwd)/$HEX_FILE"
    echo ""
    echo "📊 Tamanho do arquivo:"
    ls -lh "$HEX_FILE"
    echo ""
    echo "🚀 Pronto para fazer flash com STM32CubeProgrammer!"
else
    echo "❌ Erro: Arquivo .hex não foi gerado!"
    exit 1
fi
