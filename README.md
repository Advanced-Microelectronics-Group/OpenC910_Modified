## Introduce

This is a modified 64-bit RISC-V core designed by T-head, known as C910. Our team is trying to swift the HDL from Verilog to SystemVerilog, optimize its microarchitecture, and improve the simulation flow such as cosim and HW/SW debug.

## To Do

| Task                              | Status      |
| --------------------------------- | ----------- |
| `lint flow`                       | In progress |
| `fpga syn flow`                   | In progress |
| `syn flow`                        | In progress |
| `cosim environment(spike)`        | In progress |
| `change verilog to systemverilog` | In progress |
| `optimize microarchitecture`      | In progress |
| `random instructions case`        | In progress |
| `hw/sw debug`                     | In progress |

**Note:** The project might support the commercial EDA tools but it does not mean that any commercial EDA had been used throughout this project and the flow. None of the technical commitments or guarantees will be promised by the team. Currently, the project is in the initial stages and the target of the team is to design an unique RV64 core in the future.

## How to run

1. Download `Xuantie-900-gcc-elf-newlib-x86_64-V2.8.1-20240115.tar.gz` (or other version) from either [XuanTieC910 Official](https://www.xrvm.cn/community/download?id=4090445921563774976) or [OpenC910 GitHub](https://github.com/T-head-Semi/openc910.git)
2. Unpack `Xuantie-900-gcc-elf-newlib-x86_64-V2.8.1-20240115.tar.gz` in `OpenC910_Modified` directory or other directory, but you should modify the path of `Xuantie-900-gcc-elf-newlib-x86_64-V2.8.1` in `OpenC910_Modified/smart_run/Makefile`
3. $`cd OpenC910_Modified/smart_run`
4. $`make showcase` will show you which case you can run
5. $`make help` will show you how to run case

## About us

We are a microelectronics open source organization, established in February 2024, focusing on RISC-V chip design, involving CPU, GPU, etc. Our vision is to make chip design accessible to more people and promote the development of the open source RISC-V community.
