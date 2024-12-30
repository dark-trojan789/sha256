module s0(
    input wire [31:0]w,
    output wire [31:0]s0_val
);
    assign s0_val = ( {w[6:0],w[31:7]} ^ {w[17:0],w[31:18]} ^ w>>3 );

endmodule//small sigma 0

module s1 (
    input wire [31:0]w,
    output wire [31:0]s1_val
);
    assign s1_val = ( {w[16:0],w[31:17]} ^ {w[18:0],w[31:19]} ^ w>>10 );
    
endmodule//small sigma 1

module w_new(
    input [31:0] w_1,
    input [31:0] w_14,
    input [31:0] w_0,
    input [31:0] w_9,
    output [31:0]w_new
);
    wire [31:0]s0_val, s1_val;
    s0 s0(.w(w_1),.s0_val(s0_val));
    s1 s1(.w(w_14),.s1_val(s1_val));
    assign w_new = w_0 + s0_val + w_9 + s1_val;
endmodule//new w 

module S0 (
    input [31:0]a,
    output [31:0]S0_val
);
    assign S0_val = ({a[1:0], a[31:2]} ^ {a[12:0], a[31:13]} ^ {a[21:0], a[31:22]});

endmodule//big sigma 0

module S1 (
    input [31:0]e,
    output [31:0]S0_val
);
    assign S0_val = ({e[5:0], e[31:6]} ^ {e[10:0], e[31:11]} ^ {e[24:0], e[31:25]});

endmodule//big sigma 1

module ch (
    input [31:0] e,
    input [31:0] f,
    input [31:0] g,
    output [31:0] ch_val
);
    assign ch_val = (e & f) ^ (~e & g);
endmodule // choose function

module maj (
    input [31:0] a,
    input [31:0] b,
    input [31:0] c,
    output [31:0] maj_val
);
    assign maj_val = (a & b) ^ (a & c) ^ (b & c);
endmodule // majority function

module w_generator (
    input wire clk,
    input wire rst,
    input wire [511:0] message,
    input wire start,
    output wire [31:0] w_i,
    output reg done
    //output wire [31:0]w_next_val
);

    reg [31:0] w [0:15];
    wire [31:0] next_w;
    reg [6:0] counter; 
    
    // Calculate next w using existing w_new module
    w_new w_calc(
        .w_14(w[14]),     
        .w_1(w[1]),     
        .w_0(w[0]),     
        .w_9(w[9]),      
        .w_new(next_w)
    );
    //assign w_next_val = w[14];
    // Assign output
    assign w_i = (counter < 16) ? message[511-32*counter -: 32] : w[15];
    
    integer i;
    always @(posedge clk or posedge rst or negedge start) begin
        if (rst) begin
            // Reset all registers
            for (i = 0; i < 16; i = i + 1) begin
                w[i] <= 32'b0;
            end
            counter <= 0;
            done <= 0;
        end
        else begin
            // Load initial message
            if (counter < 64) begin
                if(counter < 15) begin
                    for (i = 0; i < 16; i = i + 1)
                        w[i] <= message[511-32*i -: 32];
                end
                else if (counter >= 15) begin
                        // Shift registers and insert new value
                        for (i = 0; i < 15; i = i + 1)
                            w[i] <= w[i+1];
                        w[15] <= next_w;
                end
                if (counter == 63) begin
                    done <= 1;
                    w[15]<=0;
                    //counter <= 0;
                end

                counter <= counter + 1;
            end
            else if(counter == 64) begin
                w[15]<=0;
                counter <= counter + 1;
                //counter<=0;
            end
            else if (counter == 65) begin
                w[15]<=0;
                counter<=0;
            end
            //counter <= 0;
            //done <= 0;
        end
        // else if (~start) begin
        //     //counter <= counter;
        // end
        // else if (counter < 64) begin
        //     if (counter >= 16) begin
        //         // Shift registers and insert new value
        //         for (i = 0; i < 15; i = i + 1)
        //             w[i] <= w[i+1];
        //         w[15] <= next_w;
        //     end
        //     counter <= counter + 1;
        //     if (counter == 63) done <= 1;
        // end
    end

endmodule//w_i generator

