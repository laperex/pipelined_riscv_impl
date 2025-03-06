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


module MEMORY #(
	parameter WIDTH = 8,
	parameter SIZE = 256,
	parameter INITFILE = "",
	parameter DUMPFILE = ""
) (
	input wr_clk,
	input rd_clk,
	input reset,
	input halt,
	
    input [4: 0] i_rd_sel,
    output reg [4: 0] o_rd_sel,

	input wr_en,
	input [2: 0] wr_size,
	input [$clog2(SIZE - 1) - 1: 0] wr_addr,
	input [WIDTH - 1: 0] wr_data,

	input rd_en,
	input [2: 0] rd_size,
	input [$clog2(SIZE - 1) - 1: 0] rd_addr,
	output reg [WIDTH - 1: 0] rd_data,

	input fe_rd_en,
	input [$clog2(SIZE - 1) - 1: 0] fe_rd_addr,
	output reg [WIDTH - 1: 0] fe_rd_data
);
	reg [7: 0] memory [0: SIZE - 1] = "";


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
			fe_rd_data <= 0;
			o_rd_sel <= 0;
			rd_data <= 0;
		end else if (halt == 0) begin
			if (fe_rd_en) begin
				fe_rd_data <= {
					memory[fe_rd_addr + 0],
					memory[fe_rd_addr + 1],
					memory[fe_rd_addr + 2],
					memory[fe_rd_addr + 3]
				};
			end
		end
	end

	always @(posedge wr_clk) begin
		if (wr_en && reset == 0 && halt == 0) begin
			if (wr_size >= 2) begin
				memory[wr_addr + 0] <= wr_data[31: 24];
				memory[wr_addr + 1] <= wr_data[23: 16];
			end
			if (wr_size >= 1) begin
				memory[wr_addr + 2] <= wr_data[15: 8];
			end
			if (wr_size >= 0) begin
				memory[wr_addr + 3] <= wr_data[7: 0];
			end
		end
	end

	always @(posedge rd_clk) begin
		if (rd_en && reset == 0 && halt == 0) begin
			if (rd_size >= 2) begin
				rd_data[31: 24] <= memory[rd_addr + 0];
				rd_data[23: 16] <= memory[rd_addr + 1];
			end
			if (rd_size >= 1) begin
				rd_data[15: 8] <= memory[rd_addr + 2];
			end
			if (rd_size >= 0) begin
				rd_data[7: 0] <= memory[rd_addr + 3];
			end
		end

		o_rd_sel <= rd_en ? i_rd_sel: 0;
	end
endmodule
