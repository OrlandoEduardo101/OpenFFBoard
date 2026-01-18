# Guia de Conexão do Aro G27 ao OpenFFBoard_F407VG

## Visão Geral

O aro do G27 possui uma placa com:
- **74HC165**: Shift register de entrada (lê os botões do volante)
- **HC595AG**: Shift register de saída (controla os LEDs do volante)
- **Conector de 7 pinos**

O OpenFFBoard_F407VG já possui suporte nativo para o **74HC165** através da função **SPI Buttons** com modo "74xx165", permitindo conexão **sem modificação de código** para leitura dos botões.

**✅ Pinout Verificado**: Este guia contém o pinout confirmado através de medições físicas do conector do G27.

## Pinout SPI2 no OpenFFBoard_F407VG

| Função SPI | Pino STM32 | GPIO | Descrição |
|------------|------------|------|-----------|
| SPI2_SCK   | PB13       | Clock | Sinal de clock SPI |
| SPI2_MISO  | PB14       | MISO | Master In Slave Out (leitura do 74HC165) |
| SPI2_MOSI  | PB15       | MOSI | Master Out Slave In (escrita no HC595) |
| SPI2_NSS   | PB12       | CS1  | Chip Select 1 (pode estar usado pelo câmbio) |
| SPI2_SS2   | PD8        | CS2  | Chip Select 2 (disponível para o aro) |
| SPI2_SS3   | PD9        | CS3  | Chip Select 3 (disponível para o aro) |
| GND        | GND        | -    | Terra comum |
| 3.3V       | 3.3V       | -    | Alimentação (se necessário) |

**⚠️ IMPORTANTE**: O SPI2 tem 3 CS pins disponíveis. Se o câmbio G27 já está usando o CS 1 (PB12), você deve usar o **CS 2 (PD8)** ou **CS 3 (PD9)** para o aro.

## Conexão do Conector de 7 Pinos do G27

**✅ Pinout Confirmado por Medições:**

| Pino Conector | Função | Chip/Pino | Conecta em OpenFFBoard | Descrição |
|---------------|--------|-----------|------------------------|-----------|
| 1             | GND    | -         | GND                    | Terra comum |
| 2             | MISO   | 74HC165 pino 9 (QH) | PB14 (SPI2_MISO) | Dados dos botões (entrada) |
| 3             | MOSI   | HC595 pino 14 (DS) | PB15 (SPI2_MOSI) | Dados para LEDs (saída) |
| 4             | SCK    | 74HC165 pino 2 (CLK) + HC595 pino 11 (SH_CP) | PB13 (SPI2_SCK) | Clock SPI (compartilhado) |
| 5             | LATCH  | HC595 pino 12 (ST_CP) | - | Latch do HC595 (LEDs) - pode precisar de GPIO separado |
| 6             | LOAD   | 74HC165 pino 1 (SH/LD) | PD8 (SPI2_SS2) ou PD9 (SPI2_SS3) | Load/Latch do 74HC165 (botões) - usado como CS (use CS diferente do câmbio) |
| 7             | VCC    | -         | 3.3V ou 5V             | Alimentação (verificar tensão necessária) |

### Mapeamento Detalhado

**Para Leitura de Botões (74HC165):**
- **Pino 2** (MISO) → Lê dados seriais dos botões
- **Pino 4** (SCK) → Clock para shift register
- **Pino 6** (LOAD) → Ativa a carga paralela dos botões (funciona como CS)

**Para Controle de LEDs (HC595):**
- **Pino 3** (MOSI) → Envia dados seriais para LEDs
- **Pino 4** (SCK) → Clock compartilhado
- **Pino 5** (LATCH) → Ativa a saída paralela dos LEDs (pode precisar de GPIO separado)

### Conexão Simplificada (Apenas Botões)

Para fazer funcionar **apenas os botões** (sem LEDs), conecte:

| Pino G27 | Conecta em | Função |
|----------|------------|--------|
| 1        | GND        | Terra |
| 2        | PB14       | MISO (dados dos botões) - **compartilhado com câmbio** |
| 4        | PB13       | SCK (clock) - **compartilhado com câmbio** |
| 6        | **PD8 (SPI2_SS2)** ou **PD9 (SPI2_SS3)** | CS/LOAD (chip select) - **use CS diferente do câmbio** |
| 7        | 3.3V ou 5V | Alimentação |

