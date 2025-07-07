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




module processor #(
    parameter WIDTH = 32,
	parameter INITFILE = "",
	parameter DUMPFILE = ""
) (
    input clk,
    input reset,

    // input [WIDTH - 1: 0] PORT_IN_A,
    // input [WIDTH - 1: 0] PORT_IN_B,
    // input [WIDTH - 1: 0] PORT_IN_C,
    // input [WIDTH - 1: 0] PORT_IN_D,

    output reg [WIDTH - 1: 0] PORT_OUT_A,
    output reg [WIDTH - 1: 0] PORT_OUT_B,
    output reg [WIDTH - 1: 0] PORT_OUT_C,
    output reg [WIDTH - 1: 0] PORT_OUT_D
);
    // FETCH
    localparam LD_PC_DISABLE = 0;
    localparam LD_PC_PLUSEQ = 1;
    localparam LD_PC_REPLACE = 2;
    localparam LD_PC_INCREMENT = 3;

    wire FE_halt;
    wire FE_reset;

    wire [WIDTH - 1: 0] FE_load_pc_A;
    wire [WIDTH - 1: 0] FE_load_pc_B;

    wire [WIDTH - 1: 0] FE_pc;


    // FETCH MEMORY
    wire MEM_fe_rd_en;
    wire [WIDTH - 1: 0] MEM_fe_rd_addr = FE_pc;
    wire [WIDTH - 1: 0] MEM_fe_rd_data;


    // DECODE
    wire DE_halt;
    wire [WIDTH - 1: 0] DE_instr = MEM_fe_rd_data;

    wire [WIDTH - 1: 0] DE_imm;
    wire [2: 0] DE_funct3;
    wire [7: 0] DE_funct7;

    wire [4: 0] DE_rs1_sel;
    wire [4: 0] DE_rs2_sel;
    wire [4: 0] DE_rd_sel;

    wire DE_i_type;
    wire DE_j_type;
    wire DE_b_type;
    wire DE_u_type;

    wire DE_sig_mem_rd_en;
    wire DE_sig_mem_wr_en;

    wire [WIDTH - 1: 0] DE_i_pc = FE_pc;
    wire [WIDTH - 1: 0] DE_o_pc;


    // EXECUTE
    wire EX_halt;
    wire EX_i_type = DE_i_type;
    wire EX_j_type;				//= DE_j_type;
    // wire EX_b_type				= DE_b_type;
    wire EX_u_type				= DE_u_type;
    wire [2: 0] EX_funct3		= DE_funct3;
    wire [7: 0] EX_funct7		= DE_funct7;
    wire [WIDTH - 1: 0] EX_imm	= DE_imm;
    wire [WIDTH - 1: 0] EX_rs1;
    wire [WIDTH - 1: 0] EX_rs2;

    wire [WIDTH - 1: 0] EX_rd;
    wire [4: 0] EX_i_rd_sel		= DE_rd_sel;
    wire [4: 0] EX_o_rd_sel;

    wire [WIDTH - 1: 0] EX_i_pc	= DE_o_pc;
    wire [WIDTH - 1: 0] EX_o_pc;

    wire EX_sig_i_mem_wr_en		= DE_sig_mem_wr_en;
    wire EX_sig_o_mem_wr_en;
    wire EX_sig_i_mem_rd_en		= DE_sig_mem_rd_en;
    wire EX_sig_o_mem_rd_en;

    wire [WIDTH - 1: 0] EX_o_mem_wr_data;
    wire [2: 0] EX_o_mem_rw_size;


    // MEMORY
    reg MEM_halt = 0;
    wire [4: 0] MEM_i_rd_sel		= EX_o_rd_sel;
    wire [4: 0] MEM_o_rd_sel;

    wire [2: 0] MEM_rw_size			= EX_o_mem_rw_size;

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

    wire [4: 0] WB_rs1_sel	= DE_rs1_sel;
    wire [WIDTH - 1: 0] WB_rs1;
    assign EX_rs1			= WB_rs1;
	
	// if (MEM_i_rd_sel == WB_rs1_sel && WB_rs1_sel > 0) begin
	// 	rd_temp
	// end

    wire [4: 0] WB_rs2_sel	= DE_rs2_sel;
    wire [WIDTH - 1: 0] WB_rs2;
    assign EX_rs2			= WB_rs2;
    
    
    wire is_branch_taken =
        DE_b_type ?
            DE_funct3 == 0 ? (EX_rs1 == EX_rs2):
            DE_funct3 == 1 ? (EX_rs1 != EX_rs2):
            DE_funct3 == 4 ? (EX_rs1 < EX_rs2):
            DE_funct3 == 5 ? (EX_rs1 >= EX_rs2):
            DE_funct3 == 6 ? (EX_rs1 < EX_rs2):
            DE_funct3 == 7 ? (EX_rs1 >= EX_rs2):
            0:
        DE_j_type;
    
    assign EX_j_type = is_branch_taken;

    // assign FE_halt	 = EX_i_rd_sel != EX_o_rd_sel  && EX_sig_i_mem_rd_en == 0 && EX_sig_o_mem_rd_en == 1 && EX_o_rd_sel > 0;
    assign FE_load_pc_B =
        is_branch_taken == 1 ?
            DE_imm:
        EX_i_rd_sel != EX_o_rd_sel && EX_sig_i_mem_rd_en == 0 && EX_sig_o_mem_rd_en == 1 && EX_o_rd_sel > 0 ?
            0:
        4;

    assign FE_load_pc_A =
        DE_j_type == 1 && DE_i_type == 1 ?
            WB_rs1:
        is_branch_taken == 1 && DE_i_type == 0 ?
            EX_o_pc:
        FE_pc;

    // assign FE_halt = DE_j_type;

    assign MEM_fe_rd_en = 1;
    // assign DE_halt	 = EX_i_rd_sel != EX_o_rd_sel  && EX_sig_i_mem_rd_en == 0 && EX_sig_o_mem_rd_en == 1 && EX_o_rd_sel > 0;
    // assign EX_halt	 = EX_i_rd_sel != EX_o_rd_sel  && EX_sig_i_mem_rd_en == 0 && EX_sig_o_mem_rd_en == 1 && EX_o_rd_sel > 0;

    assign FE_halt	 = MEM_o_rd_sel > 0 && EX_o_rd_sel != MEM_o_rd_sel && EX_sig_o_mem_rd_en == 0;
    assign DE_halt	 = MEM_o_rd_sel > 0 && EX_o_rd_sel != MEM_o_rd_sel && EX_sig_o_mem_rd_en == 0;
    assign EX_halt	 = MEM_o_rd_sel > 0 && EX_o_rd_sel != MEM_o_rd_sel && EX_sig_o_mem_rd_en == 0;

    assign WB_rd_sel = MEM_o_rd_sel > 0 ? MEM_o_rd_sel: EX_o_rd_sel;
    assign WB_rd  	 = MEM_o_rd_sel > 0 ? MEM_rd_data: EX_rd;

    // assign DE_reset = (DE_j_type == 1 && DE_i_type == 0) || reset;
    // assign FE_reset = (DE_j_type == 1 && DE_i_type == 0) || reset;
    // assign FE_ld_pc = DE_j_type == 1 && DE_i_type == 0 ? DE_imm: 0;
    

    // reg EX_reset;
    // reg DE_reset;
    // always @(posedge clk) begin
    // 	DE_reset <= (DE_j_type == 1 && DE_i_type == 0) || reset;
    // 	EX_reset <= reset | DE_reset;
    // end
	
	
	
	reg [31: 0] rd_prev;
	reg rd_prev_en;
	
	
    always @(posedge clk) begin
        if (reset) begin
            PORT_OUT_A <= 0;
            PORT_OUT_B <= 0;
            PORT_OUT_C <= 0;
            PORT_OUT_D <= 0;
			rd_prev <= 0;
			rd_prev_en <= 0;
        end else begin
			rd_prev_en <= (MEM_i_rd_sel > 0) && (MEM_i_rd_sel == WB_rs1_sel) && MEM_rd_en;
			rd_prev <= MEM_rd_data;

            if (MEM_wr_en) begin
                case (MEM_wr_addr)
                    'h40000000:
                        PORT_OUT_A <= MEM_wr_data;
                    'h40000001:
                        PORT_OUT_B <= MEM_wr_data;
                    'h40000002:
                        PORT_OUT_C <= MEM_wr_data;
                    'h40000003:
                        PORT_OUT_D <= MEM_wr_data;
                endcase
            end
        end
    end



    FETCH #(
        .WIDTH             (WIDTH)
    ) u_FETCH (
        .clk               (clk),
        .reset             (reset),
        .halt              (FE_halt),

        .load_pc_A         (FE_load_pc_A),
        .load_pc_B         (FE_load_pc_B),
        
        .pc_out            (FE_pc)
    );


    DECODE #(
        .WIDTH            (WIDTH)
    ) u_DECODE (
        .clk              (clk),
        .reset            (reset),
        .halt             (DE_halt),

        .instr            (DE_instr),

        .imm              (DE_imm),
        .funct3           (DE_funct3),
        .funct7           (DE_funct7),
        .rs1_sel          (DE_rs1_sel),
        .rs2_sel          (DE_rs2_sel),
        .rd_sel           (DE_rd_sel),

        .i_type           (DE_i_type),
        .j_type           (DE_j_type),
        .b_type           (DE_b_type),
        .u_type           (DE_u_type),

        .i_pc			  (DE_i_pc),
        .o_pc			  (DE_o_pc),

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
        // .b_type             (EX_b_type),
        .u_type             (EX_u_type),

        .funct3             (EX_funct3),
        .funct7             (EX_funct7),
        .imm                (EX_imm),

        .rs1                (EX_rs1),
        .rs2                (EX_rs2),
        .rd                 (EX_rd),

        .i_rd_sel           (EX_i_rd_sel),
        .o_rd_sel           (EX_o_rd_sel),

        .i_pc           	(EX_i_pc),
        .o_pc          		(EX_o_pc),

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

        .INITFILE	(INITFILE),
        .DUMPFILE	(DUMPFILE)
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