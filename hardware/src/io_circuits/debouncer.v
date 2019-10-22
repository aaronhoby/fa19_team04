module debouncer #(
    parameter width = 1,
    parameter sample_count_max = 25000,
    parameter pulse_count_max = 150,
    parameter wrapping_counter_width = $clog2(sample_count_max),
    parameter saturating_counter_width = $clog2(pulse_count_max))
(
    input clk,
    input [width-1:0] glitchy_signal,
    output [width-1:0] debounced_signal
);
    // Create your debouncer circuit
    // The debouncer takes in a bus of 1-bit synchronized, but glitchy signals
    // and should output a bus of 1-bit signals that hold high when their respective counter saturates
	reg [wrapping_counter_width-1:0] sample_counter = 0; 
	reg sample_pulse = 0;
	
	always @ (posedge clk) begin
		sample_pulse <= 0;
		if (sample_counter < sample_count_max)
			sample_counter <= sample_counter + 1;
		else begin
			sample_counter <= 0;
			sample_pulse <= 1;
		end
	end

	reg [saturating_counter_width-1:0] pulse_counter [width-1:0];

	integer k;
	initial begin
		for (k = 0; k < width; k = k + 1) begin
			pulse_counter[k] = 0;
		end
	end

	genvar i;
	generate
		for (i = 0; i < width; i = i + 1) begin: counter_loop
			always @ (posedge clk) begin
				pulse_counter[i] <= pulse_counter[i];
				if (sample_pulse) begin
					if (glitchy_signal[i] && pulse_counter[i] < pulse_count_max)
						pulse_counter[i] <= pulse_counter[i] + 1;
					else if (!glitchy_signal[i])
						pulse_counter[i] <= 0;
				end
			end
			assign debounced_signal[i] = (pulse_counter[i] == pulse_count_max);
		end
	endgenerate
endmodule