**✅ SIM, você pode conectar PB13 e PB14 em ambos (câmbio e aro)!**

**Como funciona o SPI compartilhado:**
- **PB13 (SCK)** e **PB14 (MISO)** são compartilhados entre todos os dispositivos SPI2
- Cada dispositivo precisa de seu **próprio CS** (Chip Select) para não interferir
- O OpenFFBoard controla qual dispositivo está ativo através do CS
- Quando um CS está ativo (baixo), apenas aquele dispositivo responde
- Os outros dispositivos ignoram os sinais enquanto seu CS está inativo (alto)

**⚠️ IMPORTANTE**:
- Se o câmbio G27 está usando **CS 1 (PB12)**, use **CS 2 (PD8)** para o aro
- Ou use **CS 3 (PD9)** se preferir
- Configure o comando `spibtn cs` conforme o CS escolhido (2 ou 3)
- **PB13 e PB14 podem ser conectados em ambos** - é assim que o SPI funciona!

**Nota sobre Pino 5 (LATCH do HC595)**: Este pino controla quando os LEDs são atualizados. Se você quiser controlar os LEDs no futuro, pode conectar este pino a um GPIO livre e controlá-lo via software.

## Como Verificar o Pinout com Multímetro

### Materiais Necessários
- Multímetro digital (modo continuidade e voltímetro)
- Cabo de teste ou pontas de prova
- Aro G27 com placa exposta (ou acesso aos pinos do conector)

### Passo 1: Identificar GND (Terra)

1. **Desligue tudo** antes de começar
2. Coloque o multímetro em modo **continuidade** (símbolo de som/buzzer)
3. Toque uma ponta no **GND da placa do G27** (geralmente conectado ao chassi ou área de terra)
4. Com a outra ponta, teste cada pino do conector
5. O pino que **apitar** (continuidade) é o **GND**
6. **Anote**: Pino X = GND

**Dica**: O GND geralmente está conectado ao chassi metálico do volante ou à área de terra da placa.

### Passo 2: Identificar VCC (Alimentação)

1. **CUIDADO**: Não conecte o G27 à alimentação ainda se não tiver certeza da tensão
2. Coloque o multímetro em modo **voltímetro DC** (V com linha contínua)
3. Se possível, meça a tensão de alimentação da placa original do G27
4. **Ou**: Conecte temporariamente 3.3V ou 5V ao conector (com cuidado!)
5. Com o multímetro em voltímetro, teste cada pino em relação ao GND
6. O pino que mostrar **3.3V ou 5V** é o **VCC**
7. **Anote**: Pino Y = VCC (e a tensão medida)

**⚠️ ATENÇÃO**:
- Não exceda 5V na alimentação
- Verifique a polaridade antes de conectar
- Use uma fonte de alimentação regulada

### Passo 3: Identificar Pinos SPI pela Placa

Com a placa do G27 visível, você pode identificar os pinos rastreando os traços:

1. **Localize os chips**:
   - **74HC165**: Shift register de entrada (lê botões)
   - **HC595AG**: Shift register de saída (controla LEDs)

2. **Identifique os pinos dos chips**:
   - **74HC165**:
     - Pino 1 (SH/LD): Load/Latch
     - Pino 2 (CLK): Clock
     - Pino 9 (QH): Saída serial (MISO)
   - **HC595AG**:
     - Pino 11 (SH_CP): Clock
     - Pino 14 (DS): Entrada serial (MOSI)
     - Pino 12 (ST_CP): Latch

3. **Rastreie os traços** da placa:
   - Siga os traços dos pinos dos chips até o conector
   - Use o multímetro em modo continuidade para confirmar

### Passo 4: Identificar SCK (Clock)

1. O **SCK** está conectado ao pino de clock de ambos os chips (74HC165 e HC595)
2. Use continuidade para encontrar qual pino do conector vai para:
   - Pino 2 (CLK) do 74HC165
   - Pino 11 (SH_CP) do HC595
3. **Anote**: Pino Z = SCK

### Passo 5: Identificar MISO (Master In Slave Out)

