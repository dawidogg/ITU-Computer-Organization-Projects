`timescale 1ns / 1ps

module part2b_tb();

    reg[2:0] O1Sel = 3'b100, O2Sel = 3'b000; //R1 and T1
    reg[3:0] RSel, TSel;
    reg[1:0] FunSel;
    reg[7:0] i = 8'b00010100;
    wire[7:0] O1, O2;
    reg[0:0] clk = 1'b0; 
    
    RF test_module(.O1Sel(O1Sel),
                   .O2Sel(O2Sel),
                   .FunSel(FunSel),
                   .RSel(RSel),
                   .TSel(TSel),
                   .i(i),
                   .clk(clk),
                   .O1(O1),
                   .O2(O2));
    
    always #13 clk = ~clk;
 
    initial begin
    
        //initializing registers   
        RSel = 4'b1111; TSel = 4'b1111;
        O1Sel = 3'b100; O2Sel = 3'b000;  //R1 and T1
        FunSel = 2'b01; #100;// must set funsel clear or load to have initial values inside registers
    
        // test increment
        FunSel = 2'b11;#100;

        // test O1/O2 & register switch and decrement
        FunSel = 2'b10; //decrement
        RSel = 4'b1111; TSel = 4'b0100; //all and T2
        O1Sel = 3'b001; O2Sel = 3'b001;#100; //T2 and T2
        
        //only o2 should increment
        FunSel = 2'b11; //increment
        RSel = 4'b0000; TSel = 4'b0001; //none and T4
        O1Sel = 3'b111; O2Sel = 3'b011;#100; // R4 and T4 (O1 must not change)
        
        //clearing every register
        RSel = 4'b1111; TSel = 4'b1111; //all and all
        FunSel = 2'b00; #100; //clear
        
        //loading i to every register
        FunSel = 2'b01; #100; //load
        
        //disabling every register
        FunSel = 2'b11; //increment
        RSel = 4'b0000; TSel = 4'b0000; //none and none; (nothing will change)
        O1Sel = 3'b101; O2Sel = 3'b010;#100; //R2 and T3
        
        //enabling all registers
        RSel = 4'b1111; TSel = 4'b1111; //all and all; 
    
    end

endmodule