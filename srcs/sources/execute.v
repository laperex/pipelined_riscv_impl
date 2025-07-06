


module EXECUTE #(
    parameter WIDTH = 32
) (
    input clk,
    input reset,
	input halt,

	input i_type,
	input j_type,
	input u_type,

    input [2: 0] funct3,
    input [7: 0] funct7,
    input [WIDTH - 1: 0] imm,

    input [WIDTH - 1: 0] rs1,
    input [WIDTH - 1: 0] rs2,
    output reg [WIDTH - 1: 0] rd,

    input [WIDTH - 1: 0] i_rd_sel,
    output reg [WIDTH - 1: 0] o_rd_sel,

	input [WIDTH - 1: 0] i_pc,
	output reg [WIDTH - 1: 0] o_pc,

	input sig_i_mem_wr_en,
	output reg sig_o_mem_wr_en,

	input sig_i_mem_rd_en,
	output reg sig_o_mem_rd_en,

	output reg [WIDTH - 1: 0] o_mem_wr_data,
	output reg [2: 0] o_mem_rw_size
);
    parameter f3_add         =  'h0;
    parameter f3_sub         =  'h0;
    parameter f3_xor         =  'h4;
    parameter f3_or          =  'h6;
    parameter f3_and         =  'h7;
    parameter f3_sll         =  'h1;
    parameter f3_srl         =  'h5;
    parameter f3_sra         =  'h5;
    parameter f3_slt         =  'h2;
    parameter f3_sltu        =  'h3;

	parameter f7_add         =  'h00;
	parameter f7_sub         =  'h20;
	parameter f7_xor         =  'h00;
	parameter f7_or          =  'h00;
	parameter f7_and         =  'h00;
	parameter f7_sll         =  'h00;
	parameter f7_srl         =  'h00;
	parameter f7_sra         =  'h20;
	parameter f7_slt         =  'h00;
	parameter f7_sltu        =  'h00;

	wire [WIDTH - 1: 0] A = 
		j_type == 1 ?
			i_pc:
		u_type && i_type ?
			o_pc:
		rs1;

	wire [WIDTH - 1: 0] B =
		j_type == 1 ?
			4:
		u_type || i_type || sig_i_mem_wr_en || sig_i_mem_rd_en ?
			imm:
		rs2;

	reg rst_0;
	reg rst_1;

	always @(posedge clk) begin
		rst_0 <= j_type;
		rst_1 <= rst_0;

		if (reset) begin
			o_pc <= 0;
		end else if (halt == 0) begin
			o_pc <= i_pc;
		end
		
		if (reset || rst_0 || rst_1) begin
			rd <= 0;

			o_rd_sel <= 0;

			sig_o_mem_wr_en <= 0;
			sig_o_mem_rd_en <= 0;

			o_mem_wr_data <= 0;
			o_mem_rw_size <= 0;
		end else if (halt == 0) begin
			rd	<=
				j_type ?
					B:
				sig_i_mem_wr_en || sig_i_mem_rd_en || (funct3 == f3_add && funct7 == f7_add) ? A + B:
				funct3 == f3_sub 	&& funct7 == f7_sub 	? A - B:
				funct3 == f3_xor 	&& funct7 == f7_xor 	? A ^ B:
				funct3 == f3_or 	&& funct7 == f7_or 		? A | B:
				funct3 == f3_and 	&& funct7 == f7_and 	? A & B:
				funct3 == f3_sll 	&& funct7 == f7_sll 	? A << B[4: 0]:
				funct3 == f3_srl 	&& funct7 == f7_srl 	? A >> B[4: 0]:
				funct3 == f3_sra 	&& funct7 == f7_sra 	? A >> B[4: 0]:
				funct3 == f3_slt 	&& funct7 == f7_slt 	? (A < B ? 1: 0):
				funct3 == f3_sltu 	&& funct7 == f7_sltu 	? (A < B ? 1: 0):
				0;

			o_rd_sel <= i_rd_sel;

			o_pc <= i_pc;

			sig_o_mem_wr_en <= sig_i_mem_wr_en;
			sig_o_mem_rd_en <= sig_i_mem_rd_en;

			o_mem_wr_data <= sig_i_mem_rd_en || sig_i_mem_wr_en ? rs2: 0;
			o_mem_rw_size <= sig_i_mem_rd_en || sig_i_mem_wr_en ? funct3:  0;
		end
	end
endmodule
