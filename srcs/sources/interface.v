`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/09/2025 12:56:22 PM
// Design Name: 
// Module Name: interface
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


module interface(
	input clk,
	input btnC,
	
	output [15: 0] led
);
	
	wire [31: 0] PORT_OUT_A;
	wire [31: 0] PORT_OUT_B;
	wire [31: 0] PORT_OUT_C;
	wire [31: 0] PORT_OUT_D;
	
	assign led = PORT_OUT_A[15: 0];

	processor #(
		.WIDTH      (32),
        .INITFILE	("/home/laperex/Programming/FPGA/pipelined_riscv/srcs/sources/rom.txt"),
        .DUMPFILE	("")
	) u_processor (
		.clk           (clk),
		.reset         (btnC),

		// input [WIDTH - 1: 0] PORT_IN_A,
		// input [WIDTH - 1: 0] PORT_IN_B,
		// input [WIDTH - 1: 0] PORT_IN_C,
		// input [WIDTH - 1: 0] PORT_IN_D,

		.PORT_OUT_A    (PORT_OUT_A),
		.PORT_OUT_B    (PORT_OUT_B),
		.PORT_OUT_C    (PORT_OUT_C),
		.PORT_OUT_D    (PORT_OUT_D)
	);
endmodule
