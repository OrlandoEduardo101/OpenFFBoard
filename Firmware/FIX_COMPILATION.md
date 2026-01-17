# Corrigir Erro de Compilação - Mac

## Problema
O erro `fatal error: stdint.h: No such file or directory` ocorre porque falta o **newlib** (biblioteca padrão do ARM).

## Solução

### 1. Instale o newlib:
```bash
brew install arm-none-eabi-newlib
```

Se não funcionar, tente:
```bash
brew install --cask gcc-arm-embedded
```

### 2. Após instalar, compile novamente:
```bash
cd Firmware
make MCU_TARGET=F407VG clean
make MCU_TARGET=F407VG
```

## Alternativa: Usar Toolchain Completo

Se ainda não funcionar, instale o toolchain completo:

```bash
# Remover versões antigas
brew uninstall arm-none-eabi-gcc arm-none-eabi-binutils

# Instalar toolchain completo (inclui newlib)
brew install gcc-arm-embedded
```

Depois atualize o PATH ou use:
```bash
make MCU_TARGET=F407VG GCC_PATH=/opt/homebrew/bin
```

## Verificar Instalação

Após instalar, verifique:
```bash
find /opt/homebrew -path "*/arm-none-eabi/include/stdint.h" 2>/dev/null
```

Deve retornar um caminho. Se retornar vazio, o newlib não está instalado corretamente.

