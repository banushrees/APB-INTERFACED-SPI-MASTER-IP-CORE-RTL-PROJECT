# APB-based SPI Master IP Core using RTL Project
The project involves the design of an APB-based SPI Master Core using RTL.The SPI Master Core is
controlled and configured through an APB interface and communicates with an external SPI slave
device through the SPI interface.
The design consists of an APB slave interface, APB state machine, SPI state machine, baud rate
generator, shift register, and slave-select control logic. The APB interface is used to access the SPI
control, baud-rate, status, and data registers. The configured SPI parameters are used to generate the
SPI clock and control serial data transmission and reception. The SPI Master Core supports 8-bit data
transfer, programmable baud rate, clock polarity, clock phase, MSB-first/LSB-first data transfer, Slave
Select control, interrupt generation, and mode-fault detection.
2. DESIGN OBJECTIVES
The main objectives of the APB-based SPI Master Core design are:
1. To implement an SPI Master Core controlled through an APB interface.
2. To provide APB read and write access to the SPI control, baud-rate, status, and data registers.
3. To generate the SPI serial clock based on the programmed baud-rate configuration.
4. To support 8-bit serial data transmission and reception.
5. To support both MSB-first and LSB-first data transfer.
6. To support programmable SPI clock polarity (CPOL) and clock phase (CPHA).
7. To control the SPI Slave Select (SS) signal during data transfer.
8. To provide SPI status information through the Status Register.
9. To provide SPI interrupt request functionality based on the configured interrupt conditions.
10. To provide mode-fault detection during Master mode operation.ASTER-IP-CORE-RTL-PROJECT

RTL ARCHITECTURE
The APB-based SPI Master Core is divided into the following major RTL blocks:

<img width="632" height="175" alt="image" src="https://github.com/user-attachments/assets/06155694-ec43-44dd-818a-067b14656eb4" />

## APB FSM
<img width="567" height="87" alt="image" src="https://github.com/user-attachments/assets/187acef0-3e89-4246-b6e1-827e6780efd7" />

The APB FSM controls the APB transaction states. It contains three states:
• IDLE: No APB transfer is active.
• SETUP: PSEL is HIGH and PENABLE is LOW.
• ENABLE/ACCESS: PSEL and PENABLE are HIGH and the APB transfer is performed.
The FSM generates the internal apb_state signal, which is used by the APB Slave Interface to determine
read and write operations.
<img width="295" height="375" alt="image" src="https://github.com/user-attachments/assets/37299312-4384-4838-964a-ea1fec6712b4" />

## APB SLAVE INTERFACE
The APB Slave Interface provides the connection between the APB bus and the internal SPI control logic.
It receives APB control signals and performs register read and write operations based on the APB
address and control information.The interface stores and provides the SPI configuration parameters,
generates status information, provides APB read data and response signals, and generates the SPI
interrupt request.
<img width="447" height="302" alt="image" src="https://github.com/user-attachments/assets/7d759191-7988-475d-86c3-591f08afaea8" />

APB SLAVE INTERFACE INPUTS

<img width="700" height="135" alt="image" src="https://github.com/user-attachments/assets/247bb197-3c43-441a-ae69-8403c3688527" />
<img width="697" height="220" alt="image" src="https://github.com/user-attachments/assets/5775d26e-0ca8-4c47-919e-c19905532872" />

<img width="826" height="431" alt="image" src="https://github.com/user-attachments/assets/b090b3c6-f7f2-42a5-9618-15d0d6766788" />

## Register Map

<img width="835" height="267" alt="image" src="https://github.com/user-attachments/assets/465ad0d4-05fc-423d-9808-d7c2319f2424" />

## SPI CONTROL REGISTER 1
<img width="836" height="341" alt="image" src="https://github.com/user-attachments/assets/7de3ee90-36f7-4125-9534-0dc8ab163eb6" />

## SPI CONTROL REGISTER 2
<img width="830" height="402" alt="image" src="https://github.com/user-attachments/assets/965dac03-45f8-410d-b335-40d11c8224a1" />

