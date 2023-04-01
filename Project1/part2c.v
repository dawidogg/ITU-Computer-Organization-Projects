`include "part1.v"

module ARF(
  input[7:0]      i,
  input[1:0]      out_b_sel,
  input[1:0]      out_a_sel,
  input[1:0]      funsel,
  input[3:0]      r_sel,
  output reg[7:0] out_a,
  output reg[7:0] out_b
);

  register #(.NBits(8)) PC (
    .funsel (funsel),
    .i      (i     )
  );

  register #(.NBits(8)) AR (
    .funsel (funsel),
    .i      (i     )
  );

  register #(.NBits(8)) SP (
    .funsel (funsel),
    .i      (i     )
  );

  register #(.NBits(8)) PC_past (
    .funsel (funsel),
    .i      (i     )
  );

  assign {AR.e,  SP.e, PC_past.e, PC.e} = r_sel;

  always @(*) begin
    case (out_a_sel)
      2'b00: out_a = AR.q;
      2'b01: out_a = SP.q;
      2'b10: out_a = PC_past.q;
      2'b11: out_a = PC.q;
    endcase
    
    case (out_b_sel)
      2'b00: out_b = AR.q;
      2'b01: out_b = SP.q;
      2'b10: out_b = PC_past.q;
      2'b11: out_b = PC.q;
    endcase
  end

endmodule