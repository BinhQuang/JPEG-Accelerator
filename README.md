# JPEG Hardware Accelerator

## Project Description

This project presents a comprehensive **Hardware Accelerator** design for the **Joint Photographic Experts Group (JPEG) encoding standard**. Developed entirely in **Verilog HDL**, the core objective is to achieve high-performance, parallel processing of the JPEG compression pipeline, making it suitable for implementation on **Field-Programmable Gate Arrays (FPGAs)**.

The design is implemented with a clear, modular, and pipelined architecture, integrating all necessary functional blocks of a baseline JPEG encoder.

## Key Functional Blocks

The design is decomposed into individual RTL modules corresponding to the sequential stages of the JPEG compression algorithm:

| Stage | Module Files | Functionality |
| :--- | :--- | :--- |
| **1. Pre-processing** | `color_space_conversion.v` | Converts image data from the RGB color space to YCbCr. |
| | `downsampler_420.v` | Performs 4:2:0 chroma subsampling on the Cb and Cr components to reduce data volume. |
| **2. Block Splitting** | `block_splitter.v` | Divides the image components into 8x8 data blocks for subsequent processing. |
| **3. DCT** | `dct_2d.v` | Computes the **2D Discrete Cosine Transform** on the 8x8 blocks. |
| **4. Quantization** | `jpeg_quantizer.v` / `quantization.v` | Quantizes the DCT coefficients using a specified quantization matrix (`quant_matrix_rom.v`). |
| **5. Entropy Encoding** | `entropy_encoder.v` | Applies lossless compression techniques (e.g., Zig-zag scanning, Run-Length Encoding, Huffman coding) to the quantized coefficients. |
| **Top Level** | `top_module_jpeg.v` | The primary module that controls and integrates the entire data flow pipeline. |


## Development Environment and Tools

* **Hardware Description Language:** Verilog HDL / SystemVerilog
* **Target Synthesis Tool:** Intel Quartus Prime
* **Simulation & Verification:** ModelSim/QuestaSim (Utilizing dedicated testbench files (`*_tb.v`) and the `simulation/modelsim` directory).
* **Timing Constraints:** Synchronization and timing requirements are managed using SDC files (e.g., `color_space_conversion.sdc`).

## Project Status

This design represents a comprehensive, synthesizable JPEG encoder at the **Register-Transfer Level (RTL)**. It is ready for synthesis, place-and-route, and deployment on an FPGA device to realize hardware acceleration capabilities.

## Repository Structure

The repository is structured to separate design files from tool-specific outputs:

* **RTL Source:** `*.v`, `*.sv` (Core design modules).
* **Verification:** `*_tb.v` (Testbench files).
* **Simulation Environment:** `simulation/modelsim` (Simulation scripts and settings).
* **Quartus Files:** `*.qpf`, `*.qsf`, `*.qws` (Project and configuration settings).
