# Instalar Newlib para Compilar o Firmware

## ⚠️ Problema

O compilador ARM está instalado, mas falta o **newlib** (biblioteca padrão C para ARM).

## ✅ Solução Rápida

Execute no terminal:

```bash
# Opção 1: Instalar newlib separadamente (se disponível)
brew install arm-none-eabi-newlib

# Opção 2: Instalar toolchain completo (recomendado)
brew install gcc-arm-embedded
```

**Nota:** Se você receber erro de permissão, execute:
```bash
sudo chown -R $(whoami) /opt/homebrew/Cellar
```

## 🔨 Após Instalar, Compile:

```bash
cd Firmware
make MCU_TARGET=F407VG clean
make MCU_TARGET=F407VG
```

O arquivo `.hex` será gerado em: `Firmware/build/OpenFFBoard_F407VG.hex`

## 🚀 Ou Use o Script Automático:

```bash
cd Firmware
./build_hex.sh
```

O script tentará instalar o newlib automaticamente e compilar.
