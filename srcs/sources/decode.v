


module DECODE #(
    parameter WIDTH = 32
) (
    input clk,
    input reset,
	input halt,

    input [WIDTH - 1: 0] instr,

    output reg [WIDTH - 1: 0] imm,
    output reg [2: 0] funct3,
    output reg [7: 0] funct7,
    output reg [4: 0] rs1_sel,
    output reg [4: 0] rs2_sel,
    output reg [4: 0] rd_sel,

    output reg i_type,
    output reg j_type,
    output reg b_type,
    output reg u_type,

    input [WIDTH - 1: 0] i_pc,
    output reg [WIDTH - 1: 0] o_pc,

	output reg sig_mem_rd_en,
	output reg sig_mem_wr_en
);
	// wire [WIDTH - 1: 0] instr;// = { instr_raw[31: 24], instr_raw[23: 16], instr_raw[15: 8], instr_raw[7: 0] };

	// // convert MSB order to LSB order
	// genvar i;
	// for (i = 0; i < WIDTH / 8; i = i + 1) begin
	// 	assign instr[(8 * (i + 1)) - 1: 8 * i] = instr_raw[WIDTH - (8 * i) - 1: WIDTH - (8 * (i + 1))];
	// end

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
	
	reg test;

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
			b_type <= 0;
			u_type <= 0;
			
			test <= 0;

			sig_mem_rd_en <= 0;
			sig_mem_wr_en <= 0;

			o_pc <= 0;
        end else if (halt == 0) begin
			sig_mem_rd_en <= opcode == op_load;
			sig_mem_wr_en <= opcode == op_store;

			i_type <= opcode[5] == 0;
			j_type <= opcode == op_jal || opcode == op_jalr;
			b_type <= opcode == op_branch;
			u_type <= opcode == op_auipc || opcode == op_lui;

			o_pc <= i_pc;

			if (opcode == op_load || opcode == op_imm || opcode == op_jalr) begin
				// I-Type
				imm[31: 11] <= {21{instr[31]}};
				imm[10: 5] <= instr[30: 25];
				imm[4: 1] <= instr[24: 21];
				imm[0] <= instr[20];

				rs1_sel <= instr[19: 15];
				rs2_sel <= 0;
				funct7  <= 0;
				funct3  <= instr[14: 12];
				rd_sel  <= instr[11: 7];
			end else if (opcode == op_store) begin
				// S-Type
				imm[31: 11] <= {21{instr[31]}};
				imm[10: 5] <= instr[30: 25];
				imm[4: 1] <= instr[11: 8];
				imm[0] <= instr[7];

				rs1_sel <= instr[19: 15];
				rs2_sel <= instr[24: 20];
				funct7  <= 0;
				funct3  <= instr[14: 12];
				rd_sel  <= instr[11: 7];
			end else if (opcode == op_branch) begin
				// B-Type
				imm[31: 12] <= {20{instr[31]}};
				imm[11] <= instr[7];
				imm[10: 5] <= instr[30: 25];
				imm[4: 1] <= instr[11: 8];
				imm[0] <= 0;
				
				test <= 1;

				rs1_sel <= instr[19: 15];
				rs2_sel <= instr[24: 20];
				funct3  <= instr[14: 12];
				funct7 <= 0;
				rd_sel  <= 0;
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
				funct3  <= instr[14: 12];
				rd_sel  <= instr[11: 7];
			end else if (opcode == op_auipc || opcode == op_lui) begin
				// U-Type
				imm[31] <= instr[31];
				imm[30: 20] <= instr[30: 20];
				imm[19: 12] <= instr[19: 12];
				imm[11: 0] <= 0;

				rs1_sel <= 0;
				rs2_sel <= 0;
				funct7 <= 0;
				funct3  <= 0;
				rd_sel  <= instr[11: 7];
			end else begin
				rs1_sel <= instr[19: 15];
				rs2_sel <= instr[24: 20];
				funct7 <= instr[31: 25];
				funct3  <= instr[14: 12];
				rd_sel  <= instr[11: 7];
			end
		end
    end
endmodule