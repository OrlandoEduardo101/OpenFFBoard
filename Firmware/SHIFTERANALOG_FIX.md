# Correção Necessária no ShifterAnalog.cpp

## Problema Identificado

O `setMode()` na linha 202 está usando `getFreeCsPins()[0]` (primeiro CS livre) em vez do CS pin configurado (`cs_pin_num`). Isso causa problemas quando:
- O SPI Buttons já reservou um CS pin
- O aro está conectado (mesmo sem estar configurado)

## Correção Necessária

**Arquivo:** `Firmware/FFBoard/UserExtensions/Src/ShifterAnalog.cpp`

**Linha 202:** Substitua:
```cpp
g27ShifterButtonClient = std::make_unique<G27ShifterButtonClient>(external_spi.getFreeCsPins()[0]);
```

**Por:**
```cpp
// Use the configured CS pin (cs_pin_num is 1-indexed, getCsPin uses 0-indexed)
OutputPin* csPin = external_spi.getCsPin(cs_pin_num - 1);
if (csPin == nullptr) {
	// Fallback to first free pin if configured pin is invalid
	auto& freePins = external_spi.getFreeCsPins();
	if (!freePins.empty()) {
		csPin = &freePins[0];
	}
}
if (csPin != nullptr) {
	g27ShifterButtonClient = std::make_unique<G27ShifterButtonClient>(*csPin);
}
```

## Também Remover Verificação de isTaken()

**Linha 296:** Mude de:
```cpp
if (external_spi.isTaken() || !ready) {
```

**Para:**
```cpp
if (!ready) {
```

E atualize o comentário na linha 295 para:
```cpp
// Start a new DMA read if ready (exactly like SPI_Buttons)
// Don't check isTaken() - beginSpiTransfer() will handle semaphore blocking
```

## Problema Elétrico Possível

Se o aro estiver conectado fisicamente mas não configurado, ele pode estar interferindo no sinal MISO. Verifique:
1. Se o CS do aro (PD8) está em estado flutuante ou puxando o sinal
2. Se há pull-up/pull-down necessário no MISO
3. Se o 74HC165 do aro está ativo mesmo sem CS

## Solução Temporária

Se o problema persistir, desconecte fisicamente o aro quando não estiver em uso, ou configure o SPI Buttons para o aro mesmo que não vá usar, para garantir que o CS esteja no estado correto.
