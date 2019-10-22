`timescale 1ns/10ps

module reg_file_testbench();
	parameter CPU_CLOCK_PERIOD = 20;
	//parameter CPU_CLOCK_FREQ = 50_000_000;

	reg clk;
	initial clk = 0;
	always #(CPU_CLOCK_PERIOD / 2) clk <= ~clk;

	reg we;
	reg [4:0] ra1, ra2, wa;
	reg [31:0] wd;
	wire [31:0] rd1, rd2;
	reg_file dut (
		.clk(clk),
		.we(we),
		.ra1(ra1),
		.ra2(ra2),
		.wa(wa),
		.wd(wd),
		.rd1(rd1),
		.rd2(rd2)
	);
	
	reg done = 0;
	initial begin
		$vcdpluson;
		// Test writing to Reg 0
		wa = 5'd0;
		wd = 32'hffff_ffff;
		we = 1'b1;
		@(posedge clk);
		we = 1'b0;
		ra1 = 5'd0;
		#1;
		if (rd1 != 32'd0) begin
			$display("FAIL Test 1 - Reg 0 has value %d instead of 0x0000_0000", rd1);
			$finish();
		end

		// Test writing and reading in same cycle
		wa = 5'd1;
		wd = 32'hffff_ffff;
		we = 1'b1;
		@(posedge clk);
		we = 1'b0;
		ra1 = 5'd1;
		#1;
		if (rd1 != 32'hffff_ffff) begin
			$display("FAIL Test 2 - Reg 1 has value %d instead of 0xffff_ffff", rd1);
			$finish();
		end
		
		// Test write enable functionality
		wa = 5'd2;
		wd = 32'hffff_ffff;
		we = 1'b0;
		ra1 = 5'd2;
		#1;
		if (rd1 != 32'bx) begin
			$display("FAIL Test 3 - Reg 2 has value %d instead of 0xxxx_xxxx", rd1);
			$finish();
		end

		// Test asynchronous reads
		ra1 = 5'd0;
		#1;
		if (rd1 != 32'd0) begin
			$display("FAIL Test 4 - Reg 0 has value %d instead of 0x0000_0000", rd1);
			$finish();
		end
		$display("PASS");
		$vcdplusoff;
		$finish();
	end
endmodule
