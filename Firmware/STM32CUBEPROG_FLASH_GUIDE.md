# Guia de Compilação e Flash com STM32CubeProgrammer

## 📋 Pré-requisitos

### 1. Instalar o Compilador ARM GCC

**No Mac:**
```bash
brew install arm-none-eabi-gcc
```

**No Linux:**
```bash
sudo apt-get install gcc-arm-none-eabi
```

**No Windows:**
- Baixe de: https://developer.arm.com/downloads/-/gnu-rm
- Ou use o pacote do STM32CubeIDE

### 2. Instalar o STM32CubeProgrammer

**No Mac:**
```bash
brew install --cask stm32cubeprog
```

**No Linux/Windows:**
- Baixe de: https://www.st.com/en/development-tools/stm32cubeprog.html
- Ou via STM32CubeIDE (já incluído)

### 3. Hardware Necessário

- **ST-Link V2** (ou ST-Link V3) conectado à placa
- **Cabo USB** para conectar o ST-Link ao computador
- **Conexões ST-Link:**
  - **SWDIO** → SWDIO da placa
  - **SWCLK** → SWCLK da placa
  - **GND** → GND da placa
  - **3.3V** → 3.3V da placa (opcional, se o ST-Link fornecer alimentação)

## 🔨 Passo 1: Compilar o Firmware

### 1. Navegue até a pasta Firmware:
```bash
cd Firmware
```

### 2. Limpe builds anteriores (recomendado):
```bash
make MCU_TARGET=F407VG clean
```

### 3. Compile o firmware:
```bash
make MCU_TARGET=F407VG
```

**Para F407VG_DISCO:**
```bash
make MCU_TARGET=F407VG_DISCO clean
make MCU_TARGET=F407VG_DISCO
```

### 4. Verifique os arquivos gerados:

Após compilar com sucesso, você terá:

```
Firmware/build/
├── OpenFFBoard_F407VG.hex  ← Arquivo para flash via STM32CubeProgrammer
├── OpenFFBoard_F407VG.bin   ← Arquivo binário alternativo
└── OpenFFBoard_F407VG.elf   ← Arquivo para debug
```

**✅ O arquivo `.hex` é o que você precisa para o STM32CubeProgrammer!**

## 📤 Passo 2: Flash com STM32CubeProgrammer

### 1. Conecte o Hardware

1. **Conecte o ST-Link** à placa OpenFFBoard:
   - **SWDIO** → SWDIO
   - **SWCLK** → SWCLK
   - **GND** → GND
   - **3.3V** → 3.3V (se necessário)

2. **Conecte o ST-Link ao computador** via USB

3. **Alimente a placa** (via USB ou fonte externa)

### 2. Abra o STM32CubeProgrammer

- **No Mac:** Abra via Spotlight ou Applications
- **No Linux/Windows:** Execute o programa instalado

### 3. Configure a Conexão

1. **Selecione a Interface:**
   - No topo da janela, selecione **"ST-LINK"**
   - Se você tiver ST-Link V3, selecione **"ST-LINK V3"**

2. **Configure a Porta:**
   - **Port:** Deixe em "USB" (padrão)
   - **Speed:** Deixe em "4.0 MHz" (padrão) ou reduza para "1.8 MHz" se houver problemas

3. **Clique em "Connect"** (botão no canto superior direito)

4. **Aguarde a conexão:**
   - Você verá informações do dispositivo na tela
   - Deve aparecer algo como:
     ```
     Device name: STM32F407VG
     Device ID: 0x413
     ```

### 4. Carregue o Arquivo .hex

1. **Na aba "Erasing & Programming":**
   - Clique em **"Browse"** ao lado de "File path"
   - Navegue até: `Firmware/build/OpenFFBoard_F407VG.hex`
   - Selecione o arquivo

2. **Configure as Opções:**
   - ✅ **"Verify programming"** - Recomendado (verifica após flash)
   - ✅ **"Erase necessary pages"** - Recomendado (apaga apenas o necessário)
   - ⚠️ **"Skip flash on verify"** - Deixe desmarcado
   - ⚠️ **"Run after programming"** - Deixe marcado (reinicia após flash)

3. **Endereço de Flash:**
   - Deixe em **"0x08000000"** (padrão para STM32F4)

