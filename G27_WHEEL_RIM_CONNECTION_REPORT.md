# G27 Steering Wheel Rim + Shifter Connection Report

## Executive Summary

This document describes the process of connecting a **Logitech G27 steering wheel rim** (buttons only) to the **OpenFFBoard F407VG** alongside the **G27 shifter**, and the firmware modifications required to make both work simultaneously.

---

## 🎯 Objective

Connect both G27 components to OpenFFBoard:
- **G27 Shifter**: 6 gears + reverse + 16 buttons (uses 2x 74HC165)
- **G27 Wheel Rim**: 8 buttons (uses 1x 74HC165)

---

## 🔴 Original Problem

### Initial Attempt: Shared SPI2 Bus

The first approach was to use the existing SPI2 bus (`external_spi`) for both devices:

| Component | Function | Pin |
|-----------|----------|-----|
| Shared | SCK | PB13 |
| Shared | MISO | PB14 |
| Shifter | CS | PB12 (SPI2_SS1) |
| Wheel Rim | CS | PD8 (SPI2_SS2) |

**Result**: ❌ **Failed** - Only one device could work at a time.

### Root Cause Analysis

#### 1. 74HC165 Lacks Tri-State Output

The 74HC165 shift register **does not have a tri-state (high-impedance) output**. This is a critical hardware limitation:

```
┌─────────────────────────────────────────────────────────────┐
│                    SPI BUS CONTENTION                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   74HC165 #1 (Shifter)     74HC165 #2 (Wheel)              │
│        ┌───┐                    ┌───┐                       │
│   Q7 ──┤   ├──┐            Q7 ──┤   ├──┐                   │
│        └───┘  │                 └───┘  │                   │
│               │                        │                   │
│               └────────┬───────────────┘                   │
│                        │                                   │
│                        ▼                                   │
│                   MISO (PB14)  ← CONFLICT!                 │
│                                                             │
│   Both chips try to drive MISO simultaneously,             │
│   even when their CS is not asserted.                      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

Unlike SPI devices with tri-state outputs (which go high-impedance when CS is inactive), the 74HC165 **always drives its output pin**. When two 74HC165 chips share the same MISO line, they create electrical contention.

#### 2. DMA Timing Issues on SPI3

When attempting to use SPI3 for the wheel rim, the DMA-based `readButtons()` function did not work correctly. The asynchronous nature of DMA transfers conflicted with the 74HC165's requirement for precise CS (latch) timing.

#### 3. Virtual Function Call in Base Constructor (C++ Issue)

The `restoreFlash()` function was called in the `SPI_Buttons` base class constructor:

```cpp
// Original problematic code
SPI_Buttons::SPI_Buttons(...) {
    // ...
    restoreFlash();  // ❌ Virtual function call in constructor
}
```

In C++, when a virtual function is called from a base class constructor, it **does not dispatch to the derived class override**. This prevented `SPI_Buttons_3::restoreFlash()` from being called, so the hardcoded 8-button configuration was never applied.

---

## ✅ Solution Implemented

### Hardware Configuration

Use **separate SPI buses** for each device to avoid MISO contention:

| Component | Function | Pin | SPI Bus |
|-----------|----------|-----|---------|
| **Shifter** | SCK | PB13 | SPI2 |
| **Shifter** | MISO | PB14 | SPI2 |
| **Shifter** | CS | PB12 | SPI2_SS1 |
| **Wheel Rim** | SCK | PC10 | SPI3 |
| **Wheel Rim** | MISO | PC11 | SPI3 |
| **Wheel Rim** | CS | PA15 | SPI3_SS1 |
| **Wheel Rim** | VCC | 3.3V | - |
| **Wheel Rim** | GND | GND | - |

```
┌─────────────────────────────────────────────────────────────┐
│                 SEPARATE SPI BUSES                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   SPI2 Bus (Shifter)              SPI3 Bus (Wheel Rim)     │
│   ┌─────────────┐                 ┌─────────────┐          │
│   │  74HC165    │                 │  74HC165    │          │
│   │  (x2)       │                 │  (x1)       │          │
│   └──────┬──────┘                 └──────┬──────┘          │
│          │                               │                  │
│   SCK ───┼─── PB13              SCK ────┼─── PC10          │
│   MISO ──┼─── PB14              MISO ───┼─── PC11          │
│   CS ────┼─── PB12              CS ─────┼─── PA15          │
│          │                               │                  │
│          ▼                               ▼                  │
│   ShifterAnalog                  SPI_Buttons_3             │
│   (G27 Mode)                     (8 buttons)               │
│                                                             │
│   ✅ No contention - separate MISO lines                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Firmware Modifications

