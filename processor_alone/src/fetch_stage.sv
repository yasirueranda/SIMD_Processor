module fetch_stage#(
    parameter  IMEM_DEPTH = 2048,
    localparam PC_LEN  = $clog2(2*IMEM_DEPTH)
  
)(
    input logic rstn, clk, start,
    output logic [11:0] imem_read_data,
    
    //instruction mem
    output logic [(PC_LEN-1):0] instr_addr,
    input logic [15:0] instr_dout,
    output logic instr_en
);

//fixed parameters
localparam ILEN = 12; //instruction length
localparam OPCODE_LEN = 4;

logic [PC_LEN-1:0] pc;
logic start_buffer;

assign imem_read_data = instr_dout[11:0];
assign instr_en = 1'b1;

always_ff@(posedge clk) begin
    if (!rstn) begin
        pc <= 0;
        start_buffer <= 0;
    end
    else begin
        if (start_buffer == 1) begin
            if (imem_read_data[OPCODE_LEN-1:0] != 4'b1010)
                pc <= pc + 1;
            else begin
                start_buffer <= 0;
                pc <= 0;
            end
        end
        else begin
            if (start == 1) begin
                pc <= 0;
                start_buffer <= 1;
            end
        end 
    end 
end

assign instr_addr = pc;

endmodule