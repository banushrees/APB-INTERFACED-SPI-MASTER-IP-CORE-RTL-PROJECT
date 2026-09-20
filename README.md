# APB-INTERFACED-SPI-MThe project involves the design of an APB-based SPI Master Core using RTL.The SPI Master Core is
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
