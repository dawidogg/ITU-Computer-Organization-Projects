`include "part2a.v"

module part2a_tb;
reg clk;
reg[7:0] i_half;
reg[1:0] funsel;
reg e, l_h;
wire[15:0] ir_out;

IR_16_bit uut(
  .clk    (clk    ),
  .i_half (i_half ),
  .funsel (funsel ),
  .e      (e      ),
  .l_h    (l_h    ),
  .ir_out (ir_out )
);

always #5 clk = ~clk;

task displayHead;
  $display("%6s %6s %6s %6s %6s %6s", "Clock", "Enable", "L'/H", "FunSel","Input","Output");
endtask

task displayLine;
  $display({50{"-"}});
endtask

task load(input[7:0] a, input[7:0] b);
begin
  funsel = 2'b00; 
  #10;

  funsel = 2'b01;
  l_h = 1'b0; i_half = b;
  #10;

  l_h = 1'b1; i_half = a;
  #10;
end
endtask;

initial begin
  $dumpvars;
  $display("Testing 16-bit instruction register");
  $monitor("%6b %6b %6b %6b   0x%h 0x%h%h", clk, e, l_h, funsel, i_half, ir_out[15:8], ir_out[7:0]);
  e = 1'b1; 
  clk = 0;

  $display("\nLoad & clear test");
  displayLine;
  displayHead;
  load(8'h33, 8'haa);
  displayLine;
  displayHead;
  load(8'h4c, 8'h4c);
  displayLine;
  displayHead;
  load(8'h66, 8'h55);
  displayLine;
  displayHead;
  load(8'h01, 8'hf0);
  displayLine;

  $display("\nIncrement test");
  displayLine;
  displayHead;
  funsel = 2'b00; #10;
  funsel = 2'b11;
  #100;

  $display("\nDecrement test");
  displayLine;
  displayHead;
  funsel = 2'b00; #10;
  funsel = 2'b10;
  #100;
  $finish;
end

endmodule