## SPI BAUD RATE REGISTER
The RTL extracts:
SPPR = SPI_BR[6:4]
SPR = SPI_BR[2:0]
These values are supplied to the Baud Generator.
The baud-rate divisor is calculated as:
Baud Rate Divisor = (SPPR + 1) × 2^(SPR + 1)

<img width="827" height="207" alt="image" src="https://github.com/user-attachments/assets/6a956f49-7e11-4b3f-bff6-f14e212cefb6" />

## SPI STATUS REGISTER
The RTL generates the status value as:
SPI_SR = {SPIF, 1'b0, SPTEF, MODF, 4'b0000}
After reset, the Status Register read value is:
8'b0010_0000
Mode Fault Detection
The MODF signal is generated using:
MODF = (~SS) && MSTR && MODFEN && (~SSOE)
Thus, the mode-fault condition occurs when Master mode is enabled, mode-fault detection is enabled, SS is LOW,
and SSOE is disabled.

<img width="706" height="77" alt="image" src="https://github.com/user-attachments/assets/c2eaf6d6-0709-4378-9494-dde994f6259c" />
<img width="825" height="137" alt="image" src="https://github.com/user-attachments/assets/8d67963e-d2f3-47f2-bf50-07d6008dfde9" />

## SPI DATA REGISTER
SPI_DR is used to store SPI transmit data and provide the SPI data-register interface.

Write Operation
When an APB write is performed to address 3'b101, the APB write data is stored in SPI_DR.
The stored data is provided to the Shift Register through the mosi_data signal.
The send_data signal is generated to initiate the SPI transfer.
Read Operation
During an APB read of address 3'b101, the contents of SPI_DR are selected as the APB read data.
<img width="702" height="111" alt="image" src="https://github.com/user-attachments/assets/0066d5bb-1e77-4e89-8776-c15a65611660" />

# SPI FSM
The SPI FSM controls the operating state of the SPI core based on the SPE and SPISWAI control
signals.The FSM determines whether the SPI module is in the normal operating state, waiting state, or
stopped state.
The SPI FSM consists of three states:
• SPI_RUN
• SPI_WAIT
• SPI_STOP

<img width="571" height="125" alt="image" src="https://github.com/user-attachments/assets/1f944302-0b7f-47ac-87c4-529eed001aac" />

<img width="322" height="392" alt="image" src="https://github.com/user-attachments/assets/423ae4af-4baf-49e8-905b-0e667e23866f" />

## 1.SPI_RUN MODE
SPI_RUN is the normal operating state of the SPI controller.
While in this state:
If SPE = 1, the FSM remains in SPI_RUN. If SPE = 0, the FSM transitions to SPI_WAIT.
• SPE = 1 → SPI_RUN
SPE = 0 → SPI_WAIT
## 2. SPI WAIT MODE
SPI_WAIT is entered when SPI operation is disabled by clearing the SPE bit.
While in this state:
If SPE = 1, the FSM returns to SPI_RUN. If SPE = 0 and SPISWAI = 1, the FSM transitions to SPI_STOP.
If SPE = 0 and SPISWAI = 0, the FSM remains in SPI_WAIT.
• SPE = 1 → SPI_RUN
SPE = 0, SPISWAI = 1 → SPI_STOP
SPE = 0, SPISWAI = 0 → SPI_WAIT
## 3. SPI STOP MODE
SPI_STOP represents the stopped state of the SPI controller.
While in this state:

