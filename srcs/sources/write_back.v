
module WRITE_BACK #(parameter WIDTH = 32) (
	input clk,
	input reset,
	input halt,

	input [4: 0] rd_ex_sel,
	input [4: 0] rd_mem_sel,

	input [4: 0] rs1_sel,
	input [4: 0] rs2_sel,

	input [WIDTH - 1: 0] rd_ex,
	input [WIDTH - 1: 0] rd_mem,

	output [WIDTH - 1: 0] rs1,
	output [WIDTH - 1: 0] rs2
);
	reg [WIDTH - 1: 0] reg_x[WIDTH - 1: 0];

	assign rs1 = rs1_sel > 0 &&
		rd_ex_sel == rs1_sel ?
			rd_ex:
		rd_mem_sel == rs1_sel ?
			rd_mem:
		reg_x[rs1_sel];

	assign rs2 = rs2_sel > 0 &&
		rd_ex_sel == rs2_sel ?
			rd_ex:
		rd_mem_sel == rs2_sel ?
			rd_mem:
		reg_x[rs2_sel];

	wire [WIDTH - 1: 0] zero	= reg_x[0];

	wire [WIDTH - 1: 0] ra		= reg_x[1];
	wire [WIDTH - 1: 0] sp		= reg_x[2];
	wire [WIDTH - 1: 0] gp		= reg_x[3];
	wire [WIDTH - 1: 0] tp		= reg_x[4];
	wire [WIDTH - 1: 0] fp		= reg_x[8];
	
	wire [WIDTH - 1: 0] a0		= reg_x[10];
	wire [WIDTH - 1: 0] a1		= reg_x[11];
	wire [WIDTH - 1: 0] a2		= reg_x[12];
	wire [WIDTH - 1: 0] a3		= reg_x[13];
	wire [WIDTH - 1: 0] a4		= reg_x[14];
	wire [WIDTH - 1: 0] a5		= reg_x[15];
	wire [WIDTH - 1: 0] a6		= reg_x[16];
	wire [WIDTH - 1: 0] a7		= reg_x[17];

	wire [WIDTH - 1: 0] s0		= reg_x[8];
	wire [WIDTH - 1: 0] s1		= reg_x[9];
	wire [WIDTH - 1: 0] s2		= reg_x[18];
	wire [WIDTH - 1: 0] s3		= reg_x[19];
	wire [WIDTH - 1: 0] s4		= reg_x[20];
	wire [WIDTH - 1: 0] s5		= reg_x[21];
	wire [WIDTH - 1: 0] s6		= reg_x[22];
	wire [WIDTH - 1: 0] s7		= reg_x[23];
	wire [WIDTH - 1: 0] s8		= reg_x[24];
	wire [WIDTH - 1: 0] s9		= reg_x[25];
	wire [WIDTH - 1: 0] s10		= reg_x[26];
	wire [WIDTH - 1: 0] s11		= reg_x[27];

	wire [WIDTH - 1: 0] t0		= reg_x[5];
	wire [WIDTH - 1: 0] t1		= reg_x[6];
	wire [WIDTH - 1: 0] t2		= reg_x[7];
	wire [WIDTH - 1: 0] t3		= reg_x[28];
	wire [WIDTH - 1: 0] t4		= reg_x[29];
	wire [WIDTH - 1: 0] t5		= reg_x[30];
	wire [WIDTH - 1: 0] t6		= reg_x[31];

	genvar i;
	for (i = 0; i < WIDTH; i = i + 1) begin
		always @(posedge clk) begin
			if (reset) begin
				reg_x[i] <= 0;
			end
		end
	end

	always @(posedge clk) begin
		if (reset == 0 && halt == 0) begin
			if (rd_ex_sel > 0) begin
				reg_x[rd_ex_sel] <= rd_ex;
			end
			if (rd_mem_sel > 0 && rd_ex_sel != rd_mem_sel) begin
				reg_x[rd_mem_sel] <= rd_mem;
			end
		end
	end
endmodule