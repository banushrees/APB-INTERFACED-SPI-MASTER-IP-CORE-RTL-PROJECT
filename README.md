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
Signal Width Description
pclk 1 APB clock
preset_n 1 Active-low asynchronous reset
paddr 3 APB register address

pwrite 1 Selects APB write or read operation
psel 1 Selects the SPI peripheral
penable 1 Indicates the APB access phase
pwdata 8 APB write data
ss 1 SPI Slave Select signal
Miso_data 8 Received SPI data (master in slave out)
receive_data 1 Indicates received-data availability
tip 1 Indicates that an SPI transfer is in progress

APB Slave Interface Outputs
Signal Width Description
prdata 8 APB read data
mstr 1 SPI Master mode control
cpol 1 SPI clock polarity
cpha 1 SPI clock phase
lsbfe 1 Selects LSB-first data transfer
spiswai 1 SPI wait-mode control
sppr 3 SPI baud-rate prescaler
spr 3 SPI baud-rate selection
spi_interrupt_request 1 SPI interrupt request
pready 1 APB transfer ready indication
pslverr 1 APB slave error indication
send_data 1 Initiates SPI data transfer
mosi_data 8 Transmit data supplied to the

shift register
spi_mode 2 SPI operating mode


