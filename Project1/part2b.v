`timescale 1ns / 1ps


//register file
module RF(
  input[2:0]          O1Sel, 
  input[2:0]          O2Sel, 
  input[1:0]          FunSel, 
  input[3:0]          RSel, 
  input[3:0]          TSel, 
  input[7:0]          i,
  input[0:0]          clk,

  output reg[7:0]     O1,
  output reg[7:0]     O2
);

  wire[7:0] R1out, R2out, R3out, R4out;
  wire[7:0] T1out, T2out, T3out, T4out;
  reg[0:0] R1e, R2e, R3e, R4e;
  reg[0:0] T1e, T2e, T3e, T4e;
  reg[0:0] dclk; //delayed clock

  register #(.NBits(8)) R1(.funsel(FunSel), .e(R1e), .i(i), .q(R1out), .clk(dclk));
  register #(.NBits(8)) R2(.funsel(FunSel), .e(R2e), .i(i), .q(R2out), .clk(dclk));
  register #(.NBits(8)) R3(.funsel(FunSel), .e(R3e), .i(i), .q(R3out), .clk(dclk));
  register #(.NBits(8)) R4(.funsel(FunSel), .e(R4e), .i(i), .q(R4out), .clk(dclk));
  register #(.NBits(8)) T1(.funsel(FunSel), .e(T1e), .i(i), .q(T1out), .clk(dclk));
  register #(.NBits(8)) T2(.funsel(FunSel), .e(T2e), .i(i), .q(T2out), .clk(dclk));
  register #(.NBits(8)) T3(.funsel(FunSel), .e(T3e), .i(i), .q(T3out), .clk(dclk));
  register #(.NBits(8)) T4(.funsel(FunSel), .e(T4e), .i(i), .q(T4out), .clk(dclk));


  always @(posedge clk) begin
    dclk = 1'b0;
    {R1e, R2e, R3e, R4e} = RSel;
    {T1e, T2e, T3e, T4e} = TSel;
    #0.01;
    dclk = 1'b1;
    #0.01; //delaying for registers
    case (O1Sel)
      3'b000:  begin  O1 = T1out; end
      3'b001:  begin  O1 = T2out; end
      3'b010:  begin  O1 = T3out; end
      3'b011:  begin  O1 = T4out; end
      3'b100:  begin  O1 = R1out; end
      3'b101:  begin  O1 = R2out; end
      3'b110:  begin  O1 = R3out; end
      3'b111:  begin  O1 = R4out; end
    endcase
    case (O2Sel)
      3'b000:  begin  O2 = T1out; end
      3'b001:  begin  O2 = T2out; end
      3'b010:  begin  O2 = T3out; end
      3'b011:  begin  O2 = T4out; end
      3'b100:  begin  O2 = R1out; end
      3'b101:  begin  O2 = R2out; end
      3'b110:  begin  O2 = R3out; end
      3'b111:  begin  O2 = R4out; end
    endcase
    end
endmodule