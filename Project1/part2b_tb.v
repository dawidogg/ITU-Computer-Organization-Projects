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
    reg[3:0] RSel = 4'b1111, TSel = 4'b1111;
    reg[1:0] FunSel;
    reg[7:0] i = 8'b00010100;
    wire[7:0] O1, O2;
    RF test_module(O1Sel, O2Sel, FunSel, RSel, TSel, i, O1, O2);
    
    reg[7:0] clk = 8'b00000000; 
    reg[3:0]RSel_mask = 4'b1000, TSel_mask = 4'b1000; 
 
    initial begin
    
        //initializing registers   
        FunSel = 2'b01; #10;// must set funsel clear or load to have initial values inside registers
        assign RSel = RSel_mask&clk; assign TSel = TSel_mask&clk; 
        O1Sel = 3'b100; O2Sel = 3'b000; //R1 and T1
        
    
        // test increment
        FunSel = 2'b11;
        repeat(12) begin clk = ~clk; #25; end

        // test O1/O2 & register switch and decrement
        FunSel = 2'b10; //decrement
        RSel_mask = 4'b1111; TSel_mask = 4'b0100; //all and T2
        O1Sel = 3'b001; O2Sel = 3'b001;#100; //T2 and T2
        repeat(4) begin clk = ~clk; #25; end
        
        //only o2 should increment
        FunSel = 2'b11; //increment
        RSel_mask = 4'b0000; TSel_mask = 4'b0001; //none and T4
        O1Sel = 3'b111; O2Sel = 3'b011;#100 // R4 and T4 (O1 must not change)
        repeat(5) begin clk = ~clk; #25; end
        
        //loading i to every register
        RSel_mask = 4'b1111; TSel_mask = 4'b1111; //all and all
        FunSel = 2'b01; #10; //load
        
        //disabling every register
        FunSel = 2'b11; //increment
        RSel_mask = 4'b0000; TSel_mask = 4'b0000; //none and none; (nothing will change)
        O1Sel = 3'b101; O2Sel = 3'b010; //R2 and T3
        repeat(5) begin clk = ~clk; #25; end
    
    end

endmodule