1. O **MISO** vem do 74HC165 (leitura de botões)
2. Use continuidade para encontrar qual pino do conector vai para:
   - Pino 9 (QH) do 74HC165
3. **Anote**: Pino W = MISO

### Passo 6: Identificar MOSI (Master Out Slave In)

1. O **MOSI** vai para o HC595 (controle de LEDs)
2. Use continuidade para encontrar qual pino do conector vem de:
   - Pino 14 (DS) do HC595
3. **Anote**: Pino V = MOSI

### Passo 7: Identificar CS (Chip Select)

1. O **CS** pode estar conectado ao pino SH/LD (Load) do 74HC165
2. Ou pode ser um pino separado que controla ambos os chips
3. Use continuidade para verificar
4. **Anote**: Pino U = CS

### Passo 8: Verificar com Teste Funcional

Após identificar todos os pinos:

1. **Faça um diagrama** com a numeração do conector e suas funções
2. **Conecte cuidadosamente** ao OpenFFBoard conforme identificado
3. **Teste com configuração mínima**:
   - Conecte apenas GND, VCC, SCK, MISO e CS primeiro
   - Deixe MOSI desconectado inicialmente (LEDs não funcionarão)
4. **Configure o OpenFFBoard** conforme instruções abaixo
5. **Teste os botões** - se funcionarem, o pinout está correto!

### Tabela de Referência para Anotações

| Pino Conector | Função Identificada | Tensão/Continuidade | Observações |
|---------------|---------------------|---------------------|-------------|
| 1             | ?                   | ?                   |             |
| 2             | ?                   | ?                   |             |
| 3             | ?                   | ?                   |             |
| 4             | ?                   | ?                   |             |
| 5             | ?                   | ?                   |             |
| 6             | ?                   | ?                   |             |
| 7             | ?                   | ?                   |             |

### Dicas de Segurança

⚠️ **SEMPRE**:
- Desligue tudo antes de fazer medições de continuidade
- Verifique a polaridade antes de conectar alimentação
- Use fonte regulada (não conecte diretamente a bateria ou fonte não regulada)
- Comece com tensão baixa (3.3V) e aumente se necessário
- Não force conexões - se não encaixar, verifique o pinout

✅ **Boa Prática**:
- Tire fotos da placa antes de começar
- Anote tudo que descobrir
- Faça um diagrama claro
- Teste cada conexão individualmente antes de conectar tudo

## Configuração via Comandos (Sem Modificar Código)

### 1. Adicionar SPI Buttons como Fonte de Botões

Conecte-se ao OpenFFBoard via USB ou UART e execute:

```
addbtn 1
```

Isso adiciona "SPI Buttons 1" como fonte de botões.

### 2. Configurar Modo 74HC165

```
spibtn mode 1
```

Modo 1 = "74xx165" (Parallel In Serial Out Shift Register)

### 3. Configurar Número de Botões

O G27 wheel geralmente tem 11 botões:
- 4 botões direcionais (cima, baixo, esquerda, direita)
- 2 botões laterais (esquerda, direita)
- 2 botões traseiros (esquerda, direita)
- 2 botões centrais (X, O)
- 1 botão central (menu)

```
spibtn btnnum 11
```

### 4. Configurar Pino CS

**⚠️ IMPORTANTE**: Se o câmbio G27 já está usando o CS 1, você deve usar o CS 2 ou CS 3:

**Opção A - Usar CS 2 (PD8)**:
```
spibtn cs 2
```
Conecte o pino 6 do G27 em **PD8 (SPI2_SS2)**

**Opção B - Usar CS 3 (PD9)**:
```
spibtn cs 3
```
Conecte o pino 6 do G27 em **PD9 (SPI2_SS3)**

**Nota**: O CS 1 (PB12) provavelmente está sendo usado pelo câmbio G27, então use CS 2 ou CS 3 para o aro.

### 5. Configurar Velocidade SPI (se necessário)

Se houver problemas de comunicação, tente velocidades menores:

```
spibtn spispeed 1  # Medium
spibtn spispeed 2  # Slow
```

### 6. Verificar Configuração

```
spibtn mode
spibtn btnnum
spibtn cs
spibtn spispeed
```

## Gerenciando Câmbio e Aro Simultaneamente

