//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/16/2024 10:37:47 AM
// Design Name: 
// Module Name: memory
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


module memory #(
	parameter WIDTH = 8,
	parameter SIZE = 256,
	parameter INITFILE = "",
	parameter DUMPFILE = ""
) (
	input wr_clk,
	input rd_clk,
	input reset,

	input wr_en,
	input [$clog2(SIZE - 1) - 1: 0] wr_addr,
	input [WIDTH - 1: 0] wr_data,

	input rd_en,
	input [$clog2(SIZE - 1) - 1: 0] rd_addr,
	output reg [WIDTH - 1: 0] rd_data
);
	reg [WIDTH - 1: 0] memory [0: SIZE - 1];


	initial begin : initialisation
		integer i;

		for (i = 0; i < SIZE; i = i + 1) begin
			memory[i][WIDTH - 1: 0] = 0;
		end

		$readmemh(INITFILE, memory);
	end

	integer file_wr_en;

	always @* begin : sim_block
		if (reset) begin
			file_wr_en = 0;
		end else begin
			if (file_wr_en == 0) begin
				file_wr_en = wr_en;
			end else begin
				$writememh(DUMPFILE, memory);

				file_wr_en = 0;
			end
		end
	end


	always @(posedge rd_clk) begin
		if (reset) begin
			rd_data <= 0;
		end else begin
			if (rd_en) begin
				rd_data <= memory[rd_addr];
			end
		end
	end
	
	always @(posedge wr_clk) begin
		if (wr_en && reset == 0) begin
			memory[wr_addr] <= wr_data;
		end
	end
endmodule
