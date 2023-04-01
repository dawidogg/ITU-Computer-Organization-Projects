`include "part2a.v"

module part2a_tb;
reg[7:0] i_half;
reg[1:0] funsel;
reg e, l_h;
wire[15:0] ir_out;

IR_16_bit uut(
  .i_half (i_half ),
  .funsel (funsel ),
  .e      (e      ),
  .l_h    (l_h    ),
  .ir_out (ir_out )
);

task displayHead;
  $display("%6s %6s %6s %6s %6s", "Enable", "L'/H", "FunSel","Input","Output");
endtask

task displayLine;
  $display({50{"-"}});
endtask

task load(input[7:0] a, b);
begin
  e = 1;
  funsel = 2'b00; #5; 
  e = 0; #5;
  funsel = 2'b01;
  l_h = 1'b0; i_half = b;
  #5;
  e = 1; #5; 
  e = 0; #5;
  l_h = 1'b1; i_half = a;
  #5; 
  e = 1; #5;
  e = 0; #5;
end
endtask;

initial begin
  $dumpfile("dump.vcd"); $dumpvars;
  $display("Testing 16-bit instruction register");
  $monitor("%6b %6b %6b   0x%h 0x%h", e, l_h, funsel, i_half, ir_out);
  e = 1'b1; 

  $display("\nLoad & clear test");
  displayLine;
  displayHead;
  load(8'h33, 8'haa); #20;
  displayLine;
  displayHead;
  load(8'h10, 8'h4c); #20;
  displayLine;
  displayHead;
  load(8'h66, 8'h55); #20;
  displayLine;
  displayHead;
  load(8'h01, 8'hf0); #20;
  displayLine;

  $display("\nIncrement test");
  displayLine;
  displayHead;
  funsel = 2'b00; #5;
  funsel = 2'b11;
  repeat(50) #5 e = ~e;

  $display("\nDecrement test");
  displayLine;
  displayHead;
  funsel = 2'b00; #5;
  funsel = 2'b10;
  repeat(50) #5 e = ~e;
  
end

endmodule