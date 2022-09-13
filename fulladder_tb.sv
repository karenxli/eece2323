`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/13/2022 02:23:39 PM
// Design Name: 
// Module Name: fulladder_tb
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


module fulladder_tb();
logic a;
logic b;
logic c_in;
logic sum;
logic c_out;

full_adder_wrapper UUT(.a(a),.b(b),.c_in(c_in ),.sum(sum),.c_out(c_out));

initial begin
    a = 1'b0; b = 1'b0; c_in = 1'b0;
    #100 a = 1'b1; b = 1'b0; c_in = 1'b0;
    #100 a = 1'b0; b = 1'b1; c_in = 1'b0;
    #100 a = 1'b0; b = 1'b0; c_in = 1'b1;
    #100 a = 1'b1; b = 1'b1; c_in = 1'b0;
    #100 a = 1'b1; b = 1'b0; c_in = 1'b1;
    #100 a = 1'b0; b = 1'b1; c_in = 1'b1;
    #100 a = 1'b1; b = 1'b1; c_in = 1'b1;
end
endmodule
