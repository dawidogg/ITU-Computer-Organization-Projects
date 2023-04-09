`include "part1.v"

module IR_16_bit (
  input         clk,
  input[7:0]    i_half,
  input[1:0]    funsel,
  input         e,
  input         l_h,
  output[15:0]  ir_out
);

reg[15:0] i;
reg dclk;

register #(.NBits(16)) ir_low (
  .clk    (dclk),
  .funsel (funsel ),
  .e      (e      ),
  .i      (i      ),
  .q      (ir_out )
);

always @(posedge clk) begin
  dclk = 0;
  if (e & funsel == 2'b01)
    if (l_h)
      i[15:8] = i_half;
    else
      i[7:0] = i_half;
  else 
    i = ir_out;
  #1;
  dclk = 1;
end 

endmodule