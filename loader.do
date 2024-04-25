add wave -position end  sim:/processor/clk
add wave -position end  sim:/processor/reset
add wave -position end  sim:/processor/pc
add wave -position end  /processor/registerFile/regs
add wave -position end  sim:/processor/in_port
add wave -position end  sim:/processor/out_port
add wave -position end  /processor/memory/memory_arr
add wave -position end  sim:/processor/alu/Z
add wave -position end  sim:/processor/alu/N
add wave -position end  sim:/processor/alu/O
add wave -position end  sim:/processor/alu/C
mem load -skip 0 -filltype value -filldata { 4013 0001  4813 AAAA  5013 FFFF  0004  2027  0821  1807  0004  0290  2C2E  3007  0450  00B0  3B8E  30C1  0004} -fillradix hexadecimal -startaddress 0 -endaddress 18 /processor/instructionMemory/memory_arr