O OpenFFBoard suporta múltiplos dispositivos SPI no mesmo barramento, usando CS diferentes:

### Configuração do Câmbio G27 (Shifter)

O câmbio G27 geralmente usa:
- **SPI Buttons** ou **Shifter Analog** (modo G27)
- **CS 1 (PB12)** - verifique com `shifter cspin` ou `spibtn cs` (se usar SPI Buttons)

### Configuração do Aro G27 (Wheel)

O aro G27 deve usar:
- **SPI Buttons** (modo 74HC165)
- **CS 2 (PD8)** ou **CS 3 (PD9)** - diferente do câmbio

### Verificar Qual CS Está Sendo Usado

Para verificar qual CS o câmbio está usando:

```
# Se o câmbio usa Shifter Analog
shifter cspin

# Se o câmbio usa SPI Buttons
spibtn cs
```

### Configuração Completa em Sequência

**Passo 1 - Configurar o Aro (SPI Buttons):**
```
# Adicionar SPI Buttons (se ainda não adicionou)
addbtn 1

# Configurar para 74HC165
spibtn mode 1
spibtn btnnum 11
spibtn cs 2  # Use CS 2 (PD8) se o câmbio está usando CS 1, ou CS 3 (PD9)
spibtn spispeed 1
```

**Passo 2 - Verificar Configuração:**
```
# Verificar configuração do aro
spibtn mode
spibtn btnnum
spibtn cs
spibtn spispeed

# Verificar configuração do câmbio (se aplicável)
shifter cspin
```

**Passo 3 - Conexões Físicas:**

| Dispositivo | Pino CS | GPIO | Observação |
|-------------|---------|------|------------|
| Câmbio G27  | CS 1    | PB12 | Verifique qual CS está configurado |
| Aro G27     | CS 2    | PD8  | Use CS diferente do câmbio |
| Aro G27     | CS 3    | PD9  | Alternativa ao CS 2 |

**Importante**: Ambos compartilham o mesmo SPI2 (SCK, MISO, MOSI), mas usam CS diferentes para não interferirem.

### Diagrama de Conexões Compartilhadas

```
                    ┌─────────────────┐
                    │  OpenFFBoard   │
                    │    F407VG       │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        │                    │                    │
    PB13 (SCK) ──────────────┼─────────────── (compartilhado)
        │                    │                    │
    PB14 (MISO) ─────────────┼─────────────── (compartilhado)
        │                    │                    │
    PB15 (MOSI) ─────────────┼─────────────── (compartilhado)
        │                    │                    │
        │                    │                    │
    PB12 (CS1) ──────────────┘                    │
        │                                         │
    ┌───┴───┐                                    │
    │Câmbio │                                    │
    │  G27  │                                    │
    └───────┘                                    │
                                                 │
    PD8 (CS2) ───────────────────────────────────┘
        │
    ┌───┴───┐
    │ Aro  │
    │ G27  │
    └──────┘
```

**Resumo**:
- ✅ **PB13 (SCK)**: Conecte em ambos (câmbio e aro)
- ✅ **PB14 (MISO)**: Conecte em ambos (câmbio e aro)
- ✅ **PB15 (MOSI)**: Conecte em ambos (câmbio e aro) - se necessário
- ⚠️ **CS**: Cada dispositivo precisa de seu próprio CS (PB12 para câmbio, PD8 ou PD9 para aro)

## Controle de LEDs (HC595)

**Nota**: O controle dos LEDs via HC595 requer código adicional, pois o OpenFFBoard não possui uma função dedicada para isso. **Os botões funcionarão normalmente mesmo sem os LEDs.**

### Como Funciona o HC595

O HC595 precisa de:
1. **Dados seriais** via MOSI (Pino 3 → PB15)
2. **Clock** compartilhado via SCK (Pino 4 → PB13)
3. **Latch/Strobe** via pino separado (Pino 5 → precisa de GPIO)

### Conexão para LEDs (Opcional)

Se quiser controlar os LEDs no futuro:

| Pino G27 | Função | Conecta em | Observação |
|----------|--------|-----------|------------|
| 3        | MOSI   | PB15 (SPI2_MOSI) | Já conectado para SPI |
| 4        | SCK    | PB13 (SPI2_SCK) | Já conectado para SPI |
| 5        | LATCH  | PD8 (SPI2_SS2) ou PD9 (SPI2_SS3) | GPIO separado para controlar latch |