module sha256 (
    //inputs ports
    input [511:0]message,
    input [63:0]block,  // Total number of blocks to process
    input clk,
    input rst,

    //output ports
    output wire [255:0]hash,
    output reg hash_valid,
    output reg next_block_read_rdy
);

    // Constants - Initial hash values
    parameter H0 = 32'h6a09e667;
    parameter H1 = 32'hbb67ae85;
    parameter H2 = 32'h3c6ef372;
    parameter H3 = 32'ha54ff53a;
    parameter H4 = 32'h510e527f;
    parameter H5 = 32'h9b05688c;
    parameter H6 = 32'h1f83d9ab;
    parameter H7 = 32'h5be0cd19;

    // Round constants K
    reg [31:0] k [0:63];
    initial begin
        k[0] = 32'h428a2f98; k[1] = 32'h71374491; k[2] = 32'hb5c0fbcf; k[3] = 32'he9b5dba5;
        k[4] = 32'h3956c25b; k[5] = 32'h59f111f1; k[6] = 32'h923f82a4; k[7] = 32'hab1c5ed5;
        k[8] = 32'hd807aa98; k[9] = 32'h12835b01; k[10] = 32'h243185be; k[11] = 32'h550c7dc3;
        k[12] = 32'h72be5d74; k[13] = 32'h80deb1fe; k[14] = 32'h9bdc06a7; k[15] = 32'hc19bf174;
        k[16] = 32'he49b69c1; k[17] = 32'hefbe4786; k[18] = 32'h0fc19dc6; k[19] = 32'h240ca1cc;
        k[20] = 32'h2de92c6f; k[21] = 32'h4a7484aa; k[22] = 32'h5cb0a9dc; k[23] = 32'h76f988da;
        k[24] = 32'h983e5152; k[25] = 32'ha831c66d; k[26] = 32'hb00327c8; k[27] = 32'hbf597fc7;
        k[28] = 32'hc6e00bf3; k[29] = 32'hd5a79147; k[30] = 32'h06ca6351; k[31] = 32'h14292967;
        k[32] = 32'h27b70a85; k[33] = 32'h2e1b2138; k[34] = 32'h4d2c6dfc; k[35] = 32'h53380d13;
        k[36] = 32'h650a7354; k[37] = 32'h766a0abb; k[38] = 32'h81c2c92e; k[39] = 32'h92722c85;
        k[40] = 32'ha2bfe8a1; k[41] = 32'ha81a664b; k[42] = 32'hc24b8b70; k[43] = 32'hc76c51a3;
        k[44] = 32'hd192e819; k[45] = 32'hd6990624; k[46] = 32'hf40e3585; k[47] = 32'h106aa070;
        k[48] = 32'h19a4c116; k[49] = 32'h1e376c08; k[50] = 32'h2748774c; k[51] = 32'h34b0bcb5;
        k[52] = 32'h391c0cb3; k[53] = 32'h4ed8aa4a; k[54] = 32'h5b9cca4f; k[55] = 32'h682e6ff3;
        k[56] = 32'h748f82ee; k[57] = 32'h78a5636f; k[58] = 32'h84c87814; k[59] = 32'h8cc70208;
        k[60] = 32'h90befffa; k[61] = 32'ha4506ceb; k[62] = 32'hbef9a3f7; k[63] = 32'hc67178f2;
    end

    // Internal registers
    reg [31:0] a, b, c, d, e, f, g, h;
    reg [31:0] h0, h1, h2, h3, h4, h5, h6, h7;
    
    // Block counter and total blocks
    reg [63:0] current_block;
    
    // State machine states
    reg [2:0] state;
    parameter IDLE = 3'b000;
    parameter INIT = 3'b001;
    parameter PROCESS = 3'b010;
    parameter UPDATE = 3'b011;
    parameter DONE = 3'b100;

    // Counter for rounds
    reg [6:0] round;
    
    // W generator signals
    wire [31:0] w_i;
    wire w_done;
    reg w_start;
    reg w_rst;

    // Intermediate calculation wires
    wire [31:0] S1, S0, ch_out, maj_out;
    wire [31:0] t1, t2;

    // Instantiate needed modules
    w_generator w_gen (
        .clk(clk),
        .rst(w_rst),
        .message(message),
        .start(w_start),
        .w_i(w_i),
        .done(w_done)
    );

    S1 sig1 (.e(e), .S0_val(S1));
    S0 sig0 (.a(a), .S0_val(S0));
    ch ch_func (.e(e), .f(f), .g(g), .ch_val(ch_out));
    maj maj_func (.a(a), .b(b), .c( c), .maj_val(maj_out));

    // reg [31:0]k_i;
    // always @(posedge clk) begin
    //     if(w_rst || rst) begin
    //         k_i <= k[0];
    //     end
    //     if(round <= 7'd62) begin
    //         k_i <= k[round + 1];
    //     end
    //     else if(round>63) begin
    //        k_i = k[0]; 
    //     end
    //     else begin
    //         k_i <= 32'b0;
    //     end
    // end
    wire [31:0]k_i = k[round<64?round:0];
    // Calculate T1 and T2
    assign t1 = h + S1 + ch_out + k[round<64?round:0] + w_i;//k[round<64?round:0]
    assign t2 = S0 + maj_out;
    assign hash = {h0, h1, h2, h3, h4, h5, h6, h7};
    // always @* begin
    //     if(rst)
    //         w_rst <= 1;
    // end
    always @(posedge clk, posedge rst) begin
        if(rst) begin
            round <= 0;
            current_block <= 1;
            w_start <= 1;
            hash_valid<=0;
            a <= H0;
            b <= H1;
            c <= H2;
            d <= H3;
            e <= H4;
            f <= H5;
            g <= H6;
            h <= H7;

            h0 <= 32'h6a09e667;  
            h1 <= 32'hbb67ae85;
            h2 <= 32'h3c6ef372;
            h3 <= 32'ha54ff53a;
            h4 <= 32'h510e527f;
            h5 <= 32'h9b05688c;
            h6 <= 32'h1f83d9ab;
            h7 <= 32'h5be0cd19;
        end
        else if(round <= 63) begin
            if(round == 63) begin
                // w_start <= 0;
                next_block_read_rdy <= 1;
                //w_rst <= 1;
                // if(current_block == 2) begin
                //     h0 <= h0 + a;
                //     h1 <= h1 + b;
                //     h2 <= h2 + c;
                //     h3 <= h3 + d;
                //     h4 <= h4 + e;
                //     h5 <= h5 + f;
                //     h6 <= h6 + g;
                //     h7 <= h7 + h;
                // end
            end 
            else if(round<63) begin
                next_block_read_rdy <= 0;
                w_rst <= 0;
            end
            w_start <= 1;
            round <= round + 1;
            
            h <= g;
            g <= f;
            f <= e;
            e <= d + t1;
            d <= c;
            c <= b;
            b <= a;
            a <= t1+ t2;
        end
        else if (round == 64) begin
            if(current_block == block) begin
                w_rst <= 1;
                round <= 0;
                hash_valid <= 1;
                h0 <= h0 + a;
                h1 <= h1 + b;
                h2 <= h2 + c;
                h3 <= h3 + d;
                h4 <= h4 + e;
                h5 <= h5 + f;
                h6 <= h6 + g;
                h7 <= h7 + h;
            end
            else begin 
                round <= round+1;
                //current_block <= current_block + 1;
                //w_start <= 1;
                w_rst <= 1;
                next_block_read_rdy <= 0;

                h0 <= h0 + a;
                h1 <= h1 + b;
                h2 <= h2 + c;
                h3 <= h3 + d;
                h4 <= h4 + e;
                h5 <= h5 + f;
                h6 <= h6 + g;
                h7 <= h7 + h;

                a <= h0;
                b <= h1;
                c <= h2;
                d <= h3;
                e <= h4;
                f <= h5;
                g <= h6;
                h <= h7;
            end
        end
        else if (round == 65)begin
            round <= 0;
            current_block <= current_block + 1;
            //w_start <= 1;
            w_rst <= 0;
            next_block_read_rdy <= 0;
            
            a <= h0;
            b <= h1;
            c <= h2;
            d <= h3;
            e <= h4;
            f <= h5;
            g <= h6;
            h <= h7;
        
        end
        else round <= round + 1;
        // else if (round > 63 && current_block == block) begin
        //     hash_valid <= 1;
        //     h0 <= h0 + a;
        //     h1 <= h1 + b;
        //     h2 <= h2 + c;
        //     h3 <= h3 + d;
        //     h4 <= h4 + e;
        //     h5 <= h5 + f;
        //     h6 <= h6 + g;
        //     h7 <= h7 + h;

        // end
    end

endmodule
