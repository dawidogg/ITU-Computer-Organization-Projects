`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2023 04:56:28 PM
// Design Name: 
// Module Name: part2b_tb
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


module part2b_tb();
    reg[2:0] O1Sel = 3'b100, O2Sel = 3'b000; //R1 and T1
    reg[1:0] FunSel = 2'b11; // increment
    reg[3:0] RSel = 4'b1000, TSel = 4'b1000; //R1 and T1
    reg[7:0] i = 8'b00010100;
    wire[7:0] O1, O2;
    RF test_module(O1Sel, O2Sel, FunSel, RSel, TSel, i, O1, O2);

    reg[0:0]clock = 1'b1;
 
    initial begin

    // test O1/O2 Switches
    //#50;
    FunSel = 2'b00;#50;
    FunSel = 2'b01;#50;
    FunSel = 2'b00;#50;
    FunSel = 2'b01;#50;
    FunSel = 2'b11;#50;
    FunSel = 2'b11;#50;
    
    
    repeat(10) #25 clock = ~clock;

    // test register switches
    

 
    end

endmodule
