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
    reg[2:0] O1Sel, O2Sel;
    reg[1:0] FunSel;
    reg[3:0] RSel, TSel;
    wire[7:0] i,O1, O2;
    //i = 8'b00000100;
    part2b test_module(O1Sel, O2Sel, FunSel, RSel, TSel, 8'b00000100, O1, O2);

    task displayHead;
        $display("%6s %6s %6s %6s %6s", "Enable", "L'/H", "FunSel","Input","Output");
    endtask
    
    task displayLine;
        $display({50{"-"}});
    endtask
        
    initial begin
        $display("TEST\n");
        O1Sel = 3'b111; O2Sel = 3'b000; // o1 is r4 initially and o2 is t1
        FunSel = 2'b11;//increment
        RSel = 4'b0001; TSel = 4'b0000;//only R4 and T1 is enabled
        $monitor("%6s &6s %6s &6s &6s %6s %6s","O1Sel", "O2Sel", "FunSel", "RSel", "TSel", "O1","O2");
    
        RSel = 4'b0000; #62.5; 
        RSel = 4'b0001; #62.5; 
        RSel = 4'b0010; #62.5;
        RSel = 4'b0011; #62.5; 
        
        RSel = 4'b0000; #62.5; 
        RSel = 4'b0001; #62.5; 
        RSel = 4'b0010; #62.5;
        RSel = 4'b0011; #62.5;
        
        //switching O1 to T1
        O1Sel = 3'b000;#62.5
        
        RSel = 4'b0000; #62.5; 
        RSel = 4'b0001; #62.5; 
        RSel = 4'b0010; #62.5;
        RSel = 4'b0011; #62.5; 
        
        RSel = 4'b0000; #62.5; 
        RSel = 4'b0001; #62.5; 
        RSel = 4'b0010; #62.5;
        RSel = 4'b0011; #62.5;
        $finish;
    
    end

endmodule
