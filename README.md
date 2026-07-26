# UART Protocol Design and Verification

<p align="center">

![Verilog](https://img.shields.io/badge/RTL-Verilog-blue)
![SystemVerilog](https://img.shields.io/badge/Verification-SystemVerilog-success)
![QuestaSim](https://img.shields.io/badge/Simulator-QuestaSim-orange)
![Coverage](https://img.shields.io/badge/Functional%20Coverage-100%25-brightgreen)

</p>

---

# Overview

This repository contains the complete RTL implementation and functional verification of a **Universal Asynchronous Receiver Transmitter (UART)**.

The UART is designed using **Verilog HDL** and verified using a reusable **SystemVerilog self-checking testbench**. The verification environment includes constrained-random stimulus generation, monitor, reference model, scoreboard, and functional coverage to ensure correctness of the UART transmitter and receiver.

The project also includes RTL synthesis results, simulation waveforms, coverage reports, and automation scripts.

---

# Features

## RTL Design

- UART Transmitter
- UART Receiver
- Baud Rate Generator
- UART Top Module
- Parameterized Clock Divider
- 8-bit Data Transmission
- Start Bit Generation
- Stop Bit Generation
- Parallel-to-Serial Conversion
- Serial-to-Parallel Conversion

---

## Verification Features

A reusable layered SystemVerilog verification environment has been implemented.

Components include:

- Interface
- Transaction Class
- Generator
- Driver
- Monitor
- Reference Model
- Scoreboard
- Functional Coverage
- Environment
- Test
- Package

Verification techniques:

- Self-checking testbench
- Mailbox-based communication
- Automatic result comparison
- Functional coverage collection
- Random stimulus generation

---

# RTL Architecture

```
                +---------------------+
                | Baud Generator      |
                +----------+----------+
                           |
                           |
          +----------------+----------------+
          |                                 |
          |                                 |
+---------v---------+             +---------v---------+
| UART Transmitter  |             | UART Receiver     |
+---------+---------+             +---------+---------+
          |                                 |
          +---------------+-----------------+
                          |
                    UART Top Module
```

---

# Verification Architecture

```
             +----------------+
             |   Generator    |
             +--------+-------+
                      |
                      v
             +----------------+
             |    Driver      |
             +--------+-------+
                      |
                      v
             +----------------+
             |  UART DUT      |
             +--------+-------+
                      |
              +-------+-------+
              |               |
              v               v
        +-----------+   +-------------+
        |  Monitor  |   |  Coverage   |
        +-----+-----+   +-------------+
              |
              v
     +---------------------+
     | Reference Model     |
     +----------+----------+
                |
                v
        +---------------+
        | Scoreboard    |
        +---------------+
```

---

# Repository Structure

```
uart-protocol/

├── rtl/
│   ├── uart_baud_generator.v
│   ├── uart_tx.v
│   ├── uart_rx.v
│   ├── uart_top.v
│
├── sv_tb/
│   ├── uart_if.sv
│   ├── uart_transaction.sv
│   ├── uart_generator.sv
│   ├── uart_driver.sv
│   ├── uart_monitor.sv
│   ├── uart_ref_model.sv
│   ├── uart_scoreboard.sv
│   ├── uart_env.sv
│   ├── uart_test.sv
│   ├── uart_pkg.sv
│   └── uart_tb_top.sv
│
├── sim/
│
├── sim_questa/
│   ├── run.do
│   └── coverage_report/
│
├── images/
│   ├── coverage_report.png
│   ├── lint_report.png
│   ├── uart_tx_waveform.png
│   ├── uart_rx_waveform.png
│   ├── uart_baud_generator_waveform.png
│   └── synthesis_schematic.png
│
├── README.md
└── .gitignore
```

---

# Simulation Flow

```
Compile RTL
      │
      ▼
Compile Testbench
      │
      ▼
Generate Random Transactions
      │
      ▼
Drive DUT
      │
      ▼
Monitor Outputs
      │
      ▼
Reference Model
      │
      ▼
Scoreboard Comparison
      │
      ▼
Functional Coverage
```

---

# Functional Coverage

| Metric | Result |
|---------|--------|
| Overall Coverage | **91.44%** |
| Functional Coverage | **100%** |
| Statement Coverage | **95.53%** |
| Branch Coverage | **93.75%** |
| Expression Coverage | **100%** |
| Condition Coverage | **69.23%** |

---

# Coverage Report

![Coverage Report](images/coverage_report.png)

The complete HTML coverage report is available in:

```
sim_questa/coverage_report/
```

---

# Simulation Waveforms

## UART Transmitter

![UART TX](images/uart_tx_waveform.png)

---

## UART Receiver

![UART RX](images/uart_rx_waveform.png)

---

## Baud Generator

![Baud Generator](images/uart_baud_generator_waveform.png)

---

# RTL Synthesis

RTL synthesis was performed using Synopsys Design Compiler.

The synthesized schematic is shown below.

![Synthesis](images/synthesis_schematic.png)

---

# Tools Used

| Tool | Purpose |
|------|---------|
| Verilog HDL | RTL Design |
| SystemVerilog | Verification |
| QuestaSim | Simulation & Functional Coverage |
| Synopsys Design Compiler | RTL Synthesis |
| Git | Version Control |
| GitHub | Source Code Hosting |

---

# Running the Simulation

Compile and simulate using the provided QuestaSim script:

```tcl
do sim_questa/run.do
```

or

```bash
vsim -do sim_questa/run.do
```

The script automatically:

- Compiles RTL
- Compiles SystemVerilog testbench
- Starts simulation
- Runs all testcases
- Saves functional coverage database
- Generates coverage reports

---

# Key Learning Outcomes

- Designed a synthesizable UART Transmitter and Receiver using Verilog HDL.
- Developed a reusable layered SystemVerilog verification environment.
- Implemented Generator, Driver, Monitor, Reference Model, Scoreboard, and Functional Coverage.
- Verified UART functionality using a self-checking methodology.
- Performed functional coverage analysis using QuestaSim.
- Executed RTL synthesis using Synopsys Design Compiler.
- Organized the project with reusable simulation scripts and documentation.

---

# Future Improvements

- UVM-based verification environment
- SystemVerilog Assertions (SVA)
- Parity support
- Configurable data width
- Configurable stop bits
- Error injection testcases
- Continuous Integration (CI) for automated simulation and regression

---

# Author

**Virupakshayya Hiremath**

Electronics and Communication Engineering

Interested in:

- RTL Design
- ASIC Front-End Design
- Design Verification
- FPGA Design

GitHub:
https://github.com/Virupakshayyahiremath

LinkedIn:
https://www.linkedin.com/in/virupakshayya/
---

⭐ If you found this project useful, consider starring the repository.