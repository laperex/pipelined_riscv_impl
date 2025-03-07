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


module FETCH #(
    WIDTH = 32
) (
    input clk,
    input reset,
    input halt,

	input [WIDTH - 1: 0] ld_pc,
	input [1: 0] sig_ld_pc_type,

	output reg [WIDTH - 1: 0] pc_current,
	output [WIDTH - 1: 0] pc_next
);
	localparam LD_PC_DISABLE = 0;
	localparam LD_PC_PLUSEQ = 1;
	localparam LD_PC_REPLACE = 2;
	localparam LD_PC_INCREMENT = 3;

	wire [WIDTH - 1: 0] pc_inc_val =
		sig_ld_pc_type == LD_PC_INCREMENT ? 4:
		sig_ld_pc_type == LD_PC_PLUSEQ ? ld_pc:
		sig_ld_pc_type == LD_PC_REPLACE ? ld_pc:
		0;

    // assign pc_current =
    assign pc_next =
		sig_ld_pc_type == LD_PC_REPLACE ? pc_inc_val:
		pc_current + pc_inc_val;

    always @(posedge clk) begin
        if (reset) begin
            pc_current <= 0;
        end else if (halt == 0) begin
			pc_current <= pc_next;
		end
    end
endmodule


module DECODE #(
    WIDTH = 32
) (
    input clk,
    input reset,
	input halt,

    input [WIDTH - 1: 0] instr_raw,

    output reg [WIDTH - 1: 0] imm,
    output reg [2: 0] funct3,
    output reg [7: 0] funct7,
    output reg [4: 0] rs1_sel,
    output reg [4: 0] rs2_sel,
    output reg [4: 0] rd_sel,

    output reg i_type,
    output reg j_type,

    input i_pc,
    input i_pc_next,

    output reg o_pc,
    output reg o_pc_next,

	output reg sig_mem_rd_en,
	output reg sig_mem_wr_en
);
	wire [WIDTH - 1: 0] instr;// = { instr_raw[31: 24], instr_raw[23: 16], instr_raw[15: 8], instr_raw[7: 0] };

	// convert MSB order to LSB order
	genvar i;
	for (i = 0; i < WIDTH / 8; i = i + 1) begin
		assign instr[(8 * (i + 1)) - 1: 8 * i] = instr_raw[WIDTH - (8 * i) - 1: WIDTH - (8 * (i + 1))];
	end

    // -> Integer Register-Immediate Instructions
    // ---> I-Type
    parameter op_imm         =  'b0010011;

    parameter f3_addi        =  'h0;  // ADD Immediate
    parameter f3_xori        =  'h4;  // XOR Immediate
    parameter f3_ori         =  'h6;  // OR Impc_currentmediate
    parameter f3_andi        =  'h7;  // AND Immediate
    parameter f3_slli        =  'h1;
    parameter imm_slli_11_5  =  'h00;  // Shift Left Logical Imm
    parameter f3_srli        =  'h5;
    parameter imm_srli_11_5  =  'h00;  // Shift Right Logical Imm
    parameter f3_srai        =  'h5;
    parameter imm_srai_11_5  =  'h20;  // Shift Right Arith Imm
    parameter f3_slti        =  'h2;  // Set Less Than Imm
    parameter f3_sltiu       =  'h3;  // Set Less Than Imm (U)


    // ---> U-Type
    parameter op_lui         =  'b0110111;
    parameter op_auipc       =  'b0010111;


    // -> Integer Register-Register Operations
    // ---> R - Type

    parameter op_reg         =  'b0110011;

    parameter f3_add         =  'h0;
    parameter f7_add         =  'h00;  //ADD
    parameter f3_sub         =  'h0;
    parameter f7_sub         =  'h20;  //SUB
    parameter f3_xor         =  'h4;
    parameter f7_xor         =  'h00;  //XOR
    parameter f3_or          =  'h6;
    parameter f7_or          =  'h00;  //OR
    parameter f3_and         =  'h7;
    parameter f7_and         =  'h00;  //AND
    parameter f3_sll         =  'h1;
    parameter f7_sll         =  'h00;  //Shift Left Logical
    parameter f3_srl         =  'h5;
    parameter f7_srl         =  'h00;  //Shift Right Logical
    parameter f3_sra         =  'h5;
    parameter f7_sra         =  'h20;  //Shift Right Arith*
    parameter f3_slt         =  'h2;
    parameter f7_slt         =  'h00;  //Set Less Than
    parameter f3_sltu        =  'h3;
    parameter f7_sltu        =  'h00;  //Set Less Than (U)

    // -> Unconditional Jumps
    // ---> J-type
    parameter op_jal         =  'b1101111;  // offset[20: 1]

    // ---> I-type
    parameter op_jalr        =  'b1100111;  // offset [11: 0]
    parameter f3_jalr        =  'h0;

    // -> Conditional Branches
    // B-Type
    parameter op_branch      =  'b1100011;
    parameter f3_beq         =  'h0;  // Branch ==
    parameter f3_bne         =  'h1;  // Branch !=
    parameter f3_blt         =  'h4;  // Branch <
    parameter f3_bge         =  'h5;  // Branch ≥
    parameter f3_bltu        =  'h6;  // Branch < (U)
    parameter f3_bgeu        =  'h7;  // Branch ≥ (U)

    // -> Load and Store Instructions
    // S-Type
    parameter op_load        =  'b0000011;
    parameter f3_lb          =  'h0;  // Load Byte
    parameter f3_lh          =  'h1;  // Load Half
    parameter f3_lw          =  'h2;  // Load Word
    parameter f3_lbu         =  'h4;  // Load Byte (U)
    parameter f3_lhu         =  'h5;  // Load Half (U)

    parameter op_store       =  'b0100011;
    parameter f3_sb          =  'h0;  // Store Byte
    parameter f3_sh          =  'h1;  // Store Half
    parameter f3_sw          =  'h2;  // Store Word

    // -> Environment Instructions
    parameter op_env         =  'b1110011;

    parameter f3_ecall       =  'h0;
    parameter imm_ecall      =  'h0;
    parameter f3_ebreak      =  'h0;
    parameter imm_ebreak     =  'h1;

    wire [6: 0] opcode = instr[6: 0];

    always @(posedge clk) begin
		if (reset) begin
			rs1_sel <= 0;
			rs2_sel <= 0;
			imm <= 0;
			rd_sel <= 0;

			funct3 <= 0;
			funct7 <= 0;

			i_type <= 0;
			j_type <= 0;

			sig_mem_rd_en <= 0;
			sig_mem_wr_en <= 0;

			o_pc <= 0;
			o_pc_next <= 0;
        end else if (halt == 0) begin
			rd_sel  <= instr[11: 7];

			funct3  <= instr[14: 12];

			sig_mem_rd_en <= opcode == op_load;
			sig_mem_wr_en <= opcode == op_store;

			i_type <= opcode[5] == 0;
			j_type <= opcode == op_jal || opcode == op_jalr;

			o_pc <= i_pc;
			o_pc_next <= i_pc_next;

			if (opcode == op_load || opcode == op_imm || opcode == op_jalr) begin
				// I-Type
				imm[31: 11] <= {21{instr[31]}};
				imm[10: 5] <= instr[30: 25];
				imm[4: 1] <= instr[24: 21];
				imm[0] <= instr[20];

				rs1_sel <= instr[19: 15];
				rs2_sel <= 0;
				funct7 <= 0;
			end else if (opcode == op_store) begin
				// S-Type
				imm[31: 11] <= {21{instr[31]}};
				imm[10: 5] <= instr[30: 25];
				imm[4: 1] <= instr[11: 8];
				imm[0] <= instr[7];

				rs1_sel <= instr[19: 15];
				rs2_sel <= instr[24: 20];
				funct7 <= 0;
			end else if (opcode == op_branch) begin
				// B-Type
				imm[31: 12] <= {20{instr[31]}};
				imm[11] <= instr[7];
				imm[10: 5] <= instr[30: 25];
				imm[4: 1] <= instr[11: 8];
				imm[0] <= 0;

				rs1_sel <= instr[19: 15];
				rs2_sel <= 0;
				funct7 <= 0;
			end else if (opcode == op_jal) begin
				// J-Type
				imm[31: 20] <= {12{instr[31]}};
				imm[19: 12] <= instr[19: 12];
				imm[11] <= instr[20];
				imm[10: 5] <= instr[30: 25];
				imm[4: 1] <= instr[24: 21];
				imm[0] <= 0;

				rs1_sel <= 0;
				rs2_sel <= 0;
				funct7 <= 0;
			end else if (opcode == op_auipc || opcode == op_lui) begin
				// U-Type
				imm[31] <= instr[31];
				imm[30: 20] <= instr[30: 20];
				imm[19: 12] <= instr[19: 12];
				imm[11: 0] <= 0;

				rs1_sel <= 0;
				rs2_sel <= 0;
				funct7 <= 0;
			end else begin
				rs1_sel <= instr[19: 15];
				rs2_sel <= instr[24: 20];
				funct7 <= instr[31: 25];
			end
		end
    end
