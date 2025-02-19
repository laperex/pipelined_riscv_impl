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
    input [WIDTH - 1:0] pc_in_val,

    input pc_count_en,

    output reg [WIDTH - 1:0] pc_out_val,
    output [WIDTH - 1:0] pc_out_val_next
);
    always @(posedge clk) begin
        if (reset) begin
            pc_out_val <= 0;
        end else begin
            if (pc_in_en) begin
                pc_out_val <= pc_in_val;
            end else if (pc_count_en) begin
                pc_out_val <= pc_out_val_next;
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

    input [WIDTH - 1:0] rs1,
    input [WIDTH - 1:0] rs2,
    input [WIDTH - 1:0] pc,
    input [WIDTH - 1:0] imm,

    output [WIDTH - 1:0] rd
);
endmodule


module register_bank #(
    WIDTH = 32
) (
    input clk,
    input reset,

    input [4:0] rs1_sel,
    input [4:0] rs2_sel,
    input [4:0] rd_sel,
    input rd_en,

    input [WIDTH - 1:0] rd,

    output [WIDTH - 1:0] rs1,
    output [WIDTH - 1:0] rs2
);
    reg [WIDTH - 1:0] registers[31:0];

    assign rs1 = registers[rs1_sel];
    assign rs2 = registers[rs2_sel];

    generate
        genvar i;
        for (i = 0; i < 32; i = i + 1) begin
            always @(posedge clk) begin
                if (reset) begin
                    registers[i] <= 0;
                end
            end
        end
    endgenerate

    always @(posedge clk) begin
        if (rd_en && rd_sel > 0) begin
            registers[rd_sel] <= 0;
        end
    end
endmodule


module FETCH #(
    WIDTH = 32
) (
    input clk,
    input reset,

    input pc_in_en,
    input [WIDTH - 1:0] pc_in,

    input pc_count_en,

    output reg [WIDTH - 1:0] pc_out = 0,
    output [WIDTH - 1:0] pc_next_out,

    output [WIDTH - 1:0] instr,

    output reg mem_rd_en,
    output [WIDTH - 1:0] mem_rd_addr,
    input [WIDTH - 1:0] mem_rd_data
);
    assign pc_next_out = pc_in_en ? pc_in : pc_out + 1;

    assign mem_rd_addr = pc_out;
    assign instr = mem_rd_data;


    always @(posedge clk) begin
        if (reset) begin
            pc_out <= 0;
            mem_rd_en <= 1;
        end else begin
            if (pc_count_en || pc_in_en) begin
                pc_out <= pc_next_out;
            end
        end
    end
endmodule