### 5. Execute o Flash

1. **Clique em "Download"** (botão azul no canto inferior direito)

2. **Aguarde a conclusão:**
   - Você verá o progresso na barra
   - Mensagens como:
     ```
     File download complete
     File verified successfully
     ```

3. **A placa deve reiniciar automaticamente** após o flash

### 6. Desconecte

1. **Clique em "Disconnect"** (botão no canto superior direito)

2. **Desconecte o ST-Link** (se necessário)

## ✅ Passo 3: Verificação

### 1. Reconecte a Placa via USB

- Conecte a placa OpenFFBoard diretamente ao computador via USB
- Não precisa mais do ST-Link para uso normal

### 2. Verifique se Funciona

1. **Verifique se aparece como dispositivo USB:**
   ```bash
   # No Mac/Linux
   lsusb | grep STM

   # Ou verifique no gerenciador de dispositivos (Windows)
   ```

2. **Teste a comunicação:**
   - Abra o OpenFFBoard Configurator
   - Ou use um terminal serial para enviar comandos
   - Teste comandos básicos como `help`

3. **Teste os recursos:**
   - Teste os botões do câmbio G27
   - Teste o PWM (se configurado)
   - Verifique se tudo está funcionando

## 🐛 Solução de Problemas

### Erro: "No ST-LINK detected"

**Soluções:**
1. Verifique se o ST-Link está conectado via USB
2. Verifique se os drivers estão instalados
3. Tente desconectar e reconectar o ST-Link
4. No Windows, instale os drivers do ST-Link

### Erro: "Connection failed"

**Soluções:**
1. Verifique as conexões SWDIO, SWCLK e GND
2. Reduza a velocidade do ST-Link (1.8 MHz)
3. Verifique se a placa está alimentada
4. Tente resetar a placa antes de conectar

### Erro: "File not found"

**Soluções:**
1. Verifique se o arquivo `.hex` foi gerado: `ls Firmware/build/`
2. Recompile o firmware: `make MCU_TARGET=F407VG`
3. Verifique o caminho do arquivo no STM32CubeProgrammer

### Erro: "Verify failed"

**Soluções:**
1. Tente fazer flash novamente
2. Verifique se há proteção de escrita na flash
3. Tente fazer "Full chip erase" antes de flash
4. Verifique se o arquivo `.hex` não está corrompido

### A placa não reinicia após flash

**Soluções:**
1. Desconecte e reconecte a alimentação
2. Pressione o botão RESET na placa
3. Verifique se o flash foi bem-sucedido
4. Tente fazer flash novamente

### Erro de Compilação

**Soluções:**
```bash
# Limpe e recompile
cd Firmware
make MCU_TARGET=F407VG clean
make MCU_TARGET=F407VG

# Verifique se o compilador está instalado
arm-none-eabi-gcc --version
```

## 📝 Notas Importantes

### Backup Antes de Flash

**Sempre faça backup antes de fazer flash!**

1. **No STM32CubeProgrammer:**
   - Conecte à placa
   - Vá em **"File" → "Save File As"**
   - Selecione **"Binary file"** ou **"Intel Hex"**
   - Salve o arquivo atual da flash

### Proteção de Flash

Se você receber erro de proteção:

1. **No STM32CubeProgrammer:**
   - Vá na aba **"Option Bytes"**
   - Desmarque **"Read Out Protection"** (se estiver ativo)
   - Clique em **"Apply"**

### Endereço de Flash

- **STM32F407VG:** `0x08000000` (padrão)
- **STM32F411RE:** `0x08000000` (padrão)
- Não altere este endereço a menos que saiba o que está fazendo!

### Formatos de Arquivo

- **`.hex`** - Intel Hex (recomendado para STM32CubeProgrammer)
- **`.bin`** - Binário puro (também funciona, mas precisa especificar endereço)
- **`.elf`** - Para debug, não para flash direto

## 🎉 Pronto!

Agora você sabe como compilar e fazer flash do firmware usando STM32CubeProgrammer!

**Dica:** Se você tiver acesso USB, considere usar o método **DFU** (mais fácil, sem ST-Link). Veja o guia `DFU_FLASH_GUIDE.md` para mais detalhes.
