module execute_stage#(
    parameter PE_ELEMENTS = 4,
    parameter  DATA_LEN = 32,
    localparam OPCODE_LEN = 4
)(
    input logic rstn, clk,
    input logic [OPCODE_LEN-1:0] opcode,
    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0]data_a,
    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0]data_b,
    output logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] result_stage_1,
    output logic result_stage_1_valid,
    output logic [DATA_LEN-1:0] result_stage_2,
    output logic result_stage_2_valid,
    output logic store_result,
    output logic stop
);

localparam NUM_STAGES = $clog2(PE_ELEMENTS); // Number of stages in the tree
typedef enum logic [OPCODE_LEN-1:0] {NOP, LOAD_A, LOAD_B, ADD, SUB, MUL, DOT, BUFFER_RES_1, BUFFER_RES_2,STORE, STOP} OPCODE; 

logic [(PE_ELEMENTS-1):0][DATA_LEN-1:0] pe_stage_1_output_buffer[NUM_STAGES]; 
logic [OPCODE_LEN-1:0] opcode_buffer[NUM_STAGES];
//logic carry_out_1,carry_out_2,carry_out_3,carry_out_4;
//logic [DATA_LEN-1:0] pe_1_out,pe_2_out,pe_3_out,pe_4_out;
logic [DATA_LEN-1:0] pe_out[PE_ELEMENTS-1:0];
logic [DATA_LEN-1:0] sum_out;
logic [DATA_LEN-1:0] acc_output;
logic [DATA_LEN-1:0] acc_output_hold;

genvar i;
generate
    for (i = 0; i < PE_ELEMENTS; i++) begin : pe_inst
        pe pe_instance (
            .clk(clk),
            .a(data_a[i]),
            .b(data_b[i]),
            .opcode(opcode),
            .out(pe_out[i])
        );
    end
endgenerate
// summation stage
summation_tree #(
    .PE_ELEMENTS(PE_ELEMENTS), // Number of processing elements
    .DATA_LEN(DATA_LEN)   // Data width
) sum_tree (
    .pe_out(pe_out),
    .clk(clk),
    .rstn(rstn),
    .sum_out(sum_out)
);

addsub adder4(
    .clk(clk),
    .rst(!rstn),
    .a(sum_out),
    .b(acc_output),
    .out(acc_output_hold)
);



// Buffering the stage 1 output of PEs
always @(posedge clk) begin
    if (!rstn) begin
        for (int i = 0; i < NUM_STAGES; i++) begin
            for (int j = 0; j < PE_ELEMENTS; j++) begin
                pe_stage_1_output_buffer[i][j] <= '0;
            end
        end
    end else begin
        for (int j = 0; j < PE_ELEMENTS; j++) begin
            pe_stage_1_output_buffer[0][j] <= pe_out[j];
        end
        for (int i = 1; i < NUM_STAGES; i++) begin
            for (int j = 0; j < PE_ELEMENTS; j++) begin
                pe_stage_1_output_buffer[i][j] <= pe_stage_1_output_buffer[i-1][j];
            end
        end
    end
end


// buffering the opcodes of PEs
always@(posedge clk) begin
    if (!rstn) begin
        for (int i = 0; i < NUM_STAGES; i++) begin
            opcode_buffer[i] <= '0;
        end
    end else begin
        opcode_buffer[0] <= opcode; // Directly assign opcode to the first buffer
        for (int i = 1; i < NUM_STAGES; i++) begin
            opcode_buffer[i] <= opcode_buffer[i-1];
        end
    end
end

// connections back to the PE fetch unit
assign result_stage_1 = pe_stage_1_output_buffer[NUM_STAGES-1];
assign result_stage_2 = acc_output_hold;

assign result_stage_1_valid = opcode_buffer[NUM_STAGES-2] == BUFFER_RES_1;
assign result_stage_2_valid = opcode_buffer[NUM_STAGES-1] == BUFFER_RES_2;
assign store_result = opcode_buffer[NUM_STAGES-1] == STORE;
assign stop = opcode_buffer[NUM_STAGES-1] == STOP;

always_comb begin
    acc_output = (opcode_buffer[NUM_STAGES-1] == BUFFER_RES_2) ? 0 : acc_output_hold;
end

endmodule

