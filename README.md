risc-v 64bit 

how to run case

## 1 
download Xuantie-900-gcc-elf-newlib-x86_64-V2.8.1-20240115.tar.gz from https://www.xrvm.cn/community/download?id=4090445921563774976
unpack Xuantie-900-gcc-elf-newlib-x86_64-V2.8.1-20240115.tar.gz in OpenC910_Modified directory
## 2 
source C910_RTL_FACTORY/setup/setup.csh
## 3 
source smart_run/setup/example_setup.csh
## 4 
cd smart_run
## 5 
make help
## 6 
select case that you want to run
## 7 
make debug

note: default sim:   vcs,
      default debug: verdi
