`include "part1.v"

module register_tb;
  reg[3:0] input_4;
  wire[3:0] output_4;
  reg[1:0] funsel;
  reg enable;
  
  register #(.NBits(4)) register_4  (
    .funsel (funsel         ),
    .e      (enable         ),
    .i      (input_4        ),
    .q      (output_4       )
  );

  task displayHead;
    $display("%6s %6s %6s %6s","Enable","FunSel","Input","Output");
  endtask

  initial begin
    $display("Testing 4-bit register \n");
    input_4 = 4'b0;
    funsel = 2'b0;
    enable = 1'b0;
    
    $monitor("%6b %6b %6b %6b", enable, funsel, input_4, output_4);
    
    $display("Load & clear test:");
    displayHead();
    enable = 1'b1;
    funsel = 2'b01; input_4 = 4'b1111; #5; 
    funsel = 2'b00; #5; 
    funsel = 2'b01; input_4 = 4'b1010; #5; 
    funsel = 2'b00; #5; 
    funsel = 2'b01; input_4 = 4'b0001; #5; 
    funsel = 2'b00; #5; 
    funsel = 2'b01; input_4 = 4'b0110; #5; 
    funsel = 2'b00; #5; 
    funsel = 2'b01; input_4 = 4'b0000; #5; 
    funsel = 2'b00; #5; 
    
    $display("\nIncrement test");
    displayHead();
    funsel = 2'b00; #5;
    funsel = 2'b11;
    repeat(34) #5 enable = ~enable;

    $display("\nDecrement test");
    displayHead();
    funsel = 2'b00; #5;
    funsel = 2'b10;
    repeat(34) #5 enable = ~enable;
  end

endmodule