**Implementação Futura**:
- O pino LATCH (ST_CP do HC595) precisa ser controlado manualmente
- Após enviar dados via SPI, você precisa:
  1. Enviar dados seriais via SPI2_MOSI
  2. Pulsar o pino LATCH (alto→baixo→alto) para atualizar as saídas
- Isso requer código customizado ou uso de um GPIO como saída

**Por enquanto**: Deixe o pino 5 desconectado. Os botões funcionarão perfeitamente sem os LEDs.

## Verificação de Funcionamento

1. Conecte o aro G27 conforme o diagrama acima
2. Configure os comandos conforme descrito
3. Teste os botões no jogo ou via comando de teste
4. Verifique se os botões são reconhecidos corretamente

## ⚠️ Segurança e Proteção Contra Danos

### Riscos de Conexão Incorreta

**SIM, há risco de danificar a placa do aro se você errar os fios!** Aqui estão os principais riscos:

#### 🔴 **MUITO PERIGOSO - Pode Queimar a Placa:**

1. **Inverter GND e VCC (Pinos 1 e 7)**
   - ⚠️ **RISCO ALTO**: Pode queimar os chips 74HC165 e HC595 instantaneamente
   - **Sintoma**: Placa para de funcionar, cheiro de queimado, chips superaquecidos
   - **Prevenção**:
     - ✅ Verifique 3 vezes antes de conectar
     - ✅ Use cores diferentes de fio (preto para GND, vermelho para VCC)
     - ✅ Meça com multímetro antes de conectar

2. **Aplicar Tensão Errada (5V em chip 3.3V ou vice-versa)**
   - ⚠️ **RISCO MÉDIO-ALTO**: Os chips podem suportar 5V (74HC165/HC595 são 5V tolerant), mas verifique
   - **Sintoma**: Funcionamento instável, superaquecimento, falhas intermitentes
   - **Prevenção**:
     - ✅ Verifique a tensão necessária (geralmente 5V para G27)
     - ✅ Use fonte regulada
     - ✅ Meça a tensão antes de conectar

3. **Conectar VCC em Pino de Sinal (MISO, MOSI, SCK, CS)**
   - ⚠️ **RISCO ALTO**: Pode danificar o chip e o OpenFFBoard
   - **Sintoma**: Chip queima, OpenFFBoard pode ser danificado
   - **Prevenção**:
     - ✅ Verifique cada conexão individualmente
     - ✅ Use diagrama de conexão
     - ✅ Não conecte tudo de uma vez

#### 🟡 **MODERADO - Pode Causar Problemas:**

4. **Inverter MISO e MOSI**
   - ⚠️ **RISCO BAIXO**: Geralmente não danifica, só não funciona
   - **Sintoma**: Botões não funcionam, comunicação SPI falha
   - **Prevenção**: Verifique o pinout antes de conectar

5. **Conectar SCK Errado**
   - ⚠️ **RISCO BAIXO**: Geralmente não danifica
   - **Sintoma**: Comunicação não funciona
   - **Prevenção**: Verifique o pinout

6. **Conectar CS Errado**
   - ⚠️ **RISCO BAIXO**: Não danifica, mas pode causar conflitos
   - **Sintoma**: Dispositivos não funcionam corretamente
   - **Prevenção**: Use CS diferentes para câmbio e aro

#### 🟢 **BAIXO RISCO:**

7. **Inverter Ordem dos Pinos de Sinal**
   - ⚠️ **RISCO MUITO BAIXO**: Geralmente só não funciona
   - **Sintoma**: Comunicação não funciona
   - **Prevenção**: Siga o diagrama

### Checklist de Segurança Antes de Conectar

Antes de conectar qualquer coisa, faça esta verificação:

- [ ] **Desligue tudo** antes de fazer conexões
- [ ] **Identifique cada pino** do conector G27 com multímetro
- [ ] **Anote o pinout** em um papel ou arquivo
- [ ] **Verifique GND**: Confirme que o pino 1 é realmente GND
- [ ] **Verifique VCC**: Confirme a tensão necessária (3.3V ou 5V)
- [ ] **Meça continuidade**: Confirme cada conexão antes de energizar
- [ ] **Use cores diferentes**:
  - Preto/Vermelho para GND/VCC
  - Cores diferentes para cada sinal
