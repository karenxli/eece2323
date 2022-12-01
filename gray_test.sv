`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2022 06:46:39 PM
// Design Name: 
// Module Name: gray_test
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


module gray_test;
    logic clock, enable, clear;
    logic [1:0] y;
    
    //instantiate
    gray_code gray_code(clock, clear, enable, y);
    
    // clock signals
    initial begin
        clock = 1;
        forever #5 clock = ~clock;
    end
    
    initial begin
        clear = 1;
        #10 clear = 0;
    end
    
    // assign initial values
    initial begin
        $monitor("%d clock = %b, enable = %b, y = %h", $time, clock, enable, y);
        
        #10 enable = 0;
        #10 enable = 1;
        #10
        #10 enable = 0;
        #10
        #10
        #10 enable = 1;
        #10
        #10
        #10
        #10
        #10
        #10 enable = 0;
        #10
        #10 enable = 1;
        #10
        #10
        #10
        #10 $finish;
    end
endmodule