/*
module execute_stage#(
    parameter PE_ELEMENTS = 4,
    parameter  DATA_LEN = 32,
    parameter OPCODE_LEN = 4
)(
    input logic rstn, clk,
    input logic [OPCODE_LEN-1:0] opcode,
    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0]data_a,
    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0]data_b,
    output logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] result_stage_1,
    output logic result_stage_1_valid,
    output logic [DATA_LEN-1:0] result_stage_2,
    output logic result_stage_2_valid,
    output logic store_result,
    output logic stop
);

typedef enum logic [OPCODE_LEN-1:0] {NOP, LOAD_A, LOAD_B, ADD, SUB, MUL, DOT, BUFFER_RES_1, BUFFER_RES_2,STORE, STOP} OPCODE; 

logic [3:0][DATA_LEN-1:0] pe_stage_1_output_buffer[2]; 
logic [OPCODE_LEN-1:0] opcode_buffer[2];
//logic carry_out_1,carry_out_2,carry_out_3,carry_out_4;
logic [DATA_LEN-1:0] pe_1_out,pe_2_out,pe_3_out,pe_4_out;
logic [1:0][DATA_LEN-1:0] sum_stage_out_1;
logic [DATA_LEN-1:0] sum_stage_out_2;
logic [DATA_LEN-1:0] acc_output;
logic [DATA_LEN-1:0] acc_output_hold;

pe pe_1 (
    .clk(clk),
    .a(data_a[0]),
    .b(data_b[0]),
    .opcode(opcode),
    .out(pe_1_out)
);

pe pe_2 (
    .clk(clk),
    .a(data_a[1]),
    .b(data_b[1]),
    .opcode(opcode),
    .out(pe_2_out)
);

pe pe_3 (
    .clk(clk),
    .a(data_a[2]),
    .b(data_b[2]),
    .opcode(opcode),
    .out(pe_3_out)
);

pe pe_4 (
    .clk(clk),
    .a(data_a[3]),
    .b(data_b[3]),
    .opcode(opcode),
    .out(pe_4_out)
);

// summation stage

ADDSUB_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
    .LATENCY(1), // Desired clock cycle latency, 0-2
    .WIDTH(32) // Input / output bus width, 1-48
) ADDSUB_MACRO_inst_3 (
    .CARRYOUT(carry_out_1),
    .RESULT(sum_stage_out_1[0]), // Add/sub result output, width defined by WIDTH parameter
    .A(pe_1_out), // Input A bus, width defined by WIDTH parameter
    .ADD_SUB(1'b1), // 1-bit add/sub input, high selects add, low selects subtract
    .B(pe_2_out), // Input B bus, width defined by WIDTH parameter
    .CARRYIN(1'b0), // 1-bit carry-in input
    .CE(1'b1), // 1-bit clock enable input
    .CLK(clk), // 1-bit clock input
    .RST(!rstn) // 1-bit active high synchronous reset
);


ADDSUB_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
    .LATENCY(1), // Desired clock cycle latency, 0-2
    .WIDTH(32) // Input / output bus width, 1-48
) ADDSUB_MACRO_inst_4 (
    .CARRYOUT(carry_out_2),
    .RESULT(sum_stage_out_1[1]), // Add/sub result output, width defined by WIDTH parameter
    .A(pe_3_out), // Input A bus, width defined by WIDTH parameter
    .ADD_SUB(1'b1), // 1-bit add/sub input, high selects add, low selects subtract
    .B(pe_4_out), // Input B bus, width defined by WIDTH parameter
    .CARRYIN(1'b0), // 1-bit carry-in input
    .CE(1'b1), // 1-bit clock enable input
    .CLK(clk), // 1-bit clock input
    .RST(!rstn) // 1-bit active high synchronous reset
);

ADDSUB_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
    .LATENCY(1), // Desired clock cycle latency, 0-2
    .WIDTH(32) // Input / output bus width, 1-48
) ADDSUB_MACRO_inst_5 (
    .CARRYOUT(carry_out_3),
    .RESULT(sum_stage_out_2), // Add/sub result output, width defined by WIDTH parameter
    .A(sum_stage_out_1[0]), // Input A bus, width defined by WIDTH parameter
    .ADD_SUB(1'b1), // 1-bit add/sub input, high selects add, low selects subtract
    .B(sum_stage_out_1[1]), // Input B bus, width defined by WIDTH parameter
    .CARRYIN(1'b0), // 1-bit carry-in input
    .CE(1'b1), // 1-bit clock enable input
    .CLK(clk), // 1-bit clock input
    .RST(!rstn) // 1-bit active high synchronous reset
);

ADDSUB_MACRO #(
    .DEVICE("7SERIES"), // Target Device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES"
    .LATENCY(1), // Desired clock cycle latency, 0-2
    .WIDTH(32) // Input / output bus width, 1-48
) ADDSUB_MACRO_inst_6 (
    .CARRYOUT(carry_out_4),
    .RESULT(acc_output_hold), // Add/sub result output, width defined by WIDTH parameter
    .A(sum_stage_out_2), // Input A bus, width defined by WIDTH parameter
    .ADD_SUB(1'b1), // 1-bit add/sub input, high selects add, low selects subtract
    .B(acc_output), // Input B bus, width defined by WIDTH parameter
    .CARRYIN(1'b0), // 1-bit carry-in input
    .CE(1'b1), // 1-bit clock enable input
    .CLK(clk), // 1-bit clock input
    .RST(!rstn) // 1-bit active high synchronous reset
);

// buffering the stage 1 output of PEs
always@(posedge clk) begin
    if (!rstn) begin
        pe_stage_1_output_buffer[0] <= 0;
        pe_stage_1_output_buffer[1] <= 0;
    end else begin
        pe_stage_1_output_buffer[0] <= {pe_4_out, pe_3_out, pe_2_out, pe_1_out};
        pe_stage_1_output_buffer[1] <= pe_stage_1_output_buffer[0];
    end
end

// buffering the opcodes of PEs
always@(posedge clk) begin
    if (!rstn) begin
        opcode_buffer[0] <= 0;
        opcode_buffer[1] <= 0;
    end else begin
        opcode_buffer[0] <= opcode;
        opcode_buffer[1] <= opcode_buffer[0];
    end
end

// connections back to the PE fetch unit
assign result_stage_1 = pe_stage_1_output_buffer[1];
assign result_stage_2 = acc_output_hold;

assign result_stage_1_valid = opcode_buffer[0] == BUFFER_RES_1;
assign result_stage_2_valid = opcode_buffer[1] == BUFFER_RES_2;
assign store_result = opcode_buffer[1] == STORE;
assign stop = opcode_buffer[1] == STOP;

always_comb begin
    acc_output = (opcode_buffer[1] == BUFFER_RES_2) ? 0 : acc_output_hold;
end

endmodule
*/