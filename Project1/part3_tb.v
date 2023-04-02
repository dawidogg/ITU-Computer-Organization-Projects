`timescale 1ns / 1ps

module alu_tb;
  reg[7:0]  a;
  reg[7:0]  b;
  reg[3:0]  funsel;
  reg       clk;
  wire[7:0] outalu;
  wire[3:0] zcno;
  
  alu ALU(
    .A(a),
    .B(b),
    .FunSel(funsel),
    .CLK(clk),
    .OutALU(outalu),
    .ZCNO(zcno)
  );
  
  task loopFunSel;
  begin
    funsel = 4'h0;
    repeat(15) begin
      #10; funsel = funsel + 1;
    end
  end
  endtask
 
  always #5 clk = ~clk;
  
  initial begin
    clk = 1'b0;
    
    // Test each function
    a = 8'h05; b = 8'h02;
    loopFunSel;
    
    // Test overflow
    #10;
    a = 8'h7F; b = 8'h01;
    funsel = 4'h4;
    #20
    if(zcno[0])
        $display("\nOverflow detected.");
  end
endmodule
