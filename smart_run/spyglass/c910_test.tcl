
set_option top cpu_sub_system_axi
set_option sdc2sgdc yes
set_option enableSV yes
set_option language_mode mixed
read_file -type sourcelist ../logical/filelists/ip.fl
read_file -type sourcelist ../logical/filelists/smart.fl
read_file -type sourcelist ../logical/filelists/tb.fl
read_file -type sgdc ./c910_test.sgdc
current_goal Design_Read -top cpu_sub_system_axi
link_design -force
set_option designread_enable_synthesis yes
compile_design -force


