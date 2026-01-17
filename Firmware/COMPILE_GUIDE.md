# Guia de Compilação e Flash - Mac

## 📋 Pré-requisitos

Você já tem o compilador ARM instalado! ✅

Se não tivesse, instalar com:
```bash
brew install arm-none-eabi-gcc
```

## 🔨 Compilação

### 1. Navegue até a pasta Firmware:
```bash
cd Firmware
```

### 2. Limpe builds anteriores (opcional):
```bash
make MCU_TARGET=F407VG clean
```

### 3. Compile o firmware:
```bash
make MCU_TARGET=F407VG
```

**Para F407VG_DISCO:**
```bash
make MCU_TARGET=F407VG_DISCO
```

### 4. Arquivos gerados:
Após compilar, você terá:
- `build/OpenFFBoard_F407VG.hex` - Arquivo para flash
- `build/OpenFFBoard_F407VG.bin` - Arquivo binário alternativo
- `build/OpenFFBoard_F407VG.elf` - Arquivo para debug

## 📤 Flash no STM32

### ⭐ Opção 1: Via USB (DFU) - RECOMENDADO (Sem ST-Link!)

O OpenFFBoard tem suporte a **DFU (Device Firmware Update)** via USB! É a forma mais fácil.

#### 1. Instale o dfu-util:
```bash
brew install dfu-util
```

#### 2. Coloque a placa em modo DFU:

**Método A - Via comando serial (se a placa já está funcionando):**
1. Conecte a placa via USB
2. Abra o configurador ou terminal serial
3. Execute o comando: `dfu`
4. A placa entrará em modo DFU

**Método B - Via hardware (se a placa não está funcionando):**
1. **Desconecte** a placa do USB
2. **Segure o botão BOOT0** (ou conecte BOOT0 ao 3.3V)
3. **Conecte** a placa ao USB (mantendo BOOT0 pressionado)
4. **Solte** o botão BOOT0 após conectar
5. A placa deve entrar em modo DFU

#### 3. Verifique se está em modo DFU:
```bash
dfu-util --list
```

Você deve ver algo como:
```
Found DFU: [0483:df11] ...
```

#### 4. Faça o flash:
```bash
cd Firmware
dfu-util -a 0 -s 0x08000000:leave -D build/OpenFFBoard_F407VG.bin
```

**Para F407VG_DISCO:**
```bash
dfu-util -a 0 -s 0x08000000:leave -D build/OpenFFBoard_F407VG_DISCO.bin
```

**Parâmetros explicados:**
- `-a 0`: Interface alternativa 0 (flash)
- `-s 0x08000000:leave`: Endereço de início da flash, `:leave` sai do modo DFU após flash
- `-D`: Arquivo para fazer download

#### 5. Aguarde a conclusão:
Você verá algo como:
```
dfu-util: Downloading...
dfu-util: Download done.
dfu-util: Leaving DFU mode...
```

A placa deve reiniciar automaticamente!

---

### Opção 2: STM32CubeProgrammer (Requer ST-Link)

1. **Baixe e instale:**
   - https://www.st.com/en/development-tools/stm32cubeprog.html
   - Ou via Homebrew: `brew install --cask stm32cubeprog`

2. **Conecte a placa via ST-Link**

3. **Abra o STM32CubeProgrammer**

4. **Conecte:**
   - Interface: ST-LINK
   - Clique em "Connect"

5. **Carregue o arquivo:**
   - Clique em "Browse" e selecione: `build/OpenFFBoard_F407VG.hex`
   - Marque "Verify programming"
   - Clique em "Download"

## ✅ Verificação

Após o flash:
1. Reconecte a placa via USB
2. Verifique se aparece como dispositivo USB
3. Teste os botões do câmbio G27!

## 🐛 Solução de Problemas

### Erro de compilação:
```bash
# Limpe e recompile
make MCU_TARGET=F407VG clean
make MCU_TARGET=F407VG
```

### Erro de flash:
- Verifique se o ST-Link está conectado
- Tente desconectar e reconectar
- Verifique se a placa está em modo DFU (se necessário)

### Não encontra o dispositivo USB:
- Verifique se o flash foi bem-sucedido
- Tente resetar a placa
- Verifique os drivers USB

