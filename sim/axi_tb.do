vlib work
vmap work work

# 编译 Verilog 文件
vlog 	C:/Users/yqy/Desktop/AXI_sim/main_tb.v
vlog 	C:/Users/yqy/Desktop/AXI_sim/axi_stream_header_insert.v

vsim -voptargs=+acc work.main_tb

do wave.do
run 1500ns