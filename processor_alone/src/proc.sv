module proc #(
    parameter PE_ELEMENTS = 4,
    parameter DMEM_DEPTH = 1024,
    parameter IMEM_DEPTH = 2048,
    parameter DATA_LEN = 32   
)(
    input logic rstn, clk, start,
    output logic stop,
    //imem
    output logic [($clog2(2*IMEM_DEPTH)-1):0] instr_addr,
    input logic [15:0] instr_dout,
    output logic instr_en,
    //mat_a
    output logic [($clog2(DMEM_DEPTH/PE_ELEMENTS)-1):0] mat_a_addr,
    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] mat_a_dout,
    output logic mat_a_en,
    //mat_b
    output logic [($clog2(DMEM_DEPTH/PE_ELEMENTS)-1):0] mat_b_addr,
    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] mat_b_dout,
    output logic mat_b_en,
    //mat_res
    output logic [($clog2(DMEM_DEPTH/PE_ELEMENTS)-1):0] mat_res_addr,
    output logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] mat_res_din,
    output logic mat_res_en 
);

localparam OPCODE_LEN = 4;
localparam PC_LEN  = $clog2(2*IMEM_DEPTH);

logic [11:0] imem_read_data;
logic [OPCODE_LEN-1:0] opcode;
logic [PE_ELEMENTS-1:0][DATA_LEN-1:0]data_a;
logic [PE_ELEMENTS-1:0][DATA_LEN-1:0]data_b;
logic [($clog2(DMEM_DEPTH/PE_ELEMENTS)-1):0]write_addr;
logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] result_stage_1;
logic result_stage_1_valid;
logic [DATA_LEN-1:0] result_stage_2;
logic result_stage_2_valid;
logic store_result;

fetch_stage #(
    .IMEM_DEPTH(IMEM_DEPTH)
) fetch (
    .rstn(rstn),
    .clk(clk),
    .start(start),
    .imem_read_data(imem_read_data),
    .instr_addr(instr_addr),
    .instr_dout(instr_dout),
    .instr_en(instr_en)
);

decode_stage #(
    .PE_ELEMENTS(PE_ELEMENTS),
    .DMEM_DEPTH(DMEM_DEPTH),
    .DATA_LEN(DATA_LEN)
)decode(
    .rstn(rstn & !start),
    .clk(clk),
    .imem_read_data(imem_read_data),
    .opcode(opcode),
    .data_a(data_a),
    .data_b(data_b),
    .write_addr(write_addr),
    .mat_a_addr(mat_a_addr),
    .mat_a_dout(mat_a_dout),
    .mat_a_en(mat_a_en),
    .mat_b_addr(mat_b_addr),
    .mat_b_dout(mat_b_dout),
    .mat_b_en(mat_b_en)
);
execute_stage#(
    .PE_ELEMENTS(PE_ELEMENTS),
    .DATA_LEN(DATA_LEN)
) execute(
    .rstn(rstn & !start),
    .clk(clk),
    .opcode(opcode),
    .data_a(data_a),
    .data_b(data_b),
    .result_stage_1(result_stage_1),
    .result_stage_1_valid(result_stage_1_valid),
    .result_stage_2(result_stage_2),
    .result_stage_2_valid(result_stage_2_valid),
    .store_result(store_result),
    .stop(stop)  
);
mem_stage #(
    .PE_ELEMENTS(PE_ELEMENTS),
    .DMEM_DEPTH(DMEM_DEPTH),
    .DATA_LEN(DATA_LEN)
)mem(
    .rstn(rstn & !start),
    .clk(clk),
    .result_stage_1(result_stage_1),
    .result_stage_1_valid(result_stage_1_valid),
    .result_stage_2(result_stage_2),
    .result_stage_2_valid(result_stage_2_valid),
    .store_result(store_result),
    .write_addr(write_addr),
    .mat_res_addr(mat_res_addr),
    .mat_res_din(mat_res_din),
    .mat_res_en(mat_res_en)
);

endmodule