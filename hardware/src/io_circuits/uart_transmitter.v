module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output reg data_in_ready,

    output reg serial_out
);
	reg curr_data_in_valid, prev_data_in_valid;
	reg curr_data_in_ready, prev_data_in_ready;
	reg transmitting, start_transmitting;
	always @ (posedge clk) begin
		curr_data_in_valid <= data_in_valid;
		prev_data_in_valid <= curr_data_in_valid;
		curr_data_in_ready <= data_in_ready;
		prev_data_in_ready <= curr_data_in_ready;
		transmitting <= transmitting;
		start_transmitting <= 1'b0;
		if (curr_data_in_valid && !prev_data_in_valid) begin
			transmitting <= 1'b1;
			start_transmitting <= 1'b1;
		end
		else if (curr_data_in_ready && !prev_data_in_ready)
			transmitting <= 1'b0;
	end

    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);
	reg [CLOCK_COUNTER_WIDTH-1:0] clk_counter;
	reg symbol_edge;
	always @ (posedge clk) begin
		symbol_edge <= 1'b0;
		if (reset || !transmitting)
			clk_counter <= 0;
		else if (clk_counter < SYMBOL_EDGE_TIME)
			clk_counter <= clk_counter + 1;
		else if (clk_counter == SYMBOL_EDGE_TIME) begin
			clk_counter <= 0;
			symbol_edge <= 1'b1;
		end
	end	

	reg [3:0] curr_data;
	reg [7:0] data_in_copy;
	always @ (posedge clk) begin
		data_in_ready <= data_in_ready;
		serial_out <= serial_out;
		curr_data <= curr_data;
		data_in_copy <= data_in_copy;
		if (reset || !transmitting) begin
			data_in_ready <= 1'b1;
			serial_out <= 1'b1;
			curr_data <= 4'b0;
			data_in_copy <= 8'd0;
		end
		else  if (start_transmitting) begin
			data_in_ready <= 1'b0;
			data_in_copy <= data_in;
		end
		else if (transmitting && symbol_edge) begin
			if (curr_data == 4'd0) begin
				serial_out <= 1'b0;
				curr_data <= curr_data + 1;
			end
			else if (curr_data < 4'd9) begin
				serial_out <= data_in_copy[curr_data - 1];
				curr_data <= curr_data + 1;
			end
			else if (curr_data == 4'd9) begin
				data_in_ready <= 1'b1;
				serial_out <= 1'b1;
				curr_data <= 4'd0;
			end
		end
	end
endmodule
