


module multi_node #(
    parameter IDX   = 0,
    parameter WIDTH = 32
) (
    input clk,
    input reset,

    input [WIDTH - 1: 0] md_val,
    input [WIDTH - 1: 0] pd_val,
    input [WIDTH - 1: 0] mr_val,
    input mx_val,

    output reg [WIDTH - 1: 0] md_next,
    output reg [WIDTH - 1: 0] pd_next,
    output reg [WIDTH - 1: 0] mr_next,
    output reg mx_next
);
	wire [WIDTH - 1: 0] pd_res =
		mr_val[0] == 1 && mx_val == 0 ?
			pd_val - md_val:
		mr_val[0] == 0 && mx_val == 1 ?
			pd_val + md_val:
			pd_val;

	always @(posedge clk) begin
		if (reset) begin
			md_next <= 0;
			pd_next <= 0;
			mr_next <= 0;
			mx_next <= 0;
		end else begin
			md_next <= md_val;

			pd_next[WIDTH - 1] <= pd_res[WIDTH - 1];
			pd_next[WIDTH - 2: 0] <= pd_res >> 1;

			mr_next[WIDTH - 1] <= pd_res[0];
			mr_next[WIDTH - 2: 0] <= mr_val >> 1;

			mx_next <= mr_val[0];
		end
	end
endmodule



module pipelined_boothe_multiplier #(
    WIDTH = 32
) (
    input clk,
    input reset,

    input en,

    input [WIDTH - 1: 0] md,
    input [WIDTH - 1: 0] mr,

    output [(2 * WIDTH) - 1: 0] s_result
);
	wire [WIDTH - 1: 0] _md[WIDTH: 0];
	wire [WIDTH - 1: 0] _pd[WIDTH: 0];
	wire [WIDTH - 1: 0] _mr[WIDTH: 0];
	wire _mx[WIDTH: 0];
	genvar i;


	assign _md[0] = md;
	assign _pd[0] = 0;
	assign _mr[0] = mr;
	assign _mx[0] = 0;

	assign s_result[(2 * WIDTH) - 1: 0] = { _pd[WIDTH], _mr[WIDTH] };

	for (i = 0; i < WIDTH; i = i + 1) begin
		multi_node #(
			.IDX        (i),
			.WIDTH      (WIDTH)
		) u_multi_node (
			.clk        (clk),
			.reset      (reset),

			.md_val     (_md[i]),
			.pd_val     (_pd[i]),
			.mr_val     (_mr[i]),
			.mx_val     (_mx[i]),

			.md_next    (_md[i + 1]),
			.pd_next    (_pd[i + 1]),
			.mr_next    (_mr[i + 1]),
			.mx_next    (_mx[i + 1])
		);
	end
endmodule
