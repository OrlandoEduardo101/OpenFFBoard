# 🚀 Compilação Rápida - OpenFFBoard F407VG

## ⚡ Passos Rápidos

### 1. Instalar Dependências (se necessário)

```bash
# Instalar o newlib (biblioteca C para ARM)
brew install arm-none-eabi-newlib
```

**Nota:** Se você já tem `arm-none-eabi-gcc` instalado, só precisa do newlib.

### 2. Compilar o Firmware

```bash
cd Firmware

# Limpar builds anteriores
make MCU_TARGET=F407VG clean

# Compilar
make MCU_TARGET=F407VG
```

### 3. Verificar o Arquivo Gerado

Após compilar com sucesso, você terá:

```
Firmware/build/OpenFFBoard_F407VG.hex  ← Use este arquivo para flash!
```

### 4. Fazer Flash com STM32CubeProgrammer

1. **Abra o STM32CubeProgrammer**
2. **Conecte via ST-Link:**
   - Interface: ST-LINK
   - Clique em "Connect"
3. **Carregue o arquivo:**
   - Browse → `Firmware/build/OpenFFBoard_F407VG.hex`
   - Marque "Verify programming"
   - Clique em "Download"

## 🔧 Usando o Script Automático

Você também pode usar o script `build_hex.sh`:

```bash
cd Firmware
chmod +x build_hex.sh
./build_hex.sh
```

O script irá:
- ✅ Verificar se o newlib está instalado
- ✅ Limpar builds anteriores
- ✅ Compilar o firmware
- ✅ Verificar se o .hex foi gerado

## ⚠️ Problemas Comuns

### Erro: "stdint.h: No such file or directory"

**Solução:** Instale o newlib:
```bash
brew install arm-none-eabi-newlib
```

### Erro: "make: command not found"

**Solução:** Instale o make:
```bash
brew install make
```

### Erro: "arm-none-eabi-gcc: command not found"

**Solução:** Instale o toolchain:
```bash
brew install arm-none-eabi-gcc
```

## 📝 Notas

- O arquivo `.hex` é o formato recomendado para STM32CubeProgrammer
- O arquivo `.bin` também funciona, mas precisa especificar o endereço
- Após o flash, a placa reinicia automaticamente

## 🎯 Próximos Passos

Após compilar e fazer flash:
1. Teste os botões do câmbio G27
2. Configure o ShifterAnalog: `shifter mode 2` e `shifter cspin 1`
3. Teste os botões do volante (se conectado)
