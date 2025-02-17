`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2025 06:01:20 PM
// Design Name: 
// Module Name: processor
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


module program_counter #(
	WIDTH = 32
) (
	input clk,
	input reset,

	input pc_in_en,
	input [WIDTH - 1: 0] pc_in_val,

	input pc_increment_en,

	output reg [WIDTH - 1: 0] pc_out_val,
	output [WIDTH - 1: 0] pc_out_val_next
);
	always @(posedge clk) begin
		if (reset) begin
			pc_out_val <= 0;
		end else begin
			if (pc_in_en) begin
				pc_out_val <= pc_in_val;
			end

			if (pc_increment_en) begin
				pc_out_val <= pc_out_val + 4;
			end
		end
	end

	assign pc_out_val_next = pc_out_val + 4;
endmodule


module alu #(
	WIDTH = 32
) (
	input clk,
	input reset,

	input [WIDTH - 1: 0] A_in,
	input [WIDTH - 1: 0] B_in,

	input [4: 0] shift_amt,

	output [WIDTH - 1: 0] E_out
);
endmodule


module register_bank();
	
endmodule


module fetch_unit();
	
endmodule


module control_unit();
	
endmodule


module processor();
	
endmodule