If SPE = 1, the FSM returns to SPI_RUN. If SPE = 0 and SPISWAI = 0, the FSM transitions to SPI_WAIT. If
SPE = 0 and SPISWAI = 1, the FSM remains in SPI_STOP.
• SPE = 1 → SPI_RUN
SPE = 0, SPISWAI = 0 → SPI_WAIT
SPE = 0, SPISWAI = 1 → SPI_STOP
SPI BAUD RATE GENERATION
The Baud Rate Generator generates the SPI Serial Clock (SCLK) by dividing the input system clock.The
SPI clock frequency is controlled using the programmable SPPR and SPR fields.
Baud Rate Divisor = (SPPR + 1) × 2^(SPR + 1)
The SPI clock frequency is calculated as:
F_SCLK = F_PCLK / Baud Rate Divisor
F_SCLK = F_PCLK / [(SPPR + 1) × 2^(SPR + 1)]
Where:
• F_SCLK = SPI Serial Clock frequency
• F_PCLK = Input/System Clock frequency
• SPPR = SPI Prescaler value
• SPR = SPI Rate Select value
Function of SPPR and SPR
• SPPR: Provides the prescaling factor.
• SPR: Provides the additional power-of-two division.
Increasing the divider → lower SCLK frequency.
Decreasing the divider → higher SCLK frequency.
# SCLK Timing
The generated SCLK is controlled according to the selected CPOL and CPHA settings.
CPOL determines the idle level of SCLK.
CPHA determines the clock edge used for data sampling and shifting
# SLAVE SELECT (SS) CONTROL
The Slave Select (SS) signal is used by the SPI Master to select the target SPI Slave during
communication.
In SPI, SS is generally active LOW.

• SS = 1 → Slave is not selected / bus is idle.
• SS = 0 → Slave is selected and SPI transfer is active.
SS Control Operation
When an SPI data transfer is initiated, the Master drives SS LOW.
• Data Transfer Start → SS = 0
Data Transfer Active → SS = 0
Data Transfer Complete → SS = 1
The SS signal remains LOW for the duration of the SPI transfer and returns HIGH when the transfer is
completed.
Purpose of SS
The SS signal:

1) Selects the required SPI Slave.
2) Indicates the beginning of an SPI transaction.
3) Remains active during data transfer.
4) Indicates the end of the SPI transaction when deasserted.

## SPI DATA TRANSMISSION
SPI data transmission is the process of sending 8-bit serial data from the Master to the Slave through the
MOSI line.The data is transmitted synchronously with the SPI SCLK signal.
Data Order
The SPI Master supports two data transmission orders:
• MSB First: Most Significant Bit is transmitted first.
• LSB First: Least Significant Bit is transmitted first.
Clock and Data
The transmission timing is controlled by the selected CPOL and CPHA settings.
CPOL determines the idle level of SCLK.
CPHA determines the clock edge used for data transfer.
SPI transmission sends 8-bit data serially through MOSI, synchronized with SCLK, while SS remains
LOW.

## SPI DATA RECEPTION
SPI data reception is the process of receiving 8-bit serial data from the Slave through the MISO line.
The received data is sampled synchronously with the SPI SCLK signal.
Data Order
The received data can be arranged in either:
• MSB First – Most Significant Bit is received first.
• LSB First – Least Significant Bit is received first.
Clock and Data
• The sampling of MISO is controlled by the selected CPOL and CPHA settings.
• CPOL determines the idle level of SCLK.
• CPHA determines the clock edge used for data sampling.
SPI INTERRUPT GENERATION
The SPI interrupt mechanism generates an interrupt request when a configured SPI status condition
occurs. The interrupt can be enabled through the control register using the appropriate interrupt-enable
bits.
Interrupt Conditions
The SPI interrupt request can be generated based on:
• SPI Status Flag (SPIF)
• Mode Fault Flag (MODF)
• SPI Transmit Empty Flag (SPTEF)
The corresponding interrupt-enable controls determine whether these conditions generate an interrupt
request.

## MODE FAULT DETECTION
Mode Fault Detection is used to detect an unexpected Slave Select (SS) condition while the SPI Master is
operating.It helps identify a conflict or incorrect Slave Select condition during Master mode operation.
Mode Fault Condition
A mode fault is detected when:

• SPI is operating in Master mode.
• Mode-fault detection is enabled.
• SS is LOW.
• Slave Select output control is disabled
Mode-fault detection helps the SPI Master identify an unexpected SS condition and provides the MODF
status flag, which can also contribute to SPI interrupt generation.




