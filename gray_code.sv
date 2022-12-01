`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2022 06:07:05 PM
// Design Name: 
// Module Name: gray_code
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gray_code(
    input logic clock,
    input logic clear,
    input logic enable,
    output logic [1:0] y
    );
    
    typedef enum logic [1:0] {A, B, C, D} states_t;
    states_t state, next_state;
    

    always_ff@(negedge clock, posedge clear)
        if(clear)
            state <= A;
        else
            state <= next_state;
            
    // state transition
    //assign next_state[0] = (~state[1] ^ enable) | (state[0] ^ ~enable);
    //assign next_state[1] = (state[0] ^ enable) | (state[1] ^ ~enable);
    always_comb
        case(state)
            A: if(enable) next_state = B;
                else next_state = state;
            B: if(enable) next_state = D;
                else next_state = state;
            C: if(enable) next_state = A;
                else next_state = state;
            D: if(enable) next_state = C;
                else next_state = state;
       endcase    


    // output transition
    assign y[0] = next_state[0];
    assign y[1] = next_state[1];
endmodule