endmodule


module EXECUTE #(
    WIDTH = 32
) (
    input clk,
    input reset,
	input halt,

	input i_type,
	input j_type,

    input [2: 0] funct3,
    input [7: 0] funct7,
    input [WIDTH - 1: 0] imm,

    input [WIDTH - 1: 0] rs1,
    input [WIDTH - 1: 0] rs2,
    output reg [WIDTH - 1: 0] rd,

    input [WIDTH - 1: 0] i_rd_sel,
    output reg [WIDTH - 1: 0] o_rd_sel,

	input [WIDTH - 1: 0] i_pc,
	input [WIDTH - 1: 0] i_pc_next,
	output reg [WIDTH - 1: 0] o_pc,
	output reg [WIDTH - 1: 0] o_pc_next,

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

	wire [WIDTH - 1: 0] B = i_type || sig_i_mem_wr_en || sig_i_mem_rd_en ? imm: rs2;

	always @(posedge clk) begin
		if (reset) begin
			rd <= 0;

			o_rd_sel <= 0;

			sig_o_mem_wr_en <= 0;
			sig_o_mem_rd_en <= 0;

			o_mem_wr_data <= 0;
			o_mem_rw_size <= 0;

			o_pc <= 0;
			o_pc_next <= 0;
		end else if (halt == 0) begin
			rd	<=
				(funct3 == f3_add 	&& funct7 == f7_add)
					|| sig_i_mem_wr_en || sig_i_mem_rd_en	? rs1 + B:
				funct3 == f3_sub 	&& funct7 == f7_sub 	? rs1 - B:
				funct3 == f3_xor 	&& funct7 == f7_xor 	? rs1 ^ B:
				funct3 == f3_or 	&& funct7 == f7_or 		? rs1 | B:
				funct3 == f3_and 	&& funct7 == f7_and 	? rs1 & B:
				funct3 == f3_sll 	&& funct7 == f7_sll 	? rs1 << B[4: 0]:
				funct3 == f3_srl 	&& funct7 == f7_srl 	? rs1 >> B[4: 0]:
				funct3 == f3_sra 	&& funct7 == f7_sra 	? rs1 >> B[4: 0]:
				funct3 == f3_slt 	&& funct7 == f7_slt 	? (rs1 < B ? 1: 0):
				funct3 == f3_sltu 	&& funct7 == f7_sltu 	? (rs1 < B ? 1: 0):
				0;

			o_rd_sel <= i_rd_sel;

			o_pc <= i_pc;
			o_pc_next <= o_pc_next;

			sig_o_mem_wr_en <= sig_i_mem_wr_en;
			sig_o_mem_rd_en <= sig_i_mem_rd_en;

			o_mem_wr_data <= sig_i_mem_rd_en || sig_i_mem_wr_en ? rs2: 0;
			o_mem_rw_size <= sig_i_mem_rd_en || sig_i_mem_wr_en ? funct3:  0;
		end
	end
endmodule


module WRITE_BACK #(WIDTH = 32) (
	input clk,
	input reset,
	input halt,

	input [4: 0] rd_sel,
	input [4: 0] rs1_sel,
	input [4: 0] rs2_sel,

	input [WIDTH - 1: 0] rd,
	output [WIDTH - 1: 0] rs1,
	output [WIDTH - 1: 0] rs2
);
	reg [WIDTH - 1: 0] reg_x[WIDTH - 1: 0];

	assign rs1 = rd_sel > 0 && rd_sel == rs1_sel ? rd: reg_x[rs1_sel];
	assign rs2 = rd_sel > 0 && rd_sel == rs2_sel ? rd: reg_x[rs2_sel];

	wire [WIDTH - 1: 0] zero	= reg_x[0];
	wire [WIDTH - 1: 0] ra		= reg_x[1];
	wire [WIDTH - 1: 0] sp		= reg_x[2];
	wire [WIDTH - 1: 0] gp		= reg_x[3];
	wire [WIDTH - 1: 0] tp		= reg_x[4];
	wire [WIDTH - 1: 0] t0		= reg_x[5];
	wire [WIDTH - 1: 0] t1		= reg_x[6];
	wire [WIDTH - 1: 0] t2		= reg_x[7];
	wire [WIDTH - 1: 0] s0		= reg_x[8];
	wire [WIDTH - 1: 0] fp		= reg_x[8];
	wire [WIDTH - 1: 0] s1		= reg_x[9];
	wire [WIDTH - 1: 0] a0		= reg_x[10];
	wire [WIDTH - 1: 0] a1		= reg_x[11];
	wire [WIDTH - 1: 0] a2		= reg_x[12];
	wire [WIDTH - 1: 0] a3		= reg_x[13];
	wire [WIDTH - 1: 0] a4		= reg_x[14];
	wire [WIDTH - 1: 0] a5		= reg_x[15];
	wire [WIDTH - 1: 0] a6		= reg_x[16];
	wire [WIDTH - 1: 0] a7		= reg_x[17];
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
			if (rd_sel > 0) begin
				reg_x[rd_sel] <= rd;
			end
		end
	end
