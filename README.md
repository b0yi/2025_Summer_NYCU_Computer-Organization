# MIPS Processor Design: From ALU to Advanced Pipelined CPU

This repository contains a comprehensive series of Verilog implementations for a MIPS-based architecture. The project documents the systematic evolution from basic hardware components to a high-performance CPU capable of handling complex hazards.

## 📌 Project Overview
The objective is to design a 32-bit processor using Verilog HDL. The project emphasizes structural design, moving from gate-level combinational logic to a pipelined architecture that utilizes data forwarding and hazard detection to optimize instruction throughput.

---

## 🛠 Lab Modules

### Lab 2: 32-bit Arithmetic Logic Unit (ALU)
The foundational execution unit of the processor.
* **Design Philosophy**: Implemented using gate-level combinational logic.
* **Key Features**: Supports 32-bit operations including ADD, SUB, AND, OR, NAND, NOR, and SLT (Set on Less Than).
* **Control Signals**: Utilizes `invertA`, `invertB`, and a 2-bit `operation` code to determine the output.
* **Status Flags**: Generates `zero` (result is zero) and `overflow` (arithmetic error) signals.

### Lab 3: Single-Cycle CPU
Integration of the ALU into a complete datapath that executes instructions in one clock cycle.
* **Instruction Set Architecture (ISA)**: 
    * **R-type**: `add`, `sub`, `AND`, `OR`, `NOR`, `slt`, `sll`, `srl`, `sllv`, `srlv`, `jr`.
    * **I-type**: `lw`, `sw`, `beq`, `bne`, `addi`.
    * **J-type**: `j`, `jal`.
* **Core Components**: Implements an Instruction Memory, Register File, Data Memory, and a Control Unit to manage data flow.

### Lab 4: Pipelined CPU
Transformation of the single-cycle architecture into a 5-stage pipeline to increase efficiency.
* **Pipeline Stages**: Split into IF (Fetch), ID (Decode), EX (Execute), MEM (Memory), and WB (Write Back).
* **Synchronization**: Uses pipeline registers (e.g., `IF/ID`, `ID/EX`) to pass control signals and data between stages.
* **Supported Instructions**: Focused on R-type and I-type instructions for stable pipeline flow.

### Lab 5: Advanced Pipelined CPU
A high-performance CPU refined to handle architectural hazards.
* **Data Forwarding**: Includes a **Forwarding Unit** that passes data directly from the execution or memory stages to the ALU, eliminating stalls caused by data dependency.
* **Hazard Detection**: Features a **Hazard Detection Unit** to identify "load-use" dependencies, automatically stalling the CPU and inserting "bubbles" to ensure data integrity.
* **Flushing Mechanism**: Implements pipeline flushing to handle branch instructions correctly.

---
