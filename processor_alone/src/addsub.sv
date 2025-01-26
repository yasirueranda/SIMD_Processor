module addsub (
    input logic clk,rst,
    input logic [31:0] a,
    input logic [31:0] b,
    output logic [31:0] out
);

reg [31:0] result_reg;

always_ff @(posedge clk) begin
    if(rst) begin
        result_reg <= 0;
    end else begin
        result_reg <= a + b;
    end
end

assign out = result_reg;

endmodule