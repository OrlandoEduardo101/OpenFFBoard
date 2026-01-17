 # Guia de Teste - Firmware F407VG_DISCO com PC2 e PC3 ADC

Este guia explica como testar com segurança a nova firmware que adiciona as entradas ADC PC2 e PC3 na placa STM32F407 Discovery.

## ⚠️ IMPORTANTE - Antes de Começar

1. **Fazer backup da firmware atual** - Se algo der errado, você pode reverter
2. **Ter acesso ao ST-Link** - Necessário para fazer flash e recuperação
3. **Verificar que você tem a placa correta** - STM32F407 Discovery (não a placa oficial FFBoard)

## 📋 Pré-requisitos

### Ferramentas necessárias:
- **ST-Link** (já incluído na placa Discovery ou externo)
- **STM32CubeProgrammer** ou **OpenOCD** (para fazer flash)
- **Compilador ARM GCC** (arm-none-eabi-gcc)
- **Make** (geralmente já instalado no Linux/Mac)
- **Terminal serial** (para testar comandos - opcional)

### Software:
- STM32CubeProgrammer: https://www.st.com/en/development-tools/stm32cubeprog.html
- Ou OpenOCD (via pacote do sistema)

## 🔨 Passo 1: Compilar a Firmware

1. **Navegue até o diretório Firmware:**
   ```bash
   cd Firmware
   ```

2. **Compile para o target F407VG_DISCO:**
   ```bash
   make MCU_TARGET=F407VG_DISCO clean
   make MCU_TARGET=F407VG_DISCO
   ```

3. **Verifique se a compilação foi bem-sucedida:**
   - O arquivo `.hex` será gerado em: `build/OpenFFBoard_F407VG_DISCO.hex`
   - O arquivo `.bin` será gerado em: `build/OpenFFBoard_F407VG_DISCO.bin`
   - O arquivo `.elf` será gerado em: `build/OpenFFBoard_F407VG_DISCO.elf`

4. **Se houver erros de compilação:**
   - Verifique se todas as dependências estão instaladas
   - Verifique se o caminho do compilador está correto

## 💾 Passo 2: Fazer Backup da Firmware Atual

**IMPORTANTE:** Sempre faça backup antes de fazer flash de uma nova firmware!

### Usando STM32CubeProgrammer:

1. **Conecte a placa via ST-Link**
2. **Abra o STM32CubeProgrammer**
3. **Conecte ao dispositivo:**
   - Clique em "Connect"
   - Selecione "ST-LINK" como interface
   - Clique em "Connect"
4. **Faça backup:**
   - Vá em "File" → "Save File As"
   - Selecione "Binary file" ou "Intel Hex"
   - Salve como `backup_F407VG_DISCO_original.bin` ou `.hex`
   - Clique em "Read" e aguarde

### Usando OpenOCD (linha de comando):

```bash
openocd -f board/stm32f4discovery.cfg -c "init" -c "halt" -c "flash read_bank 0 backup_F407VG_DISCO_original.bin 0 0x100000" -c "shutdown"
```

## 📤 Passo 3: Fazer Flash da Nova Firmware

### Opção A: Usando STM32CubeProgrammer (Recomendado)

1. **Conecte a placa via ST-Link**
2. **Abra o STM32CubeProgrammer**
3. **Conecte ao dispositivo** (se ainda não conectado)
4. **Carregue o arquivo .hex:**
   - Clique em "Browse" e selecione `build/OpenFFBoard_F407VG_DISCO.hex`
   - Ou use o arquivo `.bin` se preferir
5. **Configure as opções:**
   - ✅ Marque "Verify programming"
   - ✅ Marque "Run after programming" (opcional)
   - ⚠️ **NÃO marque "Full chip erase"** a menos que seja necessário
6. **Faça o flash:**
   - Clique em "Download"
   - Aguarde a conclusão
   - Verifique se apareceu "File download complete"

