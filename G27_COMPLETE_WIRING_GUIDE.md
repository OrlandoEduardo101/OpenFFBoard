# Logitech G27 Complete Wiring Guide for OpenFFBoard STM32F407VET6

# Guia Completo de Ligações do Logitech G27 para OpenFFBoard STM32F407VET6

---

## ⚠️ Important Notice / Aviso Importante

> **EN:** This guide includes a **PWM pin modification** (PE13 → PE11) that was necessary because the original pin was damaged on my board. **On a working board, this change is NOT necessary** - use the default PE13 pin.
>
> **PT:** Este guia inclui uma **modificação no pino PWM** (PE13 → PE11) que foi necessária porque o pino original foi danificado na minha placa. **Em uma placa funcionando normalmente, essa mudança NÃO é necessária** - use o pino padrão PE13.

---

## ⚡ Required: PA9 Pull-up Resistor / Resistor Pull-up no PA9

> **EN:** On the generic **STM32F407VET6 board**, a **10kΩ pull-up resistor must be soldered between PA9 and 5V** for the main firmware (F407VG) to boot correctly. Without this resistor, only the F407VG_DISCO firmware works. This is required due to VBUS sensing differences.
>
> **PT:** Na placa genérica **STM32F407VET6**, um **resistor pull-up de 10kΩ deve ser soldado entre PA9 e 5V** para o firmware principal (F407VG) iniciar corretamente. Sem esse resistor, apenas o firmware F407VG_DISCO funciona. Isso é necessário devido a diferenças na detecção VBUS.

| Connection | Description |
|------------|-------------|
| **PA9** ↔ **5V** | 10kΩ resistor (pull-up for VBUS sensing) |

---

## 📋 Table of Contents / Índice

