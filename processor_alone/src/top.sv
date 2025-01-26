module top (
    input logic rstn, clk, start,
    output logic stop
);

localparam PE_ELEMENTS = 16;
localparam DMEM_DEPTH = 256;
localparam IMEM_DEPTH = 1024;
localparam DATA_LEN = 32;   


//imem
logic [($clog2(2*IMEM_DEPTH)-1):0] instr_addr;
logic [15:0] instr_dout;
logic instr_en;
//mat_a
logic [($clog2(DMEM_DEPTH/PE_ELEMENTS)-1):0] mat_a_addr;
logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] mat_a_dout;
logic mat_a_en;
//mat_b
logic [($clog2(DMEM_DEPTH/PE_ELEMENTS)-1):0] mat_b_addr;
logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] mat_b_dout;
logic mat_b_en;
//mat_res
logic [($clog2(DMEM_DEPTH/PE_ELEMENTS)-1):0] mat_res_addr;
logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] mat_res_din;
logic mat_res_en;

logic [31:0] doutb;


proc #(
    .PE_ELEMENTS(PE_ELEMENTS),
    .DMEM_DEPTH(DMEM_DEPTH),
    .IMEM_DEPTH(IMEM_DEPTH),
    .DATA_LEN(DATA_LEN)   
) processor(
    .rstn(rstn), 
    .clk(clk), 
    .start(start),
    .stop(stop),
    //imem
    .instr_addr(instr_addr),
    .instr_dout(instr_dout),
    .instr_en(instr_en),
    //mat_a
    .mat_a_addr(mat_a_addr),
    .mat_a_dout(mat_a_dout),
    .mat_a_en(mat_a_en),
    //mat_b
    .mat_b_addr(mat_b_addr),
    .mat_b_dout(mat_b_dout),
    .mat_b_en(mat_b_en),
    //mat_res
    .mat_res_addr(mat_res_addr),
    .mat_res_din(mat_res_din),
    .mat_res_en(mat_res_en) 
);

Ram_inst ram_imem (
    .clkb(clk),
    .enb(instr_en),
    .addrb(instr_addr),
    .doutb(instr_dout),
    .addra(11'b000000000000),
    .clka(clk),
    .dina(32'h00000000),
    .ena(1'b0),
    .wea(1'b0)
);

Ram_A ram_a (
    .clkb(clk),
    .enb(mat_a_en),
    .addrb(mat_a_addr),
    .doutb(mat_a_dout),
    .addra(10'b0000000000),
    .clka(clk),
    .dina(32'h00000000),
    .ena(1'b0),
    .wea(1'b0)
);

Ram_B ram_b (
    .clkb(clk),
    .enb(mat_b_en),
    .addrb(mat_b_addr),
    .doutb(mat_b_dout),
    .addra(10'b0000000000),
    .clka(clk),
    .dina(32'h00000000),
    .ena(1'b0),
    .wea(1'b0)
);

Ram_C ram_c (
    .clka(clk),
    .ena(1'b0),
    .addra(mat_res_addr),
    .wea(mat_res_en),
    .dina(mat_res_din),
    .addrb(10'b0000000000),
    .clkb(clk),
    .doutb(doutb),
    .enb(1'b0)
);

endmodule