### Opção B: Usando OpenOCD (linha de comando)

```bash
cd Firmware
openocd -f board/stm32f4discovery.cfg -c "reset_config trst_only combined" -c "program build/OpenFFBoard_F407VG_DISCO.elf verify reset exit"
```

### Opção C: Usando Make (se configurado)

```bash
cd Firmware
make MCU_TARGET=F407VG_DISCO upload
```

## ✅ Passo 4: Verificação Inicial

### 4.1 Verificar se a placa inicia corretamente:

1. **Conecte a placa via USB** (se aplicável)
2. **Observe os LEDs:**
   - LED_SYS deve piscar ou acender
   - LED_PWR deve estar aceso
   - Se LED_ERR acender, há um problema

3. **Verifique se o dispositivo USB aparece:**
   - No Windows: Verifique no Gerenciador de Dispositivos
   - No Linux: `lsusb` deve mostrar o dispositivo OpenFFBoard
   - No Mac: Verifique em "Sobre este Mac" → "Relatório do Sistema" → "USB"

### 4.2 Testar comunicação serial (opcional):

1. **Conecte um cabo serial** aos pinos USART1 (PB6/PB7) ou USART3 (PB10/PB11)
2. **Configure o terminal serial:**
   - Baudrate: 460800 (USART3) ou padrão (USART1)
   - 8N1
3. **Envie comandos de teste:**
   ```
   help
   hwtype
   ```

## 🧪 Passo 5: Testar as Novas Entradas ADC

### 5.1 Teste Básico - Verificar se os pinos estão configurados:

**Via terminal serial ou configurator:**

1. **Verifique o tipo de hardware:**
   ```
   hwtype
   ```
   Deve retornar: `F407VG_DISCO`

2. **Verifique as entradas analógicas disponíveis:**
   ```
   apin info
   ```
   Deve mostrar 5 entradas analógicas (A0-A4)

### 5.2 Teste Físico - Conectar sinais de teste:

**⚠️ ATENÇÃO:** Use apenas 0-3.3V nas entradas ADC! Valores acima podem danificar o microcontrolador!

1. **Preparação:**
   - Use um potenciômetro de 10kΩ ou divisor de tensão
   - Conecte o pino central do potenciômetro à entrada ADC
   - Conecte as extremidades a GND e 3.3V

2. **Teste A0 (PB0):**
   - Conecte o potenciômetro ao pino PB0
   - Gire o potenciômetro e observe os valores mudarem

3. **Teste A1 (PB1):**
   - Conecte o potenciômetro ao pino PB1
   - Gire o potenciômetro e observe os valores mudarem

4. **Teste A2 (PC4):**
   - Conecte o potenciômetro ao pino PC4
   - Gire o potenciômetro e observe os valores mudarem

5. **Teste A3 (PC2) - NOVO:**
   - Conecte o potenciômetro ao pino PC2
   - Gire o potenciômetro e observe os valores mudarem
   - **Este é o novo pino!**

6. **Teste A4 (PC3) - NOVO:**
   - Conecte o potenciômetro ao pino PC3
   - Gire o potenciômetro e observe os valores mudarem
   - **Este é o novo pino!**

### 5.3 Teste via Comandos:

**Usando terminal serial ou configurator:**

1. **Ler valores das entradas analógicas:**
   ```
   apin get
   ```
   Deve retornar valores para 5 entradas (A0-A4)

2. **Ler valor específico:**
   ```
   apin get 3  # Para A3 (PC2)
   apin get 4  # Para A4 (PC3)
   ```

3. **Testar com potenciômetro:**
   - Conecte um potenciômetro a A3 ou A4
   - Gire o potenciômetro
   - Execute `apin get` repetidamente
   - Os valores devem mudar de ~0 (GND) a ~4095 (3.3V)

### 5.4 Teste do Analog Shifter (se aplicável):

