module summation_tree #(
    parameter PE_ELEMENTS = 4, // Number of processing elements
    parameter DATA_LEN = 32   // Data width
)(
    input  logic [DATA_LEN-1:0] pe_out[PE_ELEMENTS-1:0],
    input  logic                clk,
    input  logic                rstn,
    output logic [DATA_LEN-1:0] sum_out
);

    // Calculate the number of stages
    localparam NUM_STAGES = $clog2(PE_ELEMENTS); // Number of stages in the tree

    // Define a multidimensional array for the summation tree
    logic [DATA_LEN-1:0] sumstage[NUM_STAGES-1:0][PE_ELEMENTS-1:0];

    // Assign PE outputs to the first stage of the tree
    genvar i, j;
    generate
        for (i = 0; i < PE_ELEMENTS; i++) begin : init_stage
            assign sumstage[0][i] = pe_out[i];
        end
    endgenerate

    // Generate the summation stages
    generate
        for (i = 1; i < NUM_STAGES; i++) begin : summation_stages
            localparam VAR = PE_ELEMENTS >> i; // Number of summations in this stage
            for (j = 0; j < VAR; j++) begin : adders
                addsub adder (
                    .clk(clk),
                    .rst(!rstn),
                    .a(sumstage[i-1][2*j]),
                    .b(sumstage[i-1][2*j+1]),
                    .out(sumstage[i][j])
                );
            end
        end
    endgenerate
    
    addsub lastadder (
                    .clk(clk),
                    .rst(!rstn),
                    .a(sumstage[NUM_STAGES-1][0]),
                    .b(sumstage[NUM_STAGES-1][1]),
                    .out(sum_out)
    );

endmodule
