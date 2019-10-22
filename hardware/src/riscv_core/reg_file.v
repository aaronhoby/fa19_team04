module reg_file (
    input clk,
    input we,
    input [4:0] ra1, ra2, wa,
    input [31:0] wd,
    output [31:0] rd1, rd2
);
    reg [31:0] registers [0:31];

	always @ (posedge clk) begin
		registers[wa] <= we ? wd : registers[wa];
	end

	assign rd1 = (ra1 != 0) ? registers[ra1] : 32'd0;
	assign rd2 = (ra2 != 0) ? registers[ra2] : 32'd0;
endmodule
