`timescale 1ns / 1ps

module axi_stream_header_insert #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8 ,
	parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD)
) (
    input                        clk,
    input                        rst_n,

    // AXI Stream input header
    input                        valid_insert,
    input   [DATA_WD-1 : 0]      data_insert,
    input   [DATA_BYTE_WD-1 : 0] keep_insert,
    output                       ready_insert,
	input   [BYTE_CNT_WD-1 : 0]  byte_insert_cnt, //keep insert内有多少个1

    // AXI Stream input data
    input                        valid_in,
    input   [DATA_WD-1 : 0]      data_in,
    input   [DATA_BYTE_WD-1 : 0] keep_in,
    input                        last_in,
    output                       ready_in,

    // AXI Stream output header inserted data
    output                       valid_out,
    output reg [DATA_WD-1 : 0]   data_out,
    output reg [DATA_BYTE_WD-1:0]keep_out,
    output                       last_out,
    input                        ready_out
);
//
reg								data_valid_r1;
reg								data_valid_r2;
reg								data_last_r1;
reg								data_last_r2;
reg		[DATA_WD-1 : 0]			data_r1;
reg		[DATA_BYTE_WD-1 : 0] 	data_keep_r1;

reg								hdr_valid_r1;
reg		[DATA_WD-1 : 0]			hdr_r1;
reg		[DATA_BYTE_WD-1 : 0] 	hdr_keep_r1;
reg		[BYTE_CNT_WD-1 : 0]		byte_insert_cnt_r1;

reg 	[2*DATA_WD-1 : 0]		temp_data;
reg 	[2*DATA_BYTE_WD-1 : 0] 	temp_keep;
reg 	hdr_buffer_full;
reg 	data_buffer_full;
wire	hdr_en;
//-------------寄存data, hdr-------------
always @(posedge clk)
begin
	if(!rst_n)
	begin
		hdr_valid_r1 <= 1'b0;
		hdr_r1       <= 'b0;
		hdr_keep_r1  <= 'b0;
		hdr_buffer_full <= 1'b0;	
	end
	else if(ready_insert & valid_insert) //hdr_ready 且 valid 时寄存axi_hdr的相关信号
	begin
		hdr_keep_r1  <= keep_insert;
		hdr_valid_r1 <= valid_insert;
		hdr_r1 		 <= data_insert;
		byte_insert_cnt_r1 <= byte_insert_cnt;
	end
end

always @(posedge clk)
begin
	if(!rst_n)
		hdr_buffer_full =1'b0;
	else if(ready_insert & valid_insert)
		hdr_buffer_full =1'b1;
	else if (valid_out & last_out & ready_out)
		hdr_buffer_full =1'b0;
end

always @(posedge clk)
begin
	if(!rst_n)
		data_buffer_full =1'b0;
	if(ready_insert & valid_insert)
		data_buffer_full =1'b1;
	else if (valid_out & last_out & ready_out)
		data_buffer_full =1'b0;
end

//----------------------
always @(posedge clk)
begin
	if(!rst_n)
	begin
		data_valid_r1 <= 1'b0;
		data_r1       <= 'b0;
		data_keep_r1  <= 'b0;	
		data_last_r1  <= 'b0;
		data_last_r2  <= 'b0;
	end
	else if(ready_in) //data_ready 且 valid 时寄存axi_hdr的相关信号
	begin
		data_valid_r1 <= valid_in;
		data_valid_r2 <= data_valid_r1;
		data_r1 	  <= data_in;
		data_keep_r1  <= keep_in;
		data_last_r1  <= last_in;
		data_last_r2  <= data_last_r1;
	end 	
	else
	begin
		data_valid_r1 <= 1'b0;
		data_r1       <= 'b0;
		data_keep_r1  <= 'b0;	
		data_last_r1  <= 'b0;
		data_last_r2  <= 'b0;
	
	end
end

assign hdr_en = (!data_valid_r2 &&data_valid_r1); //表示在这个周期内，hdr被发走
//----------------------------------
wire  [DATA_WD-1 : 0] shift_cnt;
assign shift_cnt = 8*(DATA_BYTE_WD - byte_insert_cnt_r1);

always @(*)
begin
	if(!rst_n)
	begin
		temp_data = 'b0;
	    temp_keep = 'b0;
	end
	
	else if (data_valid_r1 & hdr_en) //data来到，将hdr与data拼接
	begin
		temp_data [2*DATA_WD-1 : DATA_WD ] = hdr_r1 ;
		temp_keep [2*DATA_BYTE_WD-1 : DATA_BYTE_WD]= hdr_keep_r1  ;
		temp_data [DATA_WD-1 : 0 ]  = data_r1;
	    temp_keep [DATA_BYTE_WD-1 : 0] = data_keep_r1;
		temp_data = temp_data << shift_cnt;
		temp_keep = temp_keep << (DATA_BYTE_WD - byte_insert_cnt_r1);
	end
	
	else if (data_valid_r1 & (!hdr_en)) //hdr已发送，data顺次移位
	begin

		temp_data = temp_data << DATA_WD;
		temp_keep = temp_keep << DATA_BYTE_WD;
		temp_data [2*DATA_WD-1 : DATA_WD ] = temp_data [2*DATA_WD-1 : DATA_WD ] >> shift_cnt;
		temp_keep [2*DATA_BYTE_WD-1 : DATA_BYTE_WD]= temp_keep [2*DATA_BYTE_WD-1 : DATA_BYTE_WD] >> (DATA_BYTE_WD - byte_insert_cnt_r1) ;
		temp_data [DATA_WD-1 : 0 ] = data_r1 ;
		temp_keep [DATA_BYTE_WD-1 : 0]= data_keep_r1  ;
		temp_data = temp_data << shift_cnt;
		temp_keep = temp_keep << (DATA_BYTE_WD - byte_insert_cnt_r1);
	end
	else if (last_out)
	begin
		temp_data =  'b0;
		temp_keep =  'b0;
	end
	else 
	begin
		temp_data =  temp_data << DATA_WD ;
		temp_keep =  temp_keep << DATA_BYTE_WD;
	end
end 

//--------------------------------------------
assign 	last_flag = (data_last_r1 | data_last_r2) &(~(|temp_keep[DATA_BYTE_WD-1 :0]))&(|temp_keep[2*DATA_BYTE_WD-1 :DATA_BYTE_WD]);
reg	 	last_flag_r1;
wire   	last_trans;
reg	   	last_trans_r1;

always  @(posedge clk)
begin
	last_flag_r1 <= last_flag;
	last_trans_r1 <= last_trans;
	data_out <= temp_data[2*DATA_WD-1 : DATA_WD ];
	keep_out <= temp_keep[2*DATA_BYTE_WD-1 :DATA_BYTE_WD];
end

assign last_trans = ((!last_flag_r1) & last_flag);
assign last_out   = last_trans_r1;
assign valid_out  = |keep_out;

//hdr中有数据时，才开始接受data，避免超大data的缓存
assign ready_in = hdr_buffer_full;
//hdr为空时，开始接受hdr，也就是一次传输完成后
assign ready_insert = !data_buffer_full| (valid_out & last_out & ready_out);

endmodule

