`default_nettype none
`define RATIO  4000000
module clockdivider(
	input logic clk,rst,
	output logic CLK
);
	int x,nx;
	
	always_ff @(posedge clk,posedge rst) begin
		if(rst) x <= 1;
		else x <= nx;
	end
	always_comb begin
		if( x == `RATIO ) nx = 1;
		else              nx = x + 1;
	end
	assign CLK = x == 1;
endmodule
