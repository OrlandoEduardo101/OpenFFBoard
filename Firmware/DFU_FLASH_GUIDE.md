# Guia de Flash via USB (DFU) - Mac

## 🎯 Método mais fácil: Flash via USB sem ST-Link!

O OpenFFBoard suporta **DFU (Device Firmware Update)** via USB. Você não precisa de ST-Link!

## 📋 Pré-requisitos

### 1. Instale o dfu-util:
```bash
brew install dfu-util
```

### 2. Compile o firmware:
```bash
cd Firmware
make MCU_TARGET=F407VG
```

Isso gera: `build/OpenFFBoard_F407VG.bin`

## 🔄 Colocar a Placa em Modo DFU

### Método A: Via Comando Serial (Placa Funcionando)

Se sua placa já está funcionando e conectada via USB:

1. **Abra o OpenFFBoard Configurator** ou terminal serial
2. **Execute o comando:**
   ```
   dfu
   ```
3. A placa entrará em modo DFU automaticamente

### Método B: Via Hardware (Placa Não Funciona)

Se a placa não está funcionando ou é a primeira vez:

1. **Desconecte** a placa do USB
2. **Localize o pino BOOT0** na sua placa
3. **Segure o botão BOOT0** (ou conecte BOOT0 ao 3.3V)
4. **Conecte** a placa ao USB (mantendo BOOT0 pressionado)
5. **Aguarde 2 segundos** e **solte** o BOOT0
6. A placa deve entrar em modo DFU

**Nota:** Na placa F407VG normal, o BOOT0 pode ser um jumper ou botão. Verifique o esquema da sua placa.

## ✅ Verificar Modo DFU

Execute:
```bash
dfu-util --list
```

Você deve ver algo como:
```
Found DFU: [0483:df11] ver=2200, devnum=XX, cfg=1, intf=0, alt=0, name="@Internal Flash  /0x08000000/04*016Kg,01*064Kg,07*128Kg,01*128Kg,01*480Kg"
```

Se aparecer, está em modo DFU! ✅

## 📤 Fazer o Flash

### Para F407VG:
```bash
cd Firmware
dfu-util -a 0 -s 0x08000000:leave -D build/OpenFFBoard_F407VG.bin
```

### Para F407VG_DISCO:
```bash
cd Firmware
dfu-util -a 0 -s 0x08000000:leave -D build/OpenFFBoard_F407VG_DISCO.bin
```

### Parâmetros Explicados:
- `-a 0`: Interface alternativa 0 (flash interna)
- `-s 0x08000000:leave`:
  - `0x08000000` = Endereço inicial da flash do STM32F4
  - `:leave` = Sair do modo DFU após o flash (reinicia automaticamente)
- `-D`: Arquivo binário para fazer download

## ⏱️ Aguarde a Conclusão

Você verá algo como:
```
dfu-util 0.11

Copyright 2005-2009 Weston Schmidt, Harald Welte and OpenMoko Inc.
Copyright 2010-2021 Tormod Volden and Stefan Schmidt
This program is Free Software and has ABSOLUTELY NO WARRANTY
Please report bugs to http://sourceforge.net/p/dfu-util/bugs/

dfu-util: Invalid DFU suffix signature
dfu-util: A valid DFU suffix will be required in a future dfu-util release
Opening DFU capable USB device...
Device ID: 0483:df11
Device DFU version: 011a
Claiming USB DFU Interface...
Setting Alternate Setting #0 ...
Determining device status: state = dfuIDLE, status = 0
dfuIDLE, continuing
DFU mode device DFU version 011a
Device returned transfer size 2048
DfuSe interface name: "@Internal Flash  /0x08000000/04*016Kg,01*064Kg,07*128Kg,01*128Kg,01*480Kg"
Downloading to address = 0x08000000, size = XXXXX
Download	[=========================] 100%        XXXXX bytes
Download done.
dfu-util: Leaving DFU mode...
```

A placa deve **reiniciar automaticamente** após o flash!

## ✅ Verificação

1. **A placa deve reiniciar** automaticamente
2. **Conecte via USB** (se não estiver conectada)
3. **Verifique se aparece como dispositivo USB**
4. **Teste os botões do câmbio G27!** 🎮

## 🐛 Solução de Problemas

### Erro: "No DFU capable USB device available"

**Solução:**
- Verifique se a placa está realmente em modo DFU
- Execute `dfu-util --list` novamente
- Tente desconectar e reconectar
- Verifique se o cabo USB está funcionando

### Erro: "Permission denied"

**Solução no Mac:**
```bash
# Adicione sua regra USB (pode precisar de sudo)
sudo chmod 666 /dev/tty.usbmodem*
```

Ou adicione seu usuário ao grupo `dialout` (se existir).

### A placa não entra em modo DFU

**Solução:**
- Verifique se o pino BOOT0 está conectado corretamente
- Tente segurar BOOT0 por mais tempo (5 segundos)
- Verifique se há um botão RESET na placa (pode precisar resetar)
- Tente o método via comando serial se a placa ainda funciona

### Erro: "File not found"

**Solução:**
- Verifique se você está no diretório correto: `cd Firmware`
- Verifique se o arquivo foi compilado: `ls build/OpenFFBoard_F407VG.bin`
- Compile novamente se necessário: `make MCU_TARGET=F407VG`

## 📝 Notas Importantes

- **Sempre faça backup** antes de fazer flash (se possível)
- O modo DFU é **seguro** - mesmo se der erro, você pode tentar novamente
- A placa **reinicia automaticamente** após o flash bem-sucedido
- Se algo der errado, você pode sempre entrar em modo DFU novamente

## 🎉 Pronto!

Agora você pode fazer flash via USB sem precisar de ST-Link! Muito mais fácil! 🚀

