# 🚀 UART Controller — Design (Verilog) & Verification (SystemVerilog)

![Verilog](https://img.shields.io/badge/RTL-Verilog-blue)
![SystemVerilog](https://img.shields.io/badge/Verification-SystemVerilog-orange)
![Status](https://img.shields.io/badge/Status-Completed-brightgreen)
![Simulation](https://img.shields.io/badge/Simulation-Passed-success)
![Coverage](https://img.shields.io/badge/Functional%20Coverage-91.44%25-yellow)

---

## 📌 Overview

This project implements a **UART (Universal Asynchronous Receiver/Transmitter)** controller in Verilog — including a **transmitter**, a **16x-oversampling receiver**, and a **baud rate generator** — and verifies it using two independent testbench flows:

1. **Verilog self-checking testbench** — directed, loopback-based (TX → RX) sanity verification.
2. **SystemVerilog class-based verification environment** — a structured, reusable testbench (generator, driver, monitor, reference model, scoreboard) built to verify the same RTL more rigorously, with functional coverage tracked using **Questa/ModelSim**.

The goal of this project was to go beyond just "designing a UART" and actually build a proper **verification methodology** around it — the same way it's done in industry ASIC/FPGA verification flows.

---

## 🧠 Features

- ✔ UART Transmitter (TX)
- ✔ UART Receiver (RX) with 16x oversampling
- ✔ Baud Rate Generator (9600 baud @ 100 MHz)
- ✔ Loopback integration (TX → RX)
- ✔ Self-checking Verilog testbench (PASS/FAIL)
- ✔ Class-based SystemVerilog verification environment
- ✔ Reference model–based scoreboard checking
- ✔ Functional coverage collection (Questa)
- ✔ Lint report & synthesis schematics included

---

## ⚙️ Design Specifications

| Parameter | Value |
|---|---|
| Clock Frequency | 100 MHz |
| Baud Rate | 9600 |
| Data Bits | 8 |
| Stop Bits | 1 |
| Parity | None |
| Oversampling | 16x |

---

## 🏗️ RTL Architecture

```
uart_top
 ├── uart_baud_generator   → generates the 16x oversampling clock/tick
 ├── uart_tx               → serializes parallel data → serial line
 └── uart_rx               → samples serial line → reconstructs parallel data
```

**Data flow:**
1. Parallel data is applied via `data_in` along with `wr_en`.
2. `uart_tx` serializes the byte and transmits it, framed with start/stop bits.
3. `uart_rx` oversamples the incoming line at 16x the baud rate to reliably detect bit edges.
4. Received bits are reconstructed into a byte.
5. `rdy` is asserted to indicate valid received data.

---

## 🧪 Verification

This project is verified through **two separate testbench environments**, kept in separate folders so the original design-stage testing and the later verification-stage testing are both visible.

### 1️⃣ Verilog Testbench (`verilog_tb/`)
A directed, self-checking testbench used during the initial design phase:
- Applies known test vectors through a TX → RX loopback
- Automatically compares received data against transmitted data
- Reports PASS/FAIL per test case
- Test cases: `0x41` ('A'), `0x55`, `0xFF`, `0x00`

### 2️⃣ SystemVerilog Verification Environment (`sv_tb/`)
A class-based, reusable verification environment, structured similarly to a UVM-lite architecture:

| File | Role |
|---|---|
| `uart_pkg.sv` | Package containing shared types, parameters, and imports |
| `uart_txn.sv` | Transaction class defining a UART data item |
| `uart_if.sv` | Virtual interface connecting the testbench to the DUT |
| `uart_generator.sv` | Generates (randomized) transactions to drive |
| `uart_driver.sv` | Drives generated transactions onto the DUT via the interface |
| `uart_monitor.sv` | Passively observes DUT pins and captures activity |
| `uart_ref_model.sv` | Predicts expected DUT behavior for each transaction |
| `uart_scoreboard.sv` | Compares monitored DUT output against the reference model |
| `uart_env.sv` | Instantiates and connects generator, driver, monitor, scoreboard |
| `uart_test.sv` | Top-level test class that configures and runs the environment |
| `uart_tb_top.sv` | Top-level testbench module — instantiates DUT + interface + test |

**Verification flow:**
```
uart_generator → uart_driver → DUT (uart_top)
                                   │
                              uart_monitor
                                   │
                     ┌─────────────┴─────────────┐
                uart_ref_model               (actual output)
                     │                             │
                     └────────► uart_scoreboard ◄───┘
                                (PASS/FAIL check)
```

### 🔧 Simulation Setup (`sim_questa/`)
- Simulated using **Questa/ModelSim**
- `run.do` — simulation script to compile RTL + SV testbench, run the test, and generate coverage
- `coverage_report/` — generated HTML functional coverage report (viewable in a browser)

---

## 📊 Functional Coverage Report

Coverage collected via Questa, summarized below:

| Coverage Type | Bins | Hits | Misses | % Hit |
|---|---|---|---|---|
| **Total Coverage** | — | — | — | **91.44%** |
| Covergroups | 11 | 11 | 0 | 100.00% |
| Statements | 224 | 214 | 10 | 95.53% |
| Branches | 48 | 45 | 3 | 93.75% |
| FEC Expressions | 7 | 7 | 0 | 100.00% |
| FEC Conditions | 13 | 9 | 4 | 69.23% |

> Full interactive report available in [`sim_questa/coverage_report`](./sim_questa/coverage_report).

**Coverage summary by structure:**

| Design Scope | Hits % | Coverage % |
|---|---|---|
| `uart_tb_top` | 85.77% | 90.40% |
| `intf` | 97.91% | 98.86% |
| `dut` | 84.03% | 89.70% |
| `uart_pkg` | 94.44% | 80.86% |
| `uart_transaction_display` | 100.00% | 100.00% |
| `uart_generator/new` | 100.00% | 100.00% |

---

## 📷 Waveforms & Reports

| Description | File |
|---|---|
| UART TX waveform | `uart_tx_waveform.png` |
| UART RX waveform | `uart_rx_waveform.png` |
| UART Top-level (loopback) waveform | `uart_top_waveform_using_verilog.png` |
| Baud rate generator waveform | `uart_baud_generator_waveform.png` |
| Lint report | `lint_report.png` |
| RTL schematic | `schematic.png` |
| Synthesis schematics | `synthesis_schematic_1.png`, `synthesis_schematic_2.png` |
| Functional coverage report (summary) | `coverage_report.png` |

---

## 📁 Project Structure

```
uart-protocol/
├── rtl/
│   ├── uart_baud_generator.v
│   ├── uart_rx.v
│   ├── uart_tx.v
│   └── uart_top.v
│
├── verilog_tb/
│   └── (self-checking Verilog loopback testbench)
│
├── sv_tb/
│   ├── uart_pkg.sv
│   ├── uart_txn.sv
│   ├── uart_if.sv
│   ├── uart_generator.sv
│   ├── uart_driver.sv
│   ├── uart_monitor.sv
│   ├── uart_ref_model.sv
│   ├── uart_scoreboard.sv
│   ├── uart_env.sv
│   ├── uart_test.sv
│   └── uart_tb_top.sv
│
├── sim/
│   └── (simulation scripts/logs)
│
├── sim_questa/
│   ├── run.do
│   └── coverage_report/        # generated HTML coverage report
│
├── coverage_report.png
├── lint_report.png
├── schematic.png
├── synthesis_schematic_1.png
├── synthesis_schematic_2.png
├── uart_tx_waveform.png
├── uart_rx_waveform.png
├── uart_top_waveform_using_verilog.png
├── uart_baud_generator_waveform.png
│
├── README.md
├── .gitignore
└── .gitattributes
```

---

## ▶️ How to Run

**Verilog self-checking testbench:**
```bash
# Using Icarus Verilog / your simulator of choice
iverilog -o uart_sim rtl/*.v verilog_tb/*.v
vvp uart_sim
```

**SystemVerilog verification environment (Questa/ModelSim):**
```bash
cd sim_questa
vsim -do run.do
```
This compiles the RTL + `sv_tb/` sources, runs the test, and generates the functional coverage report under `coverage_report/`.

---

## 🚀 Future Improvements

- [ ] FIFO integration for TX/RX buffering
- [ ] Parity bit support
- [ ] Configurable baud rate
- [ ] AXI/APB register interface
- [ ] Close remaining FEC condition coverage gaps (currently 69.23%)
- [ ] Constrained-random stimulus with additional corner-case scenarios

---

## 📌 Key Learnings

- UART protocol implementation (framing, baud generation, oversampling)
- FSM-based RTL design
- 16x oversampling receiver design
- Self-checking testbench methodology
- Class-based SystemVerilog verification (driver/monitor/scoreboard/reference model)
- Functional coverage-driven verification using Questa
- System-level TX/RX loopback integration

---

## 🔗 Author

**Virupakshayya Hiremath**
Repository: [uart-protocol](https://github.com/Virupakshayyahiremath/uart-protocol)