1. [Overview / Visão Geral](#overview--visão-geral)
2. [⚡ PA9 Pull-up Resistor (Required)](#-required-pa9-pull-up-resistor--resistor-pull-up-no-pa9)
3. [Motor Connection / Conexão do Motor](#motor-connection--conexão-do-motor)
4. [Encoder Connection / Conexão do Encoder](#encoder-connection--conexão-do-encoder)
5. [Pedals Connection / Conexão dos Pedais](#pedals-connection--conexão-dos-pedais)
6. [Shifter Connection / Conexão do Câmbio](#shifter-connection--conexão-do-câmbio)
7. [Wheel Rim Buttons / Botões do Aro](#wheel-rim-buttons--botões-do-aro)
8. [Complete Pinout Summary / Resumo Completo da Pinagem](#complete-pinout-summary--resumo-completo-da-pinagem)

---

## Overview / Visão Geral

### EN - English

This guide documents all connections made to integrate a **Logitech G27 Racing Wheel** with a generic **[STM32F407VET6 board](http://pt.aliexpress.com/item/1005006882009420.html)** running OpenFFBoard firmware. The G27 consists of:

- **Wheel Base**: DC motor with optical encoder
- **Shifter**: H-pattern with analog axes + 16 SPI buttons (2x 74HC165)
- **Wheel Rim**: 8 buttons (1x 74HC165) + LEDs (1x HC595)
- **Pedals**: 3 analog axes (throttle, brake, clutch)

### PT - Português

Este guia documenta todas as conexões feitas para integrar um **Volante Logitech G27** com uma placa genérica **[STM32F407VET6](http://pt.aliexpress.com/item/1005006882009420.html)** rodando firmware OpenFFBoard. O G27 consiste em:

- **Base do Volante**: Motor DC com encoder óptico
- **Câmbio**: H-pattern com eixos analógicos + 16 botões SPI (2x 74HC165)
- **Aro do Volante**: 8 botões (1x 74HC165) + LEDs (1x HC595)
- **Pedais**: 3 eixos analógicos (acelerador, freio, embreagem)

---

## Motor Connection / Conexão do Motor

### EN - Motor Wiring

The G27 uses a **DC motor** controlled via PWM through an H-bridge driver (like BTS7960).

| Function | OpenFFBoard Pin | Wire Color (typical) | Notes |
|----------|-----------------|---------------------|-------|
| PWM | ~~PE13~~ **PE11** ⚠️ | - | **See warning below** |
| Direction | PE9 | - | Motor direction control |
| Enable | PE11 | - | Motor enable (if used) |
| Motor + | BTS7960 M+ | Red/Orange | To H-bridge output |
| Motor - | BTS7960 M- | Black/Brown | To H-bridge output |

#### ⚠️ PWM Pin Modification (MY BOARD ONLY)

**On my specific board**, the original PWM pin **PE13 was damaged/burned**. I had to remap the PWM output to **PE11** (TIM1_CH2).

**This modification is NOT necessary on a working board!** Use the default configuration:
- **Default (working board):** PWM on **PE13**
- **My board (damaged PE13):** PWM on **PE11**

#### Firmware Change for PWM Remap (if needed)

If you also have a damaged PE13 and need to use PE11:

```c
// In main.c or timer configuration
// Change TIM1_CH3 (PE13) to TIM1_CH2 (PE11)
```

### PT - Ligação do Motor

O G27 usa um **motor DC** controlado via PWM através de um driver H-bridge (como BTS7960).

| Função | Pino OpenFFBoard | Cor do Fio (típico) | Notas |
|--------|------------------|---------------------|-------|
| PWM | ~~PE13~~ **PE11** ⚠️ | - | **Veja aviso abaixo** |
| Direção | PE9 | - | Controle de direção |
| Enable | PE11 | - | Habilitação (se usado) |
| Motor + | BTS7960 M+ | Vermelho/Laranja | Saída do H-bridge |
| Motor - | BTS7960 M- | Preto/Marrom | Saída do H-bridge |

#### ⚠️ Modificação do Pino PWM (APENAS MINHA PLACA)

**Na minha placa específica**, o pino PWM original **PE13 foi danificado/queimado**. Precisei remapear a saída PWM para **PE11** (TIM1_CH2).

**Essa modificação NÃO é necessária em uma placa funcionando!** Use a configuração padrão:
- **Padrão (placa boa):** PWM no **PE13**
- **Minha placa (PE13 danificado):** PWM no **PE11**

---

## Encoder Connection / Conexão do Encoder

### EN - Encoder Wiring

The G27 uses an **optical quadrature encoder** for position feedback.

| Function | OpenFFBoard Pin | G27 Wire | Notes |
|----------|-----------------|----------|-------|
| Encoder A | PA0 | Green | Quadrature signal A |
| Encoder B | PA1 | White | Quadrature signal B |
| Index (Z) | - | - | Not used on G27 |
| VCC | 5V | Red | Encoder power |
| GND | GND | Black | Ground |

#### Configuration / Configuração
- Encoder Type: **ABN** (Quadrature)
- CPR (Counts Per Revolution): **2400** (600 PPR x4)

### PT - Ligação do Encoder

O G27 usa um **encoder óptico em quadratura** para feedback de posição.

| Função | Pino OpenFFBoard | Fio G27 | Notas |
|--------|------------------|---------|-------|
| Encoder A | PA0 | Verde | Sinal de quadratura A |
| Encoder B | PA1 | Branco | Sinal de quadratura B |
| Index (Z) | - | - | Não usado no G27 |
| VCC | 5V | Vermelho | Alimentação do encoder |
| GND | GND | Preto | Terra |

---

## Pedals Connection / Conexão dos Pedais

### EN - Pedals Wiring

The G27 pedals use **3 potentiometers** for throttle, brake, and clutch. This connection follows the **standard OpenFFBoard wiki guide** - no modifications needed.

| Function | OpenFFBoard Pin | G27 Pedal Wire | Notes |
|----------|-----------------|----------------|-------|
| Throttle | Analog 1 (PA2) | - | Accelerator pedal |
| Brake | Analog 2 (PA3) | - | Brake pedal |
| Clutch | Analog 3 (PA6) | - | Clutch pedal |
| VCC | 3.3V | Red | Potentiometer power |
| GND | GND | Black | Ground |

> **Note:** This is the **standard connection** as documented in the [OpenFFBoard Wiki - Pinouts and Peripherals](https://github.com/Ultrawipf/OpenFFBoard/wiki/Pinouts-and-peripherals). No custom modifications were required.

#### Configuration / Configuração
- Analog Source: **Local Analog**
- Number of axes: **3**
- Calibrate each axis in the OpenFFBoard Configurator

### PT - Ligação dos Pedais

Os pedais do G27 usam **3 potenciômetros** para acelerador, freio e embreagem. Esta conexão segue o **guia padrão da wiki do OpenFFBoard** - nenhuma modificação necessária.

| Função | Pino OpenFFBoard | Fio Pedal G27 | Notas |
|--------|------------------|---------------|-------|
| Acelerador | Analog 1 (PA2) | - | Pedal do acelerador |
| Freio | Analog 2 (PA3) | - | Pedal do freio |
| Embreagem | Analog 3 (PA6) | - | Pedal da embreagem |
| VCC | 3.3V | Vermelho | Alimentação dos potenciômetros |
| GND | GND | Preto | Terra |

> **Nota:** Esta é a **conexão padrão** conforme documentado na [Wiki do OpenFFBoard - Pinouts and Peripherals](https://github.com/Ultrawipf/OpenFFBoard/wiki/Pinouts-and-peripherals). Nenhuma modificação customizada foi necessária.

---

## Shifter Connection / Conexão do Câmbio

### EN - Shifter Wiring

The G27 shifter has:
- **Analog axes** (X/Y) for gear position detection
- **2x 74HC165** shift registers for 16 buttons

| Function | OpenFFBoard Pin | G27 Connector Pin | Notes |
|----------|-----------------|-------------------|-------|
| VCC | 3.3V | 1 | Power (3.3V!) |
| SCK | PB13 | 2 | SPI Clock |
| MISO | PB14 | 4 | SPI Data |
| CS/Latch | PB12 | 6 | Chip Select (SPI2_SS1) |
| X Axis | Analog In | 7 | Analog X position |
| Y Axis | Analog In | 3 | Analog Y position |
| GND | GND | 9 | Ground |

#### Configuration / Configuração
- Mode: **G27 Shifter H-pattern** (ShifterAnalog mode 2)
- CS Pin: **1** (PB12)

### PT - Ligação do Câmbio

O câmbio G27 tem:
- **Eixos analógicos** (X/Y) para detecção da marcha
- **2x 74HC165** registradores de deslocamento para 16 botões

| Função | Pino OpenFFBoard | Pino Conector G27 | Notas |
|--------|------------------|-------------------|-------|
| VCC | 3.3V | 1 | Alimentação (3.3V!) |
| SCK | PB13 | 2 | Clock SPI |
| MISO | PB14 | 4 | Dados SPI |
| CS/Latch | PB12 | 6 | Chip Select (SPI2_SS1) |
| Eixo X | Analog In | 7 | Posição analógica X |
| Eixo Y | Analog In | 3 | Posição analógica Y |
| GND | GND | 9 | Terra |

---

## Wheel Rim Buttons / Botões do Aro

### EN - Wheel Rim Wiring

The G27 wheel rim has:
- **1x 74HC165** for 8 buttons
- **1x HC595AG** for LEDs (optional, not implemented)

> **Important:** The wheel rim buttons **cannot share the same SPI bus** with the shifter because the 74HC165 lacks tri-state output. A **separate SPI port (SPI3)** must be used.

| Function | OpenFFBoard Pin | Wheel Rim Pin | Notes |
|----------|-----------------|---------------|-------|
| VCC | 3.3V | 1 | Power (3.3V!) |
| SCK | PC10 | 4 | SPI3 Clock |
| MISO | PC11 | 6 | SPI3 Data |
| CS/Latch | PA15 | 2 | SPI3_SS1 |
| GND | GND | 7 | Ground |
| MOSI | - | 3 | For LEDs (not used) |
| LED Latch | - | 5 | For LEDs (not used) |

#### Why SPI3? / Por que SPI3?

The 74HC165 shift register does **not have tri-state output**. When two 74HC165 chips share the same MISO line, they create electrical contention - both try to drive the line simultaneously. Using a separate SPI bus (SPI3) avoids this problem.

#### Configuration / Configuração
- Class: **SPI Buttons 3** (custom, uses SPI3)
- Buttons: **8**
- Mode: **74HC165** (PISOSR)
- CS Pin: **1** (PA15)

### PT - Ligação dos Botões do Aro

O aro do G27 tem:
- **1x 74HC165** para 8 botões
- **1x HC595AG** para LEDs (opcional, não implementado)

> **Importante:** Os botões do aro **não podem compartilhar o mesmo barramento SPI** com o câmbio porque o 74HC165 não tem saída tri-state. Um **porta SPI separada (SPI3)** deve ser usada.

| Função | Pino OpenFFBoard | Pino do Aro | Notas |
|--------|------------------|-------------|-------|
| VCC | 3.3V | 1 | Alimentação (3.3V!) |
| SCK | PC10 | 4 | Clock SPI3 |
| MISO | PC11 | 6 | Dados SPI3 |
| CS/Latch | PA15 | 2 | SPI3_SS1 |
| GND | GND | 7 | Terra |
| MOSI | - | 3 | Para LEDs (não usado) |
| LED Latch | - | 5 | Para LEDs (não usado) |

#### Por que SPI3?

O registrador 74HC165 **não tem saída tri-state**. Quando dois 74HC165 compartilham a mesma linha MISO, eles criam conflito elétrico - ambos tentam controlar a linha simultaneamente. Usar um barramento SPI separado (SPI3) evita esse problema.

---

## Complete Pinout Summary / Resumo Completo da Pinagem

### STM32F407VET6 Pin Assignment / Atribuição de Pinos

```
┌─────────────────────────────────────────────────────────────┐
│            STM32F407VET6 - G27 CONNECTIONS                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ⚡ REQUIRED FOR F407VG FIRMWARE TO BOOT                    │
│  └── PA9 ────────── 5V (via 10kΩ resistor)                 │
│                                                             │
│  MOTOR (via BTS7960)                                        │
│  ├── PWM ────────── PE11 ⚠️ (PE13 on working board)        │
│  ├── Direction ──── PE9                                     │
│  └── Enable ─────── PE11 (if separate)                      │
│                                                             │
│  ENCODER                                                    │
│  ├── Encoder A ──── PA0                                     │
│  ├── Encoder B ──── PA1                                     │
│  ├── VCC ────────── 5V                                      │
│  └── GND ────────── GND                                     │
│                                                             │
│  PEDALS (Standard Wiki Connection)                          │
│  ├── Throttle ───── PA2 (Analog 1)                          │
│  ├── Brake ──────── PA3 (Analog 2)                          │
│  ├── Clutch ─────── PA6 (Analog 3)                          │
│  ├── VCC ────────── 3.3V                                    │
│  └── GND ────────── GND                                     │
│                                                             │
│  SHIFTER (SPI2)                                             │
│  ├── SCK ────────── PB13                                    │
│  ├── MISO ───────── PB14                                    │
│  ├── CS ─────────── PB12 (SPI2_SS1)                        │
│  ├── X Axis ─────── Analog Input                            │
│  ├── Y Axis ─────── Analog Input                            │
│  ├── VCC ────────── 3.3V                                    │
│  └── GND ────────── GND                                     │
│                                                             │
│  WHEEL RIM BUTTONS (SPI3) - Separate bus required!          │
│  ├── SCK ────────── PC10                                    │
│  ├── MISO ───────── PC11                                    │
│  ├── CS ─────────── PA15 (SPI3_SS1)                        │
│  ├── VCC ────────── 3.3V                                    │
│  └── GND ────────── GND                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Summary Table / Tabela Resumo

| Component | Interface | Pins | Power | Notes |
|-----------|-----------|------|-------|-------|
| **VBUS Fix** | Resistor | PA9 → 5V | - | ⚡ **10kΩ required for F407VG firmware** |
| Motor | PWM | PE11 ⚠️ (PE13 default) | External PSU | H-bridge required |
| Encoder | Quadrature | PA0, PA1 | 5V | ABN type |
| Pedals | Analog | PA2, PA3, PA6 | 3.3V | Standard wiki connection |
| Shifter | SPI2 | PB13, PB14, PB12 | 3.3V | G27 mode |
| Wheel Rim | SPI3 | PC10, PC11, PA15 | 3.3V | Custom firmware required |

---

## 🔧 OpenFFBoard Configurator Settings / Configurações

### EN - Configuration Steps

1. **Motor Driver**
   - Type: PWM
   - PWM Pin: PE11 (or PE13 on working board)

2. **Encoder**
   - Type: Local ABN
   - CPR: 2400

3. **Pedals (Local Analog)**
   - Analog Source: Local Analog
   - Axes: 3 (Throttle, Brake, Clutch)
   - Calibrate in configurator
   - ✅ Standard wiki connection - no modifications

4. **Shifter (Analog Shifter)**
   - Mode: G27 Shifter H-pattern (mode 2)
   - CS Pin: 1

5. **Wheel Rim (SPI Buttons 3)**
   - Buttons: 8
   - Mode: 74HC165
   - CS: 1
   - (Requires custom firmware with SPI_Buttons_3 class)

### PT - Passos de Configuração

1. **Driver do Motor**
   - Tipo: PWM
   - Pino PWM: PE11 (ou PE13 em placa funcionando)

2. **Encoder**
   - Tipo: Local ABN
   - CPR: 2400

3. **Pedais (Local Analog)**
   - Fonte Analógica: Local Analog
   - Eixos: 3 (Acelerador, Freio, Embreagem)
   - Calibrar no configurador
   - ✅ Conexão padrão da wiki - sem modificações

4. **Câmbio (Analog Shifter)**
   - Modo: G27 Shifter H-pattern (modo 2)
   - CS Pin: 1

5. **Aro (SPI Buttons 3)**
   - Botões: 8
   - Modo: 74HC165
   - CS: 1
   - (Requer firmware customizado com classe SPI_Buttons_3)

---

## ⚠️ Warnings / Avisos

### EN - Important Warnings

1. **PA9 Resistor (STM32F407VET6)**: A **10kΩ pull-up resistor between PA9 and 5V is required** for the F407VG firmware to boot on generic STM32F407VET6 boards. Without it, only the DISCO firmware works.
2. **Voltage**: The shifter and wheel rim electronics work with **3.3V**. Do not apply 5V!
3. **PWM Pin**: The PE13→PE11 change is specific to my damaged board. **Do not apply this change to a working board.**
4. **SPI Bus Separation**: The wheel rim **must** use a separate SPI bus (SPI3) due to 74HC165 limitations.
5. **Firmware**: The wheel rim buttons require custom firmware modifications (SPI_Buttons_3 class).

### PT - Avisos Importantes

1. **Resistor PA9 (STM32F407VET6)**: Um **resistor pull-up de 10kΩ entre PA9 e 5V é obrigatório** para o firmware F407VG iniciar em placas genéricas STM32F407VET6. Sem ele, apenas o firmware DISCO funciona.
2. **Tensão**: A eletrônica do câmbio e aro funciona com **3.3V**. Não aplique 5V!
3. **Pino PWM**: A mudança PE13→PE11 é específica da minha placa danificada. **Não aplique essa mudança em uma placa funcionando.**
4. **Separação do Barramento SPI**: O aro **deve** usar um barramento SPI separado (SPI3) devido às limitações do 74HC165.
5. **Firmware**: Os botões do aro requerem modificações customizadas no firmware (classe SPI_Buttons_3).

---

## 📊 Final Result / Resultado Final

| Component / Componente | Status | Windows Axes/Buttons |
|------------------------|--------|----------------------|
| Motor / Motor | ✅ Working / Funcionando | FFB enabled |
| Encoder / Encoder | ✅ Working / Funcionando | Steering axis |
| Pedals / Pedais | ✅ Working / Funcionando | 3 axes (throttle, brake, clutch) |
| Shifter Gears / Marchas | ✅ Working / Funcionando | Buttons 1-7 (6 gears + reverse) |
| Shifter Buttons / Botões Câmbio | ✅ Working / Funcionando | Buttons 8-19 (12 buttons) |
| Wheel Rim / Aro | ✅ Working / Funcionando | Buttons 20-27 (8 buttons) |

**Total: 27 buttons + 7 gears (including reverse) + 3 pedal axes + FFB motor**

---

*Document Version: 1.0*
*Date: January 2026*
*Board: Generic STM32F407VET6*
*Hardware: Logitech G27 Racing Wheel*
