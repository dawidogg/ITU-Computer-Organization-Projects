module IR_16_bit (
  input         clk,
  input[7:0]    i_half,
  input[1:0]    funsel,
  input         e,
  input         l_h,
  output[15:0]  ir_out
);
  wire[7:0] demux_1, demux_0;
  assign demux_1 = (l_h)? i_half : 8'bz;
  assign demux_0 = (l_h)? 8'bz : i_half;

  wire[7:0] bh_out;
  wire[7:0] bl_out;
  bufif0 buffer_high[7:0](bh_out, ir_out[15:8], {8{l_h}});
  bufif1 buffer_low[7:0](bl_out, ir_out[7:0], {8{l_h}});

  wire[7:0] high_part, low_part;
  assign high_part = demux_1;
  assign high_part = bh_out;
  assign low_part = demux_0;
  assign low_part = bl_out;

  wire[15:0] i;  
  assign i = {high_part, low_part};

  register #(.NBits(16)) ir (
  .clk    (clk),
  .funsel (funsel ),
  .e      (e      ),
  .i      (i      ),
  .q      (ir_out )
  );

endmodule
