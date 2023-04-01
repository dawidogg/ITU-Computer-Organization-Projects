`include "part2c.v"

module part2c_tb;
  integer seed = 315001;
  reg clk = 1'b0;
  reg[7:0] i;
  reg[1:0] out_a_sel, out_b_sel, funsel;
  reg[3:0] r_sel;
  wire[7:0] out_a, out_b;

  ARF uut(
    .i(i),
    .out_a_sel(out_a_sel),
    .out_b_sel(out_b_sel),
    .funsel(funsel),
    .r_sel(r_sel),
    .out_a(out_a),
    .out_b(out_b)
  );
  
  task displayHead;
    $display("%8s %6s %6s %6s %6s %6s %6s", "Input", "FunSel", "RSel","AR", "SP", "PCPrev", "PC");
  endtask

  task showRegistersThroughA; 
  begin
    $write("A:%6h %6b %6b ", i, funsel, r_sel);
    out_a_sel = 2'b00;
    repeat(4) begin
      #5;
      $write("%6h ", out_a);
      out_a_sel = out_a_sel + 1;
    end
    $display;
  end
  endtask

  task showRegistersThroughB; 
  begin
    $write("B:%6h %6b %6b ", i, funsel, r_sel);
    out_b_sel = 2'b00;
    repeat(4) begin
      #5;
      $write("%6h ", out_b);
      out_b_sel = out_b_sel + 1;
    end
    $display;
  end
  endtask

  task displayLine;
    $display({50{"-"}});
  endtask

  task showAll;
  begin
    displayLine;
    displayHead;
    showRegistersThroughA;
    showRegistersThroughB;
  end
  endtask

  initial begin
    //$dumpfile("dump.vcd"); $dumpvars;
    $display("Testing adress register file (ARF)");
    
    $display("\nClear test");
    funsel = 2'b00;
    r_sel = 4'b1111;
    #5;
    r_sel = 4'b0000;
    showAll;

    $display("\nLoad with random numbers test:");
    funsel = 2'b01;
    
    r_sel = 4'b1000; i = $urandom(seed)%(256); #5;
    showAll;

    r_sel = 4'b0100; i = $urandom(seed)%(256); #5;
    showAll;
    
    r_sel = 4'b0010; i = $urandom(seed)%(256); #5;
    showAll;
    
    r_sel = 4'b0001; i = $urandom(seed)%(256); #5;
    showAll;

    $display("\nIncrement with random numbers test:");
    displayLine;
    funsel = 2'b11;
    displayHead;
    repeat(15) begin
      r_sel = 4'b0000; #5;
      r_sel = $urandom(seed)%(64); #5;
      showRegistersThroughA;
    end

    $display("\nDecrement with random numbers test:");
    displayLine;
    funsel = 2'b10;
    displayHead;
    repeat(15) begin
      r_sel = 4'b0000; #5;
      r_sel = $urandom(seed)%(64); #5;
      showRegistersThroughB;
    end
  end

endmodule
