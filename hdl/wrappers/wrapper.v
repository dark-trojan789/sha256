`include "hdl/sha256.v"
module s0_wrapper(
    input [31:0] w,
    output [31:0] s0_val
);
    s0 s0_inst(.w(w), .s0_val(s0_val));
endmodule

module s1_wrapper(
    input [31:0] w,
    output [31:0] s1_val
);
    s1 s1_inst(.w(w), .s1_val(s1_val));
endmodule

module S0_wrapper(
    input [31:0] a,
    output [31:0] S0_val
);
    S0 S0_inst(.a(a), .S0_val(S0_val));
endmodule

module S1_wrapper(
    input [31:0] e,
    output [31:0] S0_val
);
    S1 S1_inst(.e(e), .S0_val(S0_val));
endmodule

module ch_wrapper(
    input [31:0] e,
    input [31:0] f,
    input [31:0] g,
    output [31:0] ch_val
);
    ch ch_inst(.e(e), .f(f), .g(g), .ch_val(ch_val));
endmodule

module maj_wrapper(
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    output [31:0] maj_val
);
    maj maj_inst(.a(a), .b(b), .c(c), .maj_val(maj_val));
endmodule

module w_new_wrapper(
    input [31:0] w_14,
    input [31:0] w_1,
    input [31:0] w_0,
    input [31:0] w_9,
    output [31:0] w_new
);
    w_new w_new_inst(
        .w_14(w_14),
        .w_1(w_1),
        .w_0(w_0),
        .w_9(w_9),
        .w_new(w_new)
    );
endmodule

module w_generator_wrapper(
    output reg clk,
    input wire rst,
    input wire [511:0] message,
    input wire start,
    output wire [31:0] w_i,
    output wire done
    //output wire [31:0]w_next_val
);
    w_generator w_gen_inst(
        .clk(clk),
        .rst(rst),
        .message(message),
        .start(start),
        .w_i(w_i),
        .done(done)
        //.w_next_val(w_next_val)
    );

    initial begin
        clk = 0;
	    forever begin
		  #5 clk=~clk;
	    end
    end
    
endmodule

module sha256_wrapper (
    input wire [511:0]message,
    input wire [63:0]block,  // Total number of blocks to process
    output reg clk,
    input wire rst,

    //output ports
    output wire [255:0]hash,
    output wire hash_valid,
    output wire next_block_read_rdy
);
    sha256 sha256(
        .message(message),
        .block(block),
        .clk(clk),
        .rst(rst),
        .hash(hash),
        .hash_valid(hash_valid),
        .next_block_read_rdy(next_block_read_rdy)
    );

    initial begin
        $dumpfile("sha256.vcd");
        $dumpvars;
        clk = 1;
	    forever begin
		  #5 clk=~clk;
	    end
    end

endmodule