`timescale 		1ns/1ns

module main_tb(
    );
parameter DATA_WD = 32;
parameter DATA_BYTE_WD = DATA_WD / 8 ;
parameter BYTE_CNT_WD = $clog2(DATA_BYTE_WD);

reg	clk		= 'd0;
reg	rst_n	= 'd0;
// AXI Stream reg header
reg                        valid_insert;
reg   [DATA_WD-1 : 0]      data_insert;
reg   [DATA_BYTE_WD-1 : 0] keep_insert;
wire                       ready_insert;
reg   [BYTE_CNT_WD-1 : 0]  byte_insert_cnt; //keep insert内有多少个1
reg                        valid_in;
reg   [DATA_WD-1 : 0]      data_in;
reg   [DATA_BYTE_WD-1 : 0] keep_in;
reg                        last_in;
wire                       ready_in;
wire                       valid_out;
wire  [DATA_WD-1 : 0]      data_out;
wire  [DATA_BYTE_WD-1 : 0] keep_out;
wire                       last_out;
reg                        ready_out;
//---------task 1:hdr axi -------------------
task 	hdr_axi_slave;
reg	[BYTE_CNT_WD-1:0] hdr_cnt;
	begin
		valid_insert =1'b1;
		data_insert = $random;
		hdr_cnt =$urandom_range(0, DATA_BYTE_WD);
		keep_insert = 4'hf >> hdr_cnt;
		byte_insert_cnt = DATA_BYTE_WD - hdr_cnt;
	end
endtask
//-----------task 2 :data axi -----------------
task data_axi;
	begin
		valid_in =1'b1;
		data_in = $random;
		keep_in = 4'hf;
		last_in =1'b0;
	end
endtask
//----------task 3 : data axi last-------------
task data_axi_last;
	reg	[DATA_BYTE_WD-1:0]last_cnt;
	begin
		valid_in =1'b1;
		last_in = 1'b1;
		data_in = $random;
		last_cnt = $urandom_range(0, DATA_BYTE_WD);
		keep_in = 4'hf << last_cnt;
		@(posedge clk)
		valid_in =1'b0;
		last_in = 1'b0;
	end
endtask
//----------task 4 : data axi interrupt-------------
task data_axi_intp;
	begin
		valid_in =1'b0;
		last_in = 1'b0;
		data_in = $random;
		keep_in = $random;
	end
endtask

//-----------task case------------------------------
//-----------task testcase : test1 hdr/data ------------------------------
task test1;
	begin
		data_axi;
		hdr_axi_slave;
		@(posedge clk)
		valid_insert =1'b0;
		repeat (5)
		begin
			data_axi;
			@(posedge clk);
		end
			data_axi_last;
	end
endtask
//-----------task testcase : test2 hdr IDLE data--------------------------------
task test2;
	begin
		hdr_axi_slave;
		@(posedge clk)
		hdr_axi_slave;
		@(posedge clk)
		hdr_axi_slave;
		@(posedge clk)
		valid_insert =1'b0;
		repeat (5)
		begin
			data_axi;
			@(posedge clk);
		end
			data_axi_last;
	end
endtask
//-----------task testcase : test3 data hdr--------------------------------
task test3;
	begin
		repeat (5)
		begin
			data_axi;
			@(posedge clk);
		end
		hdr_axi_slave;
		@(posedge clk);
		hdr_axi_slave;
		@(posedge clk)
		repeat (8)
		begin
			data_axi;
			@(posedge clk);
		end
		data_axi_last;
	end
endtask

//-----------initial block -----------
initial 
begin
	clk		= 'd0;
	rst_n	= 'd0;
	ready_out =1'b1;
	#12 rst_n = 'd1;
	test1;
	@(posedge clk);
	test2;
	@(posedge clk);
	test3;
end

always #10 clk = ~clk;
//---------DUT-------------------
axi2 axi_u0(
	.clk			( clk			),
	.rst_n			( rst_n			),
	.valid_in		( valid_in		),
	.data_in		( data_in		),
	.keep_in		( keep_in		),
	.last_in		( last_in		),
	.ready_in		( ready_in		),
	.valid_out		( valid_out		),
	.data_out		( data_out		),
	.keep_out		( keep_out		),
	.last_out		( last_out		),
	.ready_out		( ready_out		),
	.valid_insert	( valid_insert	),
	.data_insert	( data_insert	),
	.byte_insert_cnt(byte_insert_cnt),
	.keep_insert	( keep_insert	),
	.ready_insert	( ready_insert	)
);
endmodule