#### 1. Created `SPI_Buttons_3` Class

**File**: `Firmware/FFBoard/UserExtensions/Inc/SPIButtons.h`

```cpp
class SPI_Buttons_3 : public SPI_Buttons {
public:
    SPI_Buttons_3();

    const ClassIdentifier getInfo() override;
    static ClassIdentifier info;
    static bool isCreatable();

    void restoreFlash() override;
    uint8_t readButtons(uint64_t* buf) override;  // Custom synchronous read
    std::string getHelpstring() override {return "SPI 3 Button (SPI3)";}
};
```

#### 2. Custom `readButtons()` for SPI3

**File**: `Firmware/FFBoard/UserExtensions/Src/SPIButtons.cpp`

The 74HC165 requires a specific sequence to read data:
1. **Pulse CS LOW** → Latches parallel inputs into shift register
2. **CS HIGH** → Enables serial shift mode
3. **Clock pulses** → Shifts data out on MISO

```cpp
uint8_t SPI_Buttons_3::readButtons(uint64_t* buf){
    // Return last buffer immediately (non-blocking)
    memcpy(buf, this->spi_buf, std::min<uint8_t>(this->bytes, 8));
    process(buf);

    if(spiPort.isTaken())
        return this->conf.numButtons;

    SPI_HandleTypeDef* hspi = spiPort.getPortHandle();

    // Get CS pin (PA15)
    OutputPin* cs_pin = spiPort.getCsPin(this->conf.cs_num > 0 ? this->conf.cs_num - 1 : 0);

    if(cs_pin != nullptr) {
        // Pulse CS to latch parallel data into 74HC165
        cs_pin->write(false);  // CS LOW - load parallel data
        for(volatile int i = 0; i < 10; i++) {}  // Small delay
        cs_pin->write(true);   // CS HIGH - enable shift
    }

    // Synchronous SPI read (not DMA)
    HAL_SPI_Receive(hspi, spi_buf, bytes, 10);

    return this->conf.numButtons;
}
```

**Key differences from base class**:
- Uses **synchronous** `HAL_SPI_Receive()` instead of DMA
- **Manually pulses CS** before reading
- Returns `conf.numButtons` consistently

#### 3. Fixed Virtual Function Initialization

**File**: `Firmware/FFBoard/UserExtensions/Src/SPIButtons.cpp`

```cpp
// Constructor explicitly calls derived class restoreFlash
SPI_Buttons_3::SPI_Buttons_3()
    : SPI_Buttons{ADR_SPI_BTN_3_CONF, ADR_SPI_BTN_3_CONF_2, &ext3_spi, 2} {
    SPI_Buttons_3::restoreFlash();  // Explicit call, not virtual dispatch
}

void SPI_Buttons_3::restoreFlash(){
    ButtonSourceConfig config;
    config.numButtons = 8;              // 8 buttons on wheel rim
    config.mode = SPI_BtnMode::PISOSR;  // 74HC165 mode
    config.cs_num = 1;                  // CS pin 1 (PA15)
    config.spi_speed = 2;               // Slow speed
    config.invert = false;
    config.cutRight = false;

    setConfig(config);
    this->conf.cs_num = 1;
    this->btnnum = 8;
}
```

#### 4. Made Members Accessible to Derived Class

**File**: `Firmware/FFBoard/UserExtensions/Inc/SPIButtons.h`

```cpp
protected:
    void process(uint64_t* buf);    // Moved from private
    uint8_t bytes = 4;              // Moved from private
    uint8_t spi_buf[4] = {0};       // Moved from private
    ButtonSourceConfig conf;
```

#### 5. SPI3 Hardware Configuration

**File**: `Firmware/Targets/F407VG/Core/Src/main.c`

