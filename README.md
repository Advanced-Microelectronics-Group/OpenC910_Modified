## Introduce

This is a C910 (64bit risc-v design by T-head) modified core, we will do something based on C910 first, verilog into systemverilog,improve simulation flow,such us cosim and hw/sw debug,optimize c910 microarchitecture.

## To Do

| task                              | status      |
| --------------------------------- | ----------- |
| `lint flow`                       | in progress |
| `fpga syn flow`                   | in progress |
| `syn flow`                        | in progress |
| `cosim environment(spike)`        | in progress |
| `change verilog to systemverilog` | in progress |
| `optimize microarchitecture`      | in progress |
| `random instructions case`        | in progress |
| `hw/sw debug`                     | in progress |

`note:`We may just support business eda ,it does not mean that we use business eda to test this project and flow.We do not make any technical commitments or guarantees to you.We are in the initial stages of the project,and will design our own RV64 core  in feature.

## How to run

1、 Download `Xuantie-900-gcc-elf-newlib-x86_64-V2.8.1-20240115.tar.gz`(or other version) from `https://www.xrvm.cn/community/download?id=4090445921563774976`（login is required），and unpack `Xuantie-900-gcc-elf-newlib-x86_64-V2.8.1-20240115.tar.gz` in `OpenC910_Modified` directory or other directory,but you should modify the path of `Xuantie-900-gcc-elf-newlib-x86_64-V2.8.1` in `OpenC910_Modified/smart_run/Makefile`.

2、$`cd` OpenC910_Modified/smart_run

 $`make showcase`,it will show you which case you can run

$`make help`,it will show you how to run case.

## About us

We are a microelectronics open source organization, established in February 2024, focusing on RISC-V chip design, involving CPU, GPU, etc. Our vision is to make chip design accessible to more people and promote the development of the open source RISC-V community.