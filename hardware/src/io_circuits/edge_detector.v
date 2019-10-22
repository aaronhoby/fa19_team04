module edge_detector #(
    parameter width = 1
)(
    input clk,
    input [width-1:0] signal_in,
    output [width-1:0] edge_detect_pulse
);
    // The edge detector takes a bus of 1-bit signals and looks for a low to high (0 -> 1)
    // logic transition. It outputs a 1 clock cycle wide pulse if a transition is detected.
    // Remove this line once you have implemented this module.
	reg [width-1:0] prev_signal, curr_signal;
	
	genvar i;
	generate
		for (i = 0; i < width; i = i + 1) begin: edge_loop
			always @ (posedge clk) begin
				prev_signal[i] <= curr_signal[i];
				curr_signal[i] <= signal_in[i];
			end
			assign edge_detect_pulse[i] = !prev_signal[i] && curr_signal[i];
		end
	endgenerate
endmodule
