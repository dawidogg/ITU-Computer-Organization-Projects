`include "part1.v"

module register_tb;
  reg clk;
  reg[3:0] input_4;
  wire[3:0] output_4;
  reg[1:0] funsel;
  reg enable;
  
  register #(.NBits(4)) register_4  (
    .clk    (clk            ),
    .funsel (funsel         ),
    .e      (enable         ),
    .i      (input_4        ),
    .q      (output_4       )
  );

  task displayHead;
    $display("%6s %6s %6s %6s %6s", "Clock", "Enable","FunSel","Input","Output");
  endtask

  always #5 clk = ~clk;

  initial begin
    $dumpvars;
    $display("Testing 4-bit register \n");
    clk = 1'b0;
    input_4 = 4'b0;
    funsel = 2'b0;
    enable = 1'b0;
    
    $monitor("%6b %6b %6b %6b %6b", clk, enable, funsel, input_4, output_4);
    
    $display("Load & clear test:");
    displayHead;
    enable = 1'b1;
    funsel = 2'b01; input_4 = 4'b1111; #10; 
    funsel = 2'b00; #10; 
    funsel = 2'b01; input_4 = 4'b1010; #10; 
    funsel = 2'b00; #10; 
    funsel = 2'b01; input_4 = 4'b0001; #10; 
    funsel = 2'b00; #10; 
    funsel = 2'b01; input_4 = 4'b0110; #10; 
    funsel = 2'b00; #10; 
    funsel = 2'b01; input_4 = 4'b0000; #10; 
    funsel = 2'b00; #10; 
    
    $display("\nIncrement test");
    displayHead;
    funsel = 2'b00; #10;
    funsel = 2'b11;
    #170;

    $display("\nDecrement test");
    displayHead;
    funsel = 2'b00; #10;
    funsel = 2'b10;
    #170;
    
    $finish;
  end

endmodule