endmodule


module processor #(
    WIDTH = 32
) (
    input clk,
    input reset

    // input [WIDTH - 1: 0] PORT_IN_A,
    // input [WIDTH - 1: 0] PORT_IN_B,
    // input [WIDTH - 1: 0] PORT_IN_C,
    // input [WIDTH - 1: 0] PORT_IN_D,

    // output [WIDTH - 1: 0] PORT_OUT_A,
    // output [WIDTH - 1: 0] PORT_OUT_B,
    // output [WIDTH - 1: 0] PORT_OUT_C,
    // output [WIDTH - 1: 0] PORT_OUT_D
);
	// FETCH
	localparam LD_PC_DISABLE = 0;
	localparam LD_PC_PLUSEQ = 1;
	localparam LD_PC_REPLACE = 2;
	localparam LD_PC_INCREMENT = 3;

	wire FE_halt;
	wire [1: 0] FE_sig_ld_pc_type;
	wire [WIDTH - 1: 0] FE_ld_pc;

	wire [WIDTH - 1: 0] FE_pc_current;
	wire [WIDTH - 1: 0] FE_pc_next;


	// FETCH MEMORY
	reg MEM_fe_rd_en = 1;
	wire [WIDTH - 1: 0] MEM_fe_rd_addr = FE_pc_current;
	wire [WIDTH - 1: 0] MEM_fe_rd_data;


	// DECODE
	wire DE_halt;
	wire DE_reset;
	wire [WIDTH - 1: 0] DE_instr = MEM_fe_rd_data;

	wire [WIDTH - 1: 0] DE_imm;
	wire [2: 0] DE_funct3;
	wire [7: 0] DE_funct7;

	wire [4: 0] DE_rs1_sel;
	wire [4: 0] DE_rs2_sel;
	wire [4: 0] DE_rd_sel;

	wire DE_i_type;
	wire DE_j_type;
	wire DE_sig_mem_rd_en;
	wire DE_sig_mem_wr_en;

	wire [WIDTH - 1: 0] DE_i_pc = FE_pc_current;
	wire [WIDTH - 1: 0] DE_i_pc_next = FE_pc_next;
	wire [WIDTH - 1: 0] DE_o_pc;
	wire [WIDTH - 1: 0] DE_o_pc_next;


	// EXECUTE
	wire EX_halt;
	wire EX_i_type				= DE_i_type;
	wire EX_j_type				= DE_j_type;
	wire [2: 0] EX_funct3		= DE_funct3;
	wire [7: 0] EX_funct7		= DE_funct7;
	wire [WIDTH - 1: 0] EX_imm	= DE_imm;
	wire [WIDTH - 1: 0] EX_rs1;
	wire [WIDTH - 1: 0] EX_rs2;

	wire [WIDTH - 1: 0] EX_rd;
	wire [4: 0] EX_i_rd_sel		= DE_rd_sel;
	wire [4: 0] EX_o_rd_sel;

	wire [WIDTH - 1: 0] EX_i_pc			= DE_o_pc;
	wire [WIDTH - 1: 0] EX_i_pc_next	= DE_o_pc_next;
	wire [WIDTH - 1: 0] EX_o_pc;
	wire [WIDTH - 1: 0] EX_o_pc_next;

	wire EX_sig_i_mem_wr_en		= DE_sig_mem_wr_en;
	wire EX_sig_o_mem_wr_en;
	wire EX_sig_i_mem_rd_en		= DE_sig_mem_rd_en;
	wire EX_sig_o_mem_rd_en;

	wire [WIDTH - 1: 0] EX_o_mem_wr_data;
	wire [2: 0] EX_o_mem_rw_size;


	// MEMORY
	reg MEM_halt = 0;
	wire [4: 0] MEM_i_rd_sel = EX_o_rd_sel;
	wire [4: 0] MEM_o_rd_sel;

	wire [4: 0] MEM_rw_size			= EX_o_mem_rw_size;

	wire MEM_wr_en 					= EX_sig_o_mem_wr_en;
	wire [WIDTH - 1: 0] MEM_wr_addr = EX_rd;
	wire [WIDTH - 1: 0] MEM_wr_data	= EX_o_mem_wr_data;

	wire MEM_rd_en					= EX_sig_o_mem_rd_en;
	wire [WIDTH - 1: 0] MEM_rd_addr = EX_rd;
	wire [WIDTH - 1: 0] MEM_rd_data;


	// WRITE BACK
	reg WB_halt = 0;

	wire [4: 0] WB_rd_sel;
	wire [WIDTH - 1: 0] WB_rd;
	// assign WB_rd = MEM_rd_data;

	wire [4: 0] WB_rs1_sel = DE_rs1_sel;
	wire [WIDTH - 1: 0] WB_rs1;
	assign EX_rs1 = WB_rs1;

	wire [4: 0] WB_rs2_sel = DE_rs2_sel;
	wire [WIDTH - 1: 0] WB_rs2;
	assign EX_rs2 = WB_rs2;


	// assign FE_halt	 = EX_i_rd_sel != EX_o_rd_sel  && EX_sig_i_mem_rd_en == 0 && EX_sig_o_mem_rd_en == 1 && EX_o_rd_sel > 0;
	assign FE_sig_ld_pc_type =
		DE_j_type == 1 && DE_i_type == 0 ?
			LD_PC_PLUSEQ:
		EX_i_rd_sel != EX_o_rd_sel && EX_sig_i_mem_rd_en == 0 && EX_sig_o_mem_rd_en == 1 && EX_o_rd_sel > 0 ?
			LD_PC_DISABLE:
		LD_PC_INCREMENT;
	// assign DE_halt	 = EX_i_rd_sel != EX_o_rd_sel  && EX_sig_i_mem_rd_en == 0 && EX_sig_o_mem_rd_en == 1 && EX_o_rd_sel > 0;
	// assign EX_halt	 = EX_i_rd_sel != EX_o_rd_sel  && EX_sig_i_mem_rd_en == 0 && EX_sig_o_mem_rd_en == 1 && EX_o_rd_sel > 0;

	assign FE_halt	 = EX_o_rd_sel != MEM_o_rd_sel && EX_sig_o_mem_rd_en == 0 && MEM_o_rd_sel > 0;
	assign DE_halt	 = EX_o_rd_sel != MEM_o_rd_sel && EX_sig_o_mem_rd_en == 0 && MEM_o_rd_sel > 0;
	assign EX_halt	 = EX_o_rd_sel != MEM_o_rd_sel && EX_sig_o_mem_rd_en == 0 && MEM_o_rd_sel > 0;
	assign WB_rd_sel = MEM_o_rd_sel > 0 ? MEM_o_rd_sel: EX_o_rd_sel;
	assign WB_rd  	 = MEM_o_rd_sel > 0 ? MEM_rd_data: EX_rd;

	assign DE_reset = (DE_j_type == 1 && DE_i_type == 0) || reset;
	assign FE_ld_pc =
		DE_j_type == 1 && DE_i_type == 0 ? DE_imm:
		0;


	FETCH #(
		.WIDTH             (WIDTH)
	) u_FETCH (
		.clk               (clk),
		.reset             (reset),
		.halt              (FE_halt),

		.ld_pc             (FE_ld_pc),
		.sig_ld_pc_type    (FE_sig_ld_pc_type),

		.pc_current        (FE_pc_current),
		.pc_next           (FE_pc_next)
	);


	DECODE #(
		.WIDTH            (WIDTH)
	) u_DECODE (
		.clk              (clk),
		.reset            (DE_reset),
		.halt             (DE_halt),

		.instr_raw        (DE_instr),

		.imm              (DE_imm),
		.funct3           (DE_funct3),
		.funct7           (DE_funct7),
		.rs1_sel          (DE_rs1_sel),
		.rs2_sel          (DE_rs2_sel),
		.rd_sel           (DE_rd_sel),

		.i_type           (DE_i_type),
		.j_type           (DE_j_type),

		.i_pc			  (DE_i_pc),
		.i_pc_next		  (DE_i_pc_next),
		.o_pc			  (DE_o_pc),
		.o_pc_next		  (DE_o_pc_next),

		.sig_mem_rd_en    (DE_sig_mem_rd_en),
		.sig_mem_wr_en    (DE_sig_mem_wr_en)
	);


	EXECUTE #(
		.WIDTH              (WIDTH)
	) u_EXECUTE (
		.clk                (clk),
		.reset              (reset),
		.halt               (EX_halt),

		.i_type             (EX_i_type),
		.j_type             (EX_j_type),

		.funct3             (EX_funct3),
		.funct7             (EX_funct7),
		.imm                (EX_imm),

		.rs1                (EX_rs1),
		.rs2                (EX_rs2),
		.rd                 (EX_rd),

		.i_rd_sel           (EX_i_rd_sel),
		.o_rd_sel           (EX_o_rd_sel),

		.i_pc           	(EX_i_pc),
		.i_pc_next          (EX_i_pc_next),
		.o_pc          		(EX_o_pc),
		.o_pc_next          (EX_o_pc_next),

		.sig_i_mem_wr_en    (EX_sig_i_mem_wr_en),
		.sig_o_mem_wr_en    (EX_sig_o_mem_wr_en),

		.sig_i_mem_rd_en    (EX_sig_i_mem_rd_en),
		.sig_o_mem_rd_en    (EX_sig_o_mem_rd_en),

		.o_mem_wr_data      (EX_o_mem_wr_data),

		.o_mem_rw_size      (EX_o_mem_rw_size)
	);


    MEMORY #(
        .WIDTH		(WIDTH),
        .SIZE 		(1024),

        .INITFILE	("/home/laperex/Programming/Vivado/project_riscv_impl/assets/sample.txt"),
        .DUMPFILE	("")
    ) u_MEMORY (
        .wr_clk		(clk),
        .rd_clk		(clk),
		.reset		(reset),
        .halt 		(MEM_halt),

		.i_rd_sel   (MEM_i_rd_sel),
		.o_rd_sel   (MEM_o_rd_sel),

        .wr_en  	(MEM_wr_en),
        .wr_addr	(MEM_wr_addr),
    	.wr_size	(MEM_rw_size),
        .wr_data	(MEM_wr_data),

        .rd_en  	(MEM_rd_en),
        .rd_addr	(MEM_rd_addr),
    	.rd_size	(MEM_rw_size),
        .rd_data	(MEM_rd_data),

        .fe_rd_en  	(MEM_fe_rd_en),
        .fe_rd_addr	(MEM_fe_rd_addr),
        .fe_rd_data	(MEM_fe_rd_data)
    );


	WRITE_BACK #(
		.WIDTH      (WIDTH)
	) u_WRITE_BACK (
		.clk        (clk),
		.reset      (reset),
		.halt       (WB_halt),

		.rd_sel     (WB_rd_sel),
		.rs1_sel    (WB_rs1_sel),
		.rs2_sel    (WB_rs2_sel),

		.rd         (WB_rd),
		.rs1        (WB_rs1),
		.rs2        (WB_rs2)
	);
endmodule