1. **Configure o shifter analógico:**
   ```
   shifter mode 2  # G27-H mode
   shifter xchan 4  # Usar A3 (PC2) para X
   shifter ychan 5  # Usar A4 (PC3) para Y
   ```

2. **Teste os valores:**
   ```
   shifter vals
   ```
   Deve mostrar os valores de X e Y

3. **Teste a detecção de marchas:**
   ```
   shifter gear
   ```
   Deve retornar a marcha detectada (0-7)

## 🔄 Passo 6: Reverter se Necessário

Se algo der errado, você pode reverter para a firmware original:

### Usando STM32CubeProgrammer:

1. **Conecte a placa via ST-Link**
2. **Abra o STM32CubeProgrammer**
3. **Conecte ao dispositivo**
4. **Carregue o backup:**
   - Clique em "Browse" e selecione `backup_F407VG_DISCO_original.bin` ou `.hex`
5. **Faça o flash:**
   - Clique em "Download"
   - Aguarde a conclusão

### Usando OpenOCD:

```bash
openocd -f board/stm32f4discovery.cfg -c "reset_config trst_only combined" -c "program backup_F407VG_DISCO_original.elf verify reset exit"
```

## 🐛 Solução de Problemas

### Problema: A placa não inicia após o flash

**Solução:**
1. Verifique se você usou o target correto (F407VG_DISCO)
2. Tente fazer um "Full chip erase" e flash novamente
3. Verifique se os pinos BOOT0 estão corretos (deve estar em GND para boot normal)

### Problema: As novas entradas ADC não funcionam

**Solução:**
1. Verifique se os pinos PC2 e PC3 estão fisicamente acessíveis na sua placa
2. Verifique se não há curto-circuito nos pinos
3. Use um multímetro para verificar se há tensão nos pinos
4. Verifique se você está usando os comandos corretos (`apin get 3` e `apin get 4`)

### Problema: Erro de compilação

**Solução:**
1. Verifique se todas as dependências estão instaladas
2. Execute `make clean` antes de compilar novamente
3. Verifique se o caminho do compilador está correto

### Problema: Não consigo fazer flash

**Solução:**
1. Verifique se o ST-Link está conectado corretamente
2. Verifique se os drivers do ST-Link estão instalados
3. Tente usar outro método de flash (STM32CubeProgrammer vs OpenOCD)
4. Verifique se a placa está em modo DFU (se necessário)

## 📊 Checklist de Teste

- [ ] Compilação bem-sucedida
- [ ] Backup da firmware original feito
- [ ] Flash da nova firmware concluído
- [ ] Placa inicia corretamente (LEDs funcionando)
- [ ] Dispositivo USB reconhecido
- [ ] Comando `hwtype` retorna `F407VG_DISCO`
- [ ] Comando `apin info` mostra 5 entradas
- [ ] A0 (PB0) funciona corretamente
- [ ] A1 (PB1) funciona corretamente
- [ ] A2 (PC4) funciona corretamente
- [ ] A3 (PC2) funciona corretamente ⭐ NOVO
- [ ] A4 (PC3) funciona corretamente ⭐ NOVO
- [ ] Shifter analógico funciona com A3 e A4 (se aplicável)

## 📝 Notas Finais

- **PC2 e PC3 estão fisicamente acessíveis** na placa Discovery
- **PC3 está conectado ao DAC de áudio** da placa, mas isso não afeta o OpenFFBoard
- **Nenhuma outra funcionalidade será desativada** com essas mudanças
- **As entradas ADC suportam 0-3.3V** - não exceda esses valores!

## 🔗 Referências

- [Documentação do OpenFFBoard](https://github.com/Ultrawipf/OpenFFBoard/wiki)
- [Pinout F407 DISCO](https://github.com/Ultrawipf/OpenFFBoard/wiki/Pinouts-and-peripherals#f407-disco-pinout)
- [Comandos disponíveis](https://github.com/Ultrawipf/OpenFFBoard/wiki/Commands)

