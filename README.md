
## Introduce
This is a c910(64bit risc-v design by T-head) modified core, we will change verilog into systemverilog,improve simulation flow,such us cosim and hw/sw debug.We will also optimize c910 microarchitecture.

## How to run
1- Download Xuantie-900-gcc-elf-newlib-x86_64-V2.8.1-20240115.tar.gz from https://www.xrvm.cn/community/download?id=4090445921563774976
unpack Xuantie-900-gcc-elf-newlib-x86_64-V2.8.1-20240115.tar.gz in OpenC910_Modified directory or other directory,but you should modify the path of Xuantie-900-gcc-elf-newlib-x86_64-V2.8.1 in OpenC910_Modified/smart_run/Makefile.

2- cd OpenC910_Modified/smart_run $make showcase,it will show you which case you can run,$make help,it will show you how to run.
