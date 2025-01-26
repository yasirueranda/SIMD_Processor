module decode_stage#(
    parameter PE_ELEMENTS = 4,
    parameter DMEM_DEPTH = 1024,
    parameter DATA_LEN = 32,
    localparam DMEM_ADDR_WIDTH  = $clog2(DMEM_DEPTH/PE_ELEMENTS)
)(
    input logic rstn, clk,
    input logic [11:0] imem_read_data,
    output logic [3:0] opcode,
    output logic [PE_ELEMENTS-1:0][DATA_LEN-1:0]data_a,
    output logic [PE_ELEMENTS-1:0][DATA_LEN-1:0]data_b,
    output logic [DMEM_ADDR_WIDTH-1:0]write_addr,
    //mat_a
    output logic [(DMEM_ADDR_WIDTH-1):0] mat_a_addr,
    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] mat_a_dout,
    output logic mat_a_en,
    //mat_b
    output logic [(DMEM_ADDR_WIDTH-1):0] mat_b_addr,
    input logic [PE_ELEMENTS-1:0][DATA_LEN-1:0] mat_b_dout,
    output logic mat_b_en
);

localparam OPCODE_LEN = 4;

typedef enum logic [OPCODE_LEN-1:0] {NOP, LOAD_A, LOAD_B, ADD, SUB, MUL, DOT, BUFFER_RES_1, BUFFER_RES_2,STORE, STOP} OPCODE; 


logic rena, renb,write_addr_buf_en ;
logic [OPCODE_LEN-1:0] opcode_buffer;
logic [DMEM_ADDR_WIDTH-1:0] write_addr_buffer;

// opcode decoding
always_comb begin
    unique0 case (imem_read_data[OPCODE_LEN-1:0])
        STOP: begin
            rena = 0;
            renb = 0;
            write_addr_buf_en = 0; 
        end
        LOAD_A: begin
            rena = 1;
            renb = 0;
            write_addr_buf_en = 0; 
        end
        LOAD_B: begin
            rena = 0;
            renb = 1;
            write_addr_buf_en = 0; 
        end
        ADD: begin
            rena = 0;
            renb = 0;
            write_addr_buf_en = 0; 
        end
        SUB: begin
            rena = 0;
            renb = 0;
            write_addr_buf_en = 0;  
        end
        MUL: begin
            rena = 0;
            renb = 0;
            write_addr_buf_en = 0; 
        end
        DOT: begin
            rena = 0;
            renb = 0;
            write_addr_buf_en = 0;  
        end
        BUFFER_RES_1: begin
            rena = 0;
            renb = 0;
            write_addr_buf_en = 0;  
        end
        BUFFER_RES_2: begin
            rena = 0;
            renb = 0;
            write_addr_buf_en = 0; 
        end
        STORE: begin
            rena = 0;
            renb = 0;
            write_addr_buf_en = 1;  
        end
        default: begin
            rena = 0;
            renb = 0;
            write_addr_buf_en = 0;  
        end
    endcase
end

always_ff@(posedge clk) begin
    if (!rstn) begin
        write_addr_buffer <= 0;
    end else if (write_addr_buf_en == 1) begin
        write_addr_buffer <= imem_read_data[11:OPCODE_LEN];
    end
end

always_ff@(posedge clk) begin
    if (!rstn) begin
        opcode_buffer <= 0;
    end else begin 
        opcode_buffer <= imem_read_data[OPCODE_LEN-1:0];
    end
end

assign mat_a_en = rena;
assign mat_a_addr = imem_read_data[11:4];
assign data_a = mat_a_dout;

assign mat_b_en = renb;
assign mat_b_addr = imem_read_data[11:4];
assign data_b = mat_b_dout;

assign opcode = opcode_buffer;
assign write_addr = write_addr_buffer;

endmodule