module DECODE #(
    WIDTH = 32
) (
    input clk,
    input reset,

    input [WIDTH - 1:0] inst,
    input pc_in,

    output reg [WIDTH - 1:0] imm,

    output reg [2:0] funct3,
    output reg [7:0] funct7,

    output reg [4:0] rs1_sel,
    output reg [4:0] rs2_sel,
    output reg [4:0] rd_sel,

    output reg [WIDTH - 1:0] pc_out
);
    // -> Integer Register-Immediate Instructions
    // ---> I-Type
    parameter op_imm = 'b0010011;

    parameter f3_addi = 'h0;  // ADD Immediate
    parameter f3_xori = 'h4;  // XOR Immediate
    parameter f3_ori = 'h6;  // OR Immediate
    parameter f3_andi = 'h7;  // AND Immediate
    parameter f3_slli = 'h1;
    parameter imm_slli_11_5 = 'h00;  // Shift Left Logical Imm
    parameter f3_srli = 'h5;
    parameter imm_srli_11_5 = 'h00;  // Shift Right Logical Imm
    parameter f3_srai = 'h5;
    parameter imm_srai_11_5 = 'h20;  // Shift Right Arith Imm
    parameter f3_slti = 'h2;  // Set Less Than Imm
    parameter f3_sltiu = 'h3;  // Set Less Than Imm (U)


    // ---> U-Type
    parameter op_lui = 'b0110111;
    parameter op_auipc = 'b0010111;


    // -> Integer Register-Register Operations
    // ---> R - Type

    parameter op_reg = 'b0110011;

    parameter f3_add = 'h0;
    parameter f7_add = 'h00;  //ADD
    parameter f3_sub = 'h0;
    parameter f7_sub = 'h20;  //SUB
    parameter f3_xor = 'h4;
    parameter f7_xor = 'h00;  //XOR
    parameter f3_or = 'h6;
    parameter f7_or = 'h00;  //OR
    parameter f3_and = 'h7;
    parameter f7_and = 'h00;  //AND
    parameter f3_sll = 'h1;
    parameter f7_sll = 'h00;  //Shift Left Logical
    parameter f3_srl = 'h5;
    parameter f7_srl = 'h00;  //Shift Right Logical
    parameter f3_sra = 'h5;
    parameter f7_sra = 'h20;  //Shift Right Arith*
    parameter f3_slt = 'h2;
    parameter f7_slt = 'h00;  //Set Less Than
    parameter f3_sltu = 'h3;
    parameter f7_sltu = 'h00;  //Set Less Than (U)

    // -> Unconditional Jumps
    // ---> J-type
    parameter op_jal = 'b1101111;  // offset[20: 1]

    // ---> I-type
    parameter op_jalr = 'b1100111;  // offset [11: 0]
    parameter f3_jalr = 'h0;

    // -> Conditional Branches
    // B-Type
    parameter op_branch = 'b1100011;
    parameter f3_beq = 'h0;  // Branch ==
    parameter f3_bne = 'h1;  // Branch !=
    parameter f3_blt = 'h4;  // Branch <
    parameter f3_bge = 'h5;  // Branch ≥
    parameter f3_bltu = 'h6;  // Branch < (U)
    parameter f3_bgeu = 'h7;  // Branch ≥ (U)

    // -> Load and Store Instructions
    // S-Type
    parameter op_load = 'b0000011;
    parameter f3_lb = 'h0;  // Load Byte
    parameter f3_lh = 'h1;  // Load Half
    parameter f3_lw = 'h2;  // Load Word
    parameter f3_lbu = 'h4;  // Load Byte (U)
    parameter f3_lhu = 'h5;  // Load Half (U)

    parameter op_store = 'b0100011;
    parameter f3_sb = 'h0;  // Store Byte
    parameter f3_sh = 'h1;  // Store Half
    parameter f3_sw = 'h2;  // Store Word

    // -> Environment Instructions
    parameter op_env = 'b1110011;

    parameter f3_ecall = 'h0;
    parameter imm_ecall = 'h0;
    parameter f3_ebreak = 'h0;
    parameter imm_ebreak = 'h1;


    wire [6:0] opcode = inst[6:0];


    // assign shift_amt = imm[4: 0];


    always @(posedge clk) begin
        rs1_sel <= inst[19:15];
        rs2_sel <= inst[24:20];
        rd_sel  <= inst[11:7];

        funct3  <= inst[14:12];
        funct7  <= inst[31:25];

        pc_out  <= pc_in;

        // Immediates
        if (opcode == op_load || opcode == op_imm) begin
            // I-Type
            imm[31:11] <= {21{inst[31]}};
            imm[10:5] <= inst[30:25];
            imm[4:1] <= inst[24:21];
            imm[0] <= inst[20];
        end else if (opcode == op_store) begin
            // S-Type
            imm[31:11] <= {21{inst[31]}};
            imm[10:5] <= inst[30:25];
            imm[4:1] <= inst[11:8];
            imm[0] <= inst[7];
        end else if (opcode == op_branch) begin
            // B-Type
            imm[31:12] <= {20{inst[31]}};
            imm[11] <= inst[7];
            imm[10:5] <= inst[30:25];
            imm[4:1] <= inst[11:8];
            imm[0] <= 0;
        end else if (opcode == op_jal) begin
            // J-Type
            imm[31:20] <= {12{inst[31]}};
            imm[19:12] <= inst[19:12];
            imm[11] <= inst[20];
            imm[10:5] <= inst[30:25];
            imm[4:1] <= inst[24:21];
            imm[0] <= 0;
        end else if (opcode == op_auipc || opcode == op_lui) begin
            // U-Type
            imm[31] <= inst[31];
            imm[30:20] <= inst[30:20];
            imm[19:12] <= inst[19:12];
            imm[11:0] <= 0;
        end
    end
endmodule

module EXECUTE #(
    WIDTH = 32
) (
    input clk,
    input reset,

    input [2:0] funct3,
    input [7:0] funct7,

    input  [4:0] rs1,
    input  [4:0] rs2,
    output [4:0] rd,

    input [WIDTH - 1:0] pc_in,
    output reg [WIDTH - 1:0] pc_out
);
    parameter f3_add = 'h0;
    parameter f3_sub = 'h0;
    parameter f3_xor = 'h4;
    parameter f3_or = 'h6;
    parameter f3_and = 'h7;
    parameter f3_sll = 'h1;
    parameter f3_srl = 'h5;
    parameter f3_sra = 'h5;
    parameter f3_slt = 'h2;
    parameter f3_sltu = 'h3;
