module ARF(
  input           clk,
  input[7:0]      i,
  input[1:0]      out_b_sel,
  input[1:0]      out_a_sel,
  input[1:0]      funsel,
  input[3:0]      r_sel,
  output[7:0] out_a,
  output[7:0] out_b
);

  register #(.NBits(8)) PC (
    .clk    (clk),
    .funsel (funsel),
    .i      (i     )
  );

  register #(.NBits(8)) AR (
    .clk    (clk),
    .funsel (funsel),
    .i      (i     )
  );

  register #(.NBits(8)) SP (
    .clk    (clk),
    .funsel (funsel),
    .i      (i     )
  );

  register #(.NBits(8)) PC_past (
    .clk    (clk),
    .funsel (funsel),
    .i      (i     )
  );

  assign {AR.e, SP.e, PC_past.e, PC.e} = r_sel;

  assign out_a = (out_a_sel == 2'b00)? AR.q : 8'bz;
  assign out_a = (out_a_sel == 2'b01)? SP.q : 8'bz;
  assign out_a = (out_a_sel == 2'b10)? PC_past.q : 8'bz;
  assign out_a = (out_a_sel == 2'b11)? PC.q : 8'bz;

  assign out_b = (out_b_sel == 2'b00)? AR.q : 8'bz;
  assign out_b = (out_b_sel == 2'b01)? SP.q : 8'bz;
  assign out_b = (out_b_sel == 2'b10)? PC_past.q : 8'bz;
  assign out_b = (out_b_sel == 2'b11)? PC.q : 8'bz;
endmodule