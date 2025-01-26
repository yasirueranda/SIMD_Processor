module pe (
    input logic clk,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] opcode,
    output logic [31:0] out
);

typedef enum logic [3:0] {NOP, LOAD_A, LOAD_B, ADD, SUB, MUL, DOT, BUFFER_RES_1, BUFFER_RES_2,STORE, STOP} OPCODE; 

always_comb begin
    unique0 case(opcode)
        NOP: out = 0;
        LOAD_A: out = 0;
        LOAD_B: out = 0;
        ADD: out = a + b;
        SUB: out = a - b;
        MUL: out = a * b;
        DOT: out = a * b;
        BUFFER_RES_1: out = 0;
        BUFFER_RES_2: out = 0;
        STORE: out = 0;
        STOP: out = 0;
        default: out = 0;
    endcase
end


endmodule
/*
module pe #(
    parameter OPCODE_LEN = 4
)(
    input logic clk,
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [OPCODE_LEN-1:0] opcode,
    output logic [31:0] out
);

typedef enum logic [OPCODE_LEN-1:0] {NOP, LOAD_A, LOAD_B, ADD, SUB, MUL, DOT, BUFFER_RES_1, BUFFER_RES_2,STORE, STOP} OPCODE; 

logic [31:0] add_out;
logic [31:0] sub_out;
logic [42:0] mult_out;
logic carry_out;


ADDSUB_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
    .LATENCY(1), // Desired clock cycle latency, 0-2
    .WIDTH(32) // Input / output bus width, 1-48
) ADDSUB_MACRO_inst_1 (
    .CARRYOUT(carry_out),
    .RESULT(add_out), // Add/sub result output, width defined by WIDTH parameter
    .A(a), // Input A bus, width defined by WIDTH parameter
    .ADD_SUB(1'b1), // 1-bit add/sub input, high selects add, low selects subtract
    .B(b), // Input B bus, width defined by WIDTH parameter
    .CARRYIN(1'b0), // 1-bit carry-in input
    .CE(1'b1), // 1-bit clock enable input
    .CLK(clk), // 1-bit clock input
    .RST(1'b0) // 1-bit active high synchronous reset
);

ADDSUB_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
    .LATENCY(1), // Desired clock cycle latency, 0-2
    .WIDTH(32) // Input / output bus width, 1-48
) ADDSUB_MACRO_inst_2 (
    .CARRYOUT(carry_out),
    .RESULT(add_out), // Add/sub result output, width defined by WIDTH parameter
    .A(a), // Input A bus, width defined by WIDTH parameter
    .ADD_SUB(1'b0), // 1-bit add/sub input, high selects add, low selects subtract
    .B(b), // Input B bus, width defined by WIDTH parameter
    .CARRYIN(1'b0), // 1-bit carry-in input
    .CE(1'b1), // 1-bit clock enable input
    .CLK(clk), // 1-bit clock input
    .RST(1'b0) // 1-bit active high synchronous reset
);

MULT_MACRO #(
.DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6","7SERIES"
.LATENCY(1), // Desired clock cycle latency, 0-4
.WIDTH_A(25), // Multiplier A-input bus width, 1-25
.WIDTH_B(18) // Multiplier B-input bus width, 1-18
) MULT_MACRO_inst (
.P(mult_out), // Multiplier output bus, width determined by WIDTH_P parameter
.A(a[25-1:0]), // Multiplier input A bus, width determined by WIDTH_A parameter
.B(b[18-1:0]), // Multiplier input B bus, width determined by WIDTH_B parameter
.CE(1'b1), // 1-bit active high input clock enable
.CLK(clk), // 1-bit positive edge clock input
.RST(1'b0) // 1-bit input active high reset
);

always_comb begin
    unique0 case(opcode)
        NOP: out = 0;
        LOAD_A: out = 0;
        LOAD_B: out = 0;
        ADD: out = add_out;
        SUB: out = sub_out;
        MUL: out = mult_out;
        DOT: out = mult_out;
        BUFFER_RES_1: out = 0;
        BUFFER_RES_2: out = 0;
        STORE: out = 0;
        STOP: out = 0;
        default: out = 0;
    endcase
end


endmodule
*/