- [ ] **Conecte GND primeiro**: Sempre conecte o terra primeiro
- [ ] **Conecte VCC por último**: Só conecte a alimentação quando tudo estiver verificado
- [ ] **Teste sem alimentação primeiro**: Conecte todos os sinais, mas deixe VCC desconectado
- [ ] **Use fonte regulada**: Não use fonte não regulada ou bateria diretamente

### Procedimento Seguro de Conexão

**Passo a Passo Seguro:**

1. **Desligue tudo** (OpenFFBoard e fonte de alimentação)
2. **Identifique pinos** do conector G27 com multímetro
3. **Conecte GND primeiro** (pino 1 → GND do OpenFFBoard)
4. **Conecte sinais** (MISO, SCK, CS) - sem alimentação ainda
5. **Verifique todas as conexões** visualmente e com multímetro
6. **Conecte VCC por último** (pino 7 → 3.3V ou 5V)
7. **Ligue o OpenFFBoard**
8. **Teste a comunicação** antes de usar

### O Que Fazer Se Algo Der Errado

**Se você notar algo estranho (cheiro, fumaça, superaquecimento):**

1. ⚡ **DESLIGUE IMEDIATAMENTE** - Corte a alimentação
2. 🔍 **Não toque** - Deixe esfriar
3. 🔬 **Inspecione visualmente** - Procure por chips queimados, componentes danificados
4. 📏 **Meça com multímetro** - Verifique continuidade e tensões
5. 🔧 **Teste isoladamente** - Teste cada componente separadamente se possível

**Se a placa não funcionar após conexão:**

1. Verifique se não há curto-circuito (GND-VCC)
2. Meça tensões em todos os pinos
3. Verifique se os chips estão recebendo alimentação
4. Teste comunicação SPI isoladamente
5. Verifique se não há componentes queimados

### Proteções Recomendadas

**Para Minimizar Riscos:**

1. **Use fonte regulada** com proteção contra curto-circuito
2. **Adicione fusível** na linha VCC (500mA-1A)
3. **Use conectores** em vez de soldar diretamente (facilita correção)
4. **Teste com multímetro** antes de cada conexão
5. **Tenha um aro G27 reserva** se possível (para testes)

### Tensão de Alimentação

**Verificação Importante:**

- Os chips 74HC165 e HC595 geralmente suportam **3.3V a 5V**
- O G27 original usa **5V**
- O OpenFFBoard fornece **3.3V** nos pinos de alimentação
- **Recomendação**:
  - Teste primeiro com **3.3V** (mais seguro para o OpenFFBoard)
  - Se não funcionar, tente **5V** (use fonte externa regulada)
  - **NUNCA** exceda 5V

## Troubleshooting

### Botões não funcionam

1. **Verifique as conexões**: Use multímetro para confirmar continuidade
2. **Verifique tensão**: O G27 pode precisar de 5V em vez de 3.3V
3. **Inverta polaridade**: Tente `spibtn btnpol 1` para inverter
4. **Ajuste velocidade SPI**: Use `spibtn spispeed 2` (mais lento)
5. **Verifique CS**: Confirme que o CS está conectado corretamente

### Comunicação SPI instável

1. Reduza a velocidade SPI: `spibtn spispeed 2`
2. Verifique comprimento dos cabos (mantenha curto)
3. Adicione pull-ups/pull-downs se necessário
4. Verifique terra comum (GND)

### LEDs não funcionam

Como mencionado, o controle de LEDs requer código adicional. Os botões devem funcionar independentemente dos LEDs.

## Referências

- **SPI Buttons**: Suporta modo "74xx165" nativamente
- **SPI2**: Configurado em `cpp_target_config.cpp` como `external_spi`
- **Pinos**: Definidos em `main.h` e `OpenFFBoard_F407VG.ioc`

## Notas Finais

✅ **Leitura de botões**: Funciona sem modificação de código
⚠️ **Controle de LEDs**: Pode requerer código adicional
✅ **SPI2**: Já configurado e pronto para uso
✅ **Modo 74HC165**: Suportado nativamente pelo firmware

