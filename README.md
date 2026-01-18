<div align="center">
    <a href="https://github.com/Ultrawipf/OpenFFBoard">
        <img width="200" height="200" src="doc/img/ffboard_logo.svg">
    </a>
	<br>
	<br>
	<div style="display: flex;">
		<a href="https://discord.gg/gHtnEcP">
            <img src="https://img.shields.io/discord/704355326291607614">
		</a>
		<a href="https://github.com/Ultrawipf/OpenFFBoard/stargazers">
            <img src="https://img.shields.io/github/stars/Ultrawipf/OpenFFBoard">
		</a>
		<a href="https://github.com/Ultrawipf/OpenFFBoard/actions/workflows/build-firmware.yml">
            <img src="https://github.com/Ultrawipf/OpenFFBoard/actions/workflows/build-firmware.yml/badge.svg?branch=master">
		</a>
	</div>
</div>

---

## ⚠️ Personal Fork Notice / Aviso de Fork Pessoal

> **EN:** This is a **personal fork** of the [original OpenFFBoard project](https://github.com/Ultrawipf/OpenFFBoard), modified to meet my specific needs for integrating a **Logitech G27** with a generic **[STM32F407VET6 board](http://pt.aliexpress.com/item/1005006882009420.html)**. This fork is **not commercial** and is intended for personal/educational use only. All credits for the original project go to [Ultrawipf](https://github.com/Ultrawipf) and the OpenFFBoard community.
>
> **PT:** Este é um **fork pessoal** do [projeto OpenFFBoard original](https://github.com/Ultrawipf/OpenFFBoard), modificado para atender às minhas necessidades específicas de integração do **Logitech G27** com uma placa genérica **[STM32F407VET6](http://pt.aliexpress.com/item/1005006882009420.html)**. Este fork **não é comercial** e destina-se apenas para uso pessoal/educacional. Todos os créditos do projeto original vão para [Ultrawipf](https://github.com/Ultrawipf) e a comunidade OpenFFBoard.

### ⚡ Important: STM32F407VET6 Board Fix / Correção Importante

> **EN:** On the generic STM32F407VET6 board, a **10kΩ pull-up resistor must be soldered between PA9 and 5V** for the main firmware (F407VG) to boot correctly. Without this resistor, only the F407VG_DISCO firmware works. This is due to VBUS sensing configuration differences between the generic board and the official OpenFFBoard hardware.
>
> **PT:** Na placa genérica STM32F407VET6, um **resistor pull-up de 10kΩ deve ser soldado entre PA9 e 5V** para o firmware principal (F407VG) iniciar corretamente. Sem esse resistor, apenas o firmware F407VG_DISCO funciona. Isso ocorre devido a diferenças na configuração de detecção VBUS entre a placa genérica e o hardware oficial do OpenFFBoard.

### 📄 Documentation of Modifications / Documentação das Modificações

| Document | Description |
|----------|-------------|
| [G27 Complete Wiring Guide](G27_COMPLETE_WIRING_GUIDE.md) | Full wiring guide for motor, encoder, pedals, shifter and wheel rim / Guia completo de ligações |
| [G27 Shifter Issue Report](G27_SHIFTER_ISSUE_REPORT.md) | Analysis and fixes for ShifterAnalog G27 mode buttons / Análise e correções dos botões do câmbio |
| [G27 Wheel Rim Buttons Report](G27_WHEEL_RIM_BUTTONS_REPORT.md) | SPI bus contention issue and SPI3 solution / Problema de contenção SPI e solução com SPI3 |

### 🔧 Main Modifications / Principais Modificações

- **ShifterAnalog.cpp/.h**: Fixed SPI timing, CS pin handling, and synchronous read for G27 shifter buttons
- **SPIButtons.cpp/.h**: Added `SPI_Buttons_3` class using SPI3 for wheel rim buttons (due to 74HC165 tri-state limitation)
- **cpp_target_config.cpp**: Added SPI3 port configuration with CS pins
- **F407VG target files**: Configured SPI3 peripheral (PC10/SCK, PC11/MISO, PA15/CS) for STM32F407VET6

---

# Open FFBoard
The Open FFBoard is an open source force feedback interface with the goal of creating a platform for highly compatible FFB simulation devices like steering wheels and joysticks.

This firmware is optimized for the Open FFBoard and mainly designed for use with DD steering wheels.
Remember this software is experimental and is intended for advanced users. Features may contain errors and can change at any time.

More documentation about this project is on the [hackaday.io page](https://hackaday.io/project/163904-open-ffboard).

The hardware designs are found under [OpenFFBoard-hardware](https://github.com/Ultrawipf/OpenFFBoard-hardware).

The GUI for configuration is found at [OpenFFBoard-configurator](https://github.com/Ultrawipf/OpenFFBoard-configurator).

These git submodules can be pulled with `git submodule init` and `git submodule update`

Updates often require matching firmware and GUI versions!
For binary releases check the [github release section](https://github.com/Ultrawipf/OpenFFBoard/releases).

## Documentation
Documentation will be updated in the [GitHub Wiki](https://github.com/Ultrawipf/OpenFFBoard/wiki).

Available commands are listed on the [Commands wiki page](https://github.com/Ultrawipf/OpenFFBoard/wiki/Commands)

Code summary and documentation of the latest stable version is available as a [Doxygen site](https://ultrawipf.github.io/OpenFFBoard/doxygen/).

For discussion and progress updates we have a [Discord server](https://discord.com/invite/gHtnEcP).


## Features
For more information, [game compatibility](https://github.com/Ultrawipf/OpenFFBoard/wiki/Games-setup#compatibility-list) and common setups check the [GitHub Wiki](https://github.com/Ultrawipf/OpenFFBoard/wiki).
### Main modes:
See [other mainclasses](https://github.com/Ultrawipf/OpenFFBoard/wiki/Commands#other-mainclasses) for full list.
* **FFB Wheel**: 	USB 1 Axis force feedback device with HID FFB support, multiple analog axis inputs (see analog sources) and digital buttons (see digital sources)
* **FFB Joystick**: USB 2 Axis force feedback device

* **EXT FFB Gamepad**: USB 2 axis gamepad device without HID FFB. Use this for simple non FFB devices or send custom FFB data via commands (See [Ext FFB mode](https://github.com/Ultrawipf/OpenFFBoard/wiki/External-FFB-mode))
* **CAN Remote Analog/Digital**: Send all supported digital and analog inputs as CAN packets to a main FFBoard (Receive using CAN Analog/Digital source)
---
* **CAN Interface**: GVRET compatible CAN interface for CAN bus debugging

### Supported motor drivers
|Name|Interface|1ch Wheel support|2ch Joystick support|Supported motors|Supported encoders|Enc forwarding (see [FFBoard supported encoders](#supported-encoders))|Dual interface encoder
|--|--|--|--|--|--|--|--|
**OpenFFBoard TMC4671**|SPI|yes✅|limited⚠️|3 phase servo (BLDC), 2ph stepper (w. encoder), (DC) | ABZ, SinCos, (Digital Hall), Analog hall | yes✅|yes✅
ODrive|CAN|yes✅|yes✅|3 phase servo | ABZ, SPI, Internal (See ODrive docs) | no❌|no❌
VESC|CAN|yes✅|yes✅|3 phase servo| ABZ | no❌|yes✅
PWM|PWM pins|yes✅|no❌|Any external driver (PWM+Dir, Centered, RC PPM, 2x PWM)| Any [FFBoard encoder](#supported-encoders) | no❌|no❌
MyActuator|CAN|yes✅|yes✅|Integrated in servo| Internal | no❌|no❌
Simplemotion|RS432 w. adapter⚠️|yes✅|no❌|3 phase servo, Stepper| ABZ, BISS-C | no❌|no❌


### Supported encoders
Encoders supported directly by FFBoard firmware and main board

Can be forwarded to TMC4671 using external encoder forwarding

|Name|Interface|Absolute|
|-|-|-|
|ABZ Quadrature|ABZ|no❌|
|BISS-C|SPI w. Adapter⚠️|yes✅|
|MagnTek (MT6825,MT6835)|SPI + ABZ|yes✅|
|SSI|SPI|yes✅|


### Extensions
The modular structure means you are free to implement your own main classes.
Take a look into the FFBoardMain and ExampleMain class files in the UserExtensions folder.
Helper functions for parsing CDC commands and accessing the flash are included.

The firmware is class based in a way that for example the whole main class can be changed at runtime and with it for example even the usb device and complete behavior of the firmware.

For FFB the motor drivers, button sources or encoders also have their own interfaces.

A unified command system supporting different interfaces is available and recommended for setting parameters at runtime. (see `CommandHandler.h` and the example mainclass)


### Copyright notice:
Some parts of this software may contain third party libraries and source code licenced under different terms.
The license applying to these files is found in the header of the file.
For all other parts in the `Firmware/FFBoard` folder the LICENSE file applies.
