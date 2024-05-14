# Fire-Core RISC-V Processor

## Project Target:
- Supported the RISC-V32E instruction set and passed compatibility testing with the RISC-V instruction set.

- Adopted the classic five-stage pipeline structure (i.e., fetch, decode, execute, memory access, and write-back), and all instructions are single-issue in-order execution, adhering to the K.I.S.S. principle of Unix kernel architecture design.Potential future enhancements may include changing to out-of-order execution.

- Designed with a dedicated data bus interface based on AMBA AXI4, the system enables uni-directional or bi-directional communication with peripheral devices (currently including GPIO, SPI, UART) via the system bus.

- Supported basic cache to improve memory access performance and included robust exception handling mechanisms to manage various system errors and interrupts.

- The processor core is capable of running C language programs in both bare-metal and RT-Thread environments.

