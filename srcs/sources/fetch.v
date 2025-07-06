`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2025 08:04:15 PM
// Design Name: 
// Module Name: fetch
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


module FETCH #(
    parameter WIDTH = 32
) (
    input clk,
    input reset,
    input halt,
	
	input restore_pc,

	input [WIDTH - 1: 0] load_pc_A,
	input [WIDTH - 1: 0] load_pc_B,

	output reg [WIDTH - 1: 0] pc_out
);
	reg [WIDTH - 1: 0] pc_prev;

    always @(posedge clk) begin
        if (reset) begin
            pc_out <= 0;
			pc_prev <= pc_prev;
        end else if (halt == 0) begin
			if (restore_pc) begin
				pc_out <= pc_prev;
			end else begin
				pc_out <= load_pc_A + load_pc_B;
				pc_prev <= pc_out;
			end
		end
    end
endmodule

// module FETCH #(
//     parameter WIDTH = 32
// ) (
//     input clk,
//     input reset,
//     input halt,

// 	input [WIDTH - 1: 0] load_pc_A,
// 	input [WIDTH - 1: 0] load_pc_B,

// 	output reg [WIDTH - 1: 0] pc_out
// );

//     always @(posedge clk) begin
//         if (reset) begin
//             pc_out <= 0;
//         end else if (halt == 0) begin
// 			pc_out <= load_pc_A + load_pc_B;
// 		end
//     end
// endmodule