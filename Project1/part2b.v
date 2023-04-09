`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2023 01:47:39 PM
// Design Name: 
// Module Name: part2b
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


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


  register #(.NBits(8)) R1(.funsel(FunSel), .e(R1e), .i(i), .q(R1out), .clk(clk));
  register #(.NBits(8)) R2(.funsel(FunSel), .e(R2e), .i(i), .q(R2out), .clk(clk));
  register #(.NBits(8)) R3(.funsel(FunSel), .e(R3e), .i(i), .q(R3out), .clk(clk));
  register #(.NBits(8)) R4(.funsel(FunSel), .e(R4e), .i(i), .q(R4out), .clk(clk));
  register #(.NBits(8)) T1(.funsel(FunSel), .e(T1e), .i(i), .q(T1out), .clk(clk));
  register #(.NBits(8)) T2(.funsel(FunSel), .e(T2e), .i(i), .q(T2out), .clk(clk));
  register #(.NBits(8)) T3(.funsel(FunSel), .e(T3e), .i(i), .q(T3out), .clk(clk));
  register #(.NBits(8)) T4(.funsel(FunSel), .e(T4e), .i(i), .q(T4out), .clk(clk));



  always @(posedge clk) begin
    {R1e, R2e, R3e, R4e} = RSel;
    {T1e, T2e, T3e, T4e} = TSel;
    
    case (O1Sel)
      3'b000:  O1 = T1out;
      3'b001:  O1 = T2out;
      3'b010:  O1 = T3out;
      3'b011:  O1 = T4out;
      3'b100:  O1 = R1out;
      3'b101:  O1 = R2out;
      3'b110:  O1 = R3out;
      3'b111:  O1 = R4out;
    endcase
    case (O2Sel)
      3'b000:  O2 = T1out;
      3'b001:  O2 = T2out;
      3'b010:  O2 = T3out;
      3'b011:  O2 = T4out;
      3'b100:  O2 = R1out;
      3'b101:  O2 = R2out;
      3'b110:  O2 = R3out;
      3'b111:  O2 = R4out;
    endcase

    end
endmodule