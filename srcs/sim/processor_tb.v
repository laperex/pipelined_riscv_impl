`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2024 09:10:40 AM
// Design Name: 
// Module Name: interface_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module processor_tb;
	reg clk = 0;
	reg reset = 1;
	
	always #0.5 clk = ~clk;

	initial #5 reset = 0;


	wire btnC;
	wire RsTx;


	wire [15: 0] led;


	assign btnC = reset;
	
	interface u_interface (
		.clk     (clk),
		.btnC    (btnC),
		.led     (led)
	);
endmodule