endmodule

module ALU ();
endmodule

module LOAD_STORE ();
endmodule

module WRITE_BACK ();
endmodule


module return_address_stack #(
    WIDTH = 32,
    STACK_SIZE = 1024
) (
    input clk,
    input reset,

    input push_en,
    input [WIDTH - 1:0] push_val,

    input pop_en,
    output reg [WIDTH - 1:0] pop_val,

    output reg [1:0] error
);
    parameter ER_SUCCESS = 0;
    parameter ER_UNDERFLOW = 1;
    parameter ER_OVERFLOW = 2;

    reg [$clog2(STACK_SIZE - 1) - 1:0] stack_ptr;
    reg [$clog2(STACK_SIZE - 1) - 1:0] stack_ptr_prev;

    reg [WIDTH - 1:0] stack_memory[0:STACK_SIZE - 1];

    always @(posedge clk) begin
        if (reset) begin
            stack_ptr <= 0;
            stack_ptr_prev <= 0;
            error <= 0;
        end else begin
            if (push_en != pop_en) begin
                stack_memory[stack_ptr] <= push_val;
                pop_val <= stack_memory[stack_ptr_prev];

                if (push_en) begin
                    stack_ptr <= stack_ptr + 1;
                    stack_ptr_prev <= stack_ptr;
                end

                if (pop_en) begin
                    stack_ptr <= stack_ptr + 1;
                    stack_ptr_prev <= stack_ptr;
                end
            end


            // if (push_en) begin
            // 	stack_ptr <= stack_ptr + 1;
            // 	stack_ptr_prev <= stack_ptr;

            // stack_memory[stack_ptr] <= push_val;

            // 	error <= (stack_ptr == STACK_SIZE - 1) ? ER_OVERFLOW: ER_SUCCESS;
            // end

            // if (pop_en) begin
            // pop_val <= stack_memory[stack_ptr_prev];

            // stack_ptr_prev <= stack_ptr_prev - 1;
            // stack_ptr <= stack_ptr_prev;

            // error <= (stack_ptr == 0) ? ER_UNDERFLOW: ER_SUCCESS;
            // end
        end
    end
endmodule




module processor #(
    WIDTH = 32
) (
    input clk,
    input reset,

    input [WIDTH - 1:0] PORT_IN_A,
    input [WIDTH - 1:0] PORT_IN_B,
    input [WIDTH - 1:0] PORT_IN_C,
    input [WIDTH - 1:0] PORT_IN_D,

    output [WIDTH - 1:0] PORT_OUT_A,
    output [WIDTH - 1:0] PORT_OUT_B,
    output [WIDTH - 1:0] PORT_OUT_C,
    output [WIDTH - 1:0] PORT_OUT_D
);
    wire mem_wr_clk = clk;
    wire mem_rd_clk = clk;

    wire mem_wr_en;
    wire [WIDTH - 1:0] mem_wr_addr;
    wire [WIDTH - 1:0] mem_wr_data;

    wire mem_rd_en;
    wire [WIDTH - 1:0] mem_rd_addr;
    wire [WIDTH - 1:0] mem_rd_data;


    memory #(
        .WIDTH(WIDTH),
        .SIZE (256),

        // .INITFILE(""),
        .INITFILE("/home/laperex/Programming/Vivado/project_riscv_impl/assets/sample.txt"),
        .DUMPFILE("")
    ) u_memory (
        .wr_clk(mem_wr_clk),
        .rd_clk(mem_rd_clk),
        .reset (mem_reset),

        .wr_en  (mem_wr_en),
        .wr_addr(mem_wr_addr),
        .wr_data(mem_wr_data),

        .rd_en  (mem_rd_en),
        .rd_addr(mem_rd_addr[7:0]),
        .rd_data(mem_rd_data)
    );


    reg pc_in_en = 0;
    reg [WIDTH - 1:0] pc_in = 0;

    reg pc_count_en = 1;

    wire [WIDTH - 1:0] pc_out;
    wire [WIDTH - 1:0] pc_next_out;

    wire [WIDTH - 1:0] instr;


    FETCH #(
        .WIDTH(WIDTH)
    ) u_FETCH (
        .clk  (clk),
        .reset(reset),

        .pc_in_en(pc_in_en),
        .pc_in   (pc_in),

        .pc_count_en(pc_count_en),

        .pc_out     (pc_out),
        .pc_next_out(pc_next_out),

        .instr(instr),

        .mem_rd_en  (mem_rd_en),
        .mem_rd_addr(mem_rd_addr),
        .mem_rd_data(mem_rd_data)
    );
endmodule
