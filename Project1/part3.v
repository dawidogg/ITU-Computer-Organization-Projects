`timescale 1ns / 1ps

module alu(
  input[7:0]  A,
  input[7:0]  B,
  input[3:0]  FunSel,
  input       CLK,
  output[7:0] OutALU,
  output[3:0] ZCNO
);

reg[7:0] out;
assign OutALU = out;

reg[3:0] in;
register #(.NBits(4)) zcno (
  .funsel(2'b01),
  .i(in),
  .e(1'b1),
  .clk(CLK),
  .q(ZCNO)
);

always @(*) begin
  case(FunSel)
    4'b0000:begin // A
      out = A;
    end
    4'b0001:begin // B
      out = B;
    end
    4'b0010:begin // NOT A
      out = ~A;
    end
    4'b0011:begin // NOT B
      out = ~B;
    end
    4'b0100:begin // A + B
      if(in[2] != 1'bX)
        {in[2], out} = {A[7], A} + {B[7], B} + {8'h00, in[2]};
      else
        {in[2], out} = {A[7], A} + {B[7], B};
      if((A[7] == B[7]) && (B[7] != out[7])) // Check overflow
        in[0] = 1'b1;
      else 
        in[0] = 1'b0;
    end
    4'b0101:begin // A - B
      {in[2], out} = {A[7], A} - {B[7], B};
      if((A[7] != B[7]) && (B[7] == out[7])) // Check overflow
        in[0] = 1'b1; 
      else 
        in[0] = 1'b0;
    end
    4'b0110:begin // Compare A, B
      {in[2], out} = {A[7], A} - {B[7], B};
      if((A[7] != B[7]) && (B[7] == out[7])) // Check overflow
        in[0] = 1'b1; 
      else 
        in[0] = 1'b0;
      // Comparison
      if(out == 8'h00) 
        out = 8'h00;
      else if(out[7] == in[0]) 
        out = A;
      else
        out = 8'h00;
    end
    4'b0111:begin // A AND B
      out = A & B;
    end
    4'b1000:begin // A OR B
      out = A | B;
    end
    4'b1001:begin // A NAND B
      out = ~(A & B);
    end
    4'b1010:begin // A XOR B
      out = A ^ B;
    end
    4'b1011:begin // LSL A
      out = {A[6:0], 1'b0}; in[2] = A[7];
    end
    4'b1100:begin // LSR A
      out = {1'b0, A[7:1]}; in[2] = A[0];
    end
    4'b1101:begin // ASL A
      out = {A[6:0], 1'b0};
      if(A[7] != A[6]) // Check overflow
        in[0] = 1'b1; 
      else 
        in[0] = 1'b0;
    end
    4'b1110:begin // ASR A
      out = {A[7], A[7:1]};
    end
    4'b1111:begin // CSR A
      out = {in[2], A[7:1]}; in[2] = A[0];
    end
  endcase
  
  if(out == 8'b0) // Check zero output
    in[3] = 1'b1;
  else
    in[3] = 1'b0;
    
  if(out[7] == 1'b1 && FunSel != 4'hE) // Check negative output
    in[1] = 1'b1;
  else
    in[1] = 1'b0;
end
endmodule