```c
static void MX_SPI3_Init(void)
{
    hspi3.Instance = SPI3;
    hspi3.Init.Mode = SPI_MODE_MASTER;
    hspi3.Init.Direction = SPI_DIRECTION_2LINES;
    hspi3.Init.DataSize = SPI_DATASIZE_8BIT;
    hspi3.Init.CLKPolarity = SPI_POLARITY_LOW;
    hspi3.Init.CLKPhase = SPI_PHASE_1EDGE;
    hspi3.Init.NSS = SPI_NSS_SOFT;
    hspi3.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_32;
    hspi3.Init.FirstBit = SPI_FIRSTBIT_MSB;
    // ...
}
```

#### 6. SPI3 CS Pins Definition

**File**: `Firmware/Targets/F407VG/Core/Src/cpp_target_config.cpp`

```cpp
#ifdef EXT3_SPI_PORT
static const std::vector<OutputPin> ext3_spi_cspins{
    OutputPin(*SPI3_SS1_GPIO_Port, SPI3_SS1_Pin),  // PA15 - CS1
    OutputPin(*SPI3_SS2_GPIO_Port, SPI3_SS2_Pin),  // PD2  - CS2
    OutputPin(*SPI3_SS3_GPIO_Port, SPI3_SS3_Pin)   // PD3  - CS3
};
extern SPI_HandleTypeDef EXT3_SPI_PORT;
SPIPort ext3_spi{hspi3, ext3_spi_cspins, 42000000, true};
#endif
```

---

## 📋 Configuration Steps

### OpenFFBoard Configurator Settings

1. **Shifter (ShifterAnalog)**:
   - Mode: G27 Shifter
   - CS Pin: 1 (PB12)
   - ✅ All 6 gears + reverse + 16 buttons working

2. **Wheel Rim (SPI Buttons 3)**:
   - Automatically configured (hardcoded in firmware)
   - 8 buttons mapped to buttons 20-27 in Windows

---

## 📊 Final Result

| Component | Status | Notes |
|-----------|--------|-------|
| G27 Shifter Gears | ✅ Working | 6 gears + reverse |
| G27 Shifter Buttons | ✅ Working | 16 buttons |
| G27 Wheel Rim Buttons | ✅ Working | 8 buttons (20-27) |

---

## 🔑 Key Learnings

### 1. 74HC165 Cannot Share MISO Lines
The 74HC165 shift register lacks tri-state output capability. Multiple 74HC165 devices **must use separate SPI buses** or external tri-state buffer ICs (like 74HC125).

### 2. DMA vs Synchronous SPI for Shift Registers
DMA-based SPI transfers may have timing issues with shift registers that require precise CS/latch timing. Synchronous reads with manual CS control provide more reliable operation.

### 3. C++ Virtual Functions in Constructors
Virtual functions called from base class constructors do not dispatch to derived class overrides. Derived classes must explicitly call their own initialization methods.

### 4. SPI Configuration Must Match Device Requirements
The 74HC165 requires:
- `CLKPolarity = SPI_POLARITY_LOW`
- `CLKPhase = SPI_PHASE_1EDGE`
- `FirstBit = SPI_FIRSTBIT_MSB`

---

## 📁 Modified Files Summary

| File | Changes |
|------|---------|
| `SPIButtons.h` | Added `SPI_Buttons_3` class, moved members to protected |
| `SPIButtons.cpp` | Implemented `SPI_Buttons_3` with custom `readButtons()` |
| `cpp_target_config.cpp` | Defined SPI3 CS pins |
| `main.c` | Configured SPI3 hardware parameters |
| `stm32f4xx_hal_msp.c` | Adjusted SPI3 DMA/IRQ priorities |
| `OpenFFBoard_F407VG.ioc` | Updated SPI3 CubeMX configuration |

---

## 💡 Recommendations for OpenFFBoard

1. **Document 74HC165 limitations** in the wiki regarding shared SPI buses
2. **Consider adding tri-state buffer support** for users who need multiple 74HC165 devices on one bus
3. **Expose SPI3 as a user-selectable option** in the configurator for button sources
4. **Add a "SPI Buttons 3" dialog** in the configurator (currently shows "error. no dialog for spi buttons 3")

---

## 🙏 Acknowledgments

This solution was developed through extensive debugging and firmware modification. Special thanks to the OpenFFBoard community and the original firmware developers.

---

*Report generated: January 2026*
*OpenFFBoard Target: F407VG*
*Firmware: Custom modified build*
