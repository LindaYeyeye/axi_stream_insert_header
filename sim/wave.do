onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /main_tb/axi_u0/clk
add wave -noupdate /main_tb/axi_u0/rst_n
add wave -noupdate -color Coral /main_tb/axi_u0/hdr_buffer_full
add wave -noupdate -color Coral /main_tb/axi_u0/data_buffer_full
add wave -noupdate /main_tb/hdr_axi_slave/hdr_cnt
add wave -noupdate -color Khaki /main_tb/axi_u0/valid_insert
add wave -noupdate -color Khaki /main_tb/axi_u0/ready_insert
add wave -noupdate -color Khaki /main_tb/axi_u0/data_insert
add wave -noupdate -color Khaki /main_tb/axi_u0/keep_insert
add wave -noupdate /main_tb/axi_u0/hdr_r1
add wave -noupdate /main_tb/axi_u0/hdr_keep_r1
add wave -noupdate -color Khaki /main_tb/axi_u0/byte_insert_cnt
add wave -noupdate /main_tb/axi_u0/temp_data
add wave -noupdate /main_tb/axi_u0/temp_keep
add wave -noupdate -color Violet /main_tb/axi_u0/valid_in
add wave -noupdate -color Violet /main_tb/axi_u0/ready_in
add wave -noupdate -color Violet /main_tb/axi_u0/data_in
add wave -noupdate -color Violet /main_tb/axi_u0/last_in
add wave -noupdate -color Violet /main_tb/axi_u0/keep_in
add wave -noupdate /main_tb/data_axi_last/last_cnt
add wave -noupdate -color Cyan /main_tb/axi_u0/valid_out
add wave -noupdate -color Cyan /main_tb/axi_u0/ready_out
add wave -noupdate -color Cyan /main_tb/axi_u0/last_out
add wave -noupdate -color Cyan /main_tb/axi_u0/data_out
add wave -noupdate /main_tb/axi_u0/data_valid_r1
add wave -noupdate /main_tb/axi_u0/data_valid_r2
add wave -noupdate /main_tb/axi_u0/data_last_r1
add wave -noupdate /main_tb/axi_u0/data_r1
add wave -noupdate /main_tb/axi_u0/data_keep_r1
add wave -noupdate /main_tb/axi_u0/hdr_valid_r1
add wave -noupdate /main_tb/axi_u0/byte_insert_cnt_r1
add wave -noupdate /main_tb/axi_u0/hdr_en
add wave -noupdate /main_tb/axi_u0/shift_cnt
add wave -noupdate /main_tb/axi_u0/data_last_r2
add wave -noupdate -color Cyan /main_tb/axi_u0/keep_out
add wave -noupdate /main_tb/axi_u0/last_flag
add wave -noupdate /main_tb/axi_u0/last_flag_r1
add wave -noupdate /main_tb/axi_u0/last_trans
add wave -noupdate /main_tb/axi_u0/last_trans_r1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {928421 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 353
configure wave -valuecolwidth 127
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {889508 ps} {1035547 ps}
