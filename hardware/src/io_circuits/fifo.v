module fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = $clog2(fifo_depth)
) (
    input clk, rst,

    // Write side
    input wr_en,
    input [data_width-1:0] din,
    output full,

    // Read side
    input rd_en,
    output reg [data_width-1:0] dout,
    output empty
	//output [5:0] wr_ptr_out,
	//output [5:0] rd_ptr_out
);
	reg [addr_width:0] wr_ptr, rd_ptr;
	reg [data_width-1:0] buffer [fifo_depth-1:0];
	//assign wtr_ptr_out = wr_ptr;
	//assign rd_ptr_out = rd_ptr;

	always @ (posedge clk) begin
		wr_ptr <= wr_ptr;
		if (rst)
			wr_ptr <= 0;
		else if (!full && wr_en)
			wr_ptr <= wr_ptr + 1;
	end

	always @ (posedge clk) begin
		rd_ptr <= rd_ptr;
		if (rst)
			rd_ptr <= 0;
		else if (!empty && rd_en)
			rd_ptr <= rd_ptr + 1;
	end

	always @ (posedge clk) begin
		buffer[wr_ptr] <= buffer[wr_ptr];
		dout <= buffer[rd_ptr];
		if (!full && wr_en)
			buffer[wr_ptr] <= din;
	end

	assign full = (wr_ptr[addr_width-1:0] == rd_ptr[addr_width-1:0]) && (wr_ptr[addr_width] != rd_ptr[addr_width]);
	assign empty = (wr_ptr == rd_ptr);
endmodule
