module mem_stage#(
    parameter PE_ELEMENTS = 4,
    parameter DMEM_DEPTH = 1024,
    parameter DATA_LEN = 32,
    localparam DRAM_ADDR_WIDTH  = $clog2(DMEM_DEPTH/PE_ELEMENTS)
)(
    input logic rstn, clk,
    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] result_stage_1,
    input logic result_stage_1_valid,
    input logic [DATA_LEN-1:0] result_stage_2,
    input logic result_stage_2_valid,
    input store_result,
    input logic [DRAM_ADDR_WIDTH-1:0]write_addr,
    //mat_result
    output logic [DRAM_ADDR_WIDTH-1:0] mat_res_addr,
    output logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] mat_res_din,
    output logic mat_res_en
);


logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] result;

// handling outputs from the programming elements
always_ff@(posedge clk) begin
    if (!rstn) begin
        result <= 0;
    end
    else if (result_stage_1_valid && !store_result)
        result <= result_stage_1;
    else if (result_stage_2_valid && !store_result) begin
        result[PE_ELEMENTS-1] <= result_stage_2;

        for (int i=1; i<PE_ELEMENTS; i++) begin
            result[i-1] <= result[i];
        end
    end
end

assign mat_res_addr = write_addr;
assign mat_res_din = result;
assign mat_res_en = store_result;

endmodule