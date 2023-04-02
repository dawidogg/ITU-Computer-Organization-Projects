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

  output[7:0]         O1,
  output[7:0]         O2
);

  wire[7:0] R1out, R2out, R3out, R4out;
  wire[7:0] T1out, T2out, T3out, T4out;
  reg[0:0] R1e, R2e, R3e, R4e;
  reg[0:0] T1e, T2e, T3e, T4e;
  reg[7:0] O1out, O2out;
  assign O1 = O1out; assign O2 = O2out;

  register #(.NBits(8)) R1(.funsel(FunSel), .e(R1e), .i(i), .q(R1out));
  register #(.NBits(8)) R2(.funsel(FunSel), .e(R2e), .i(i), .q(R2out));
  register #(.NBits(8)) R3(.funsel(FunSel), .e(R3e), .i(i), .q(R3out));
  register #(.NBits(8)) R4(.funsel(FunSel), .e(R4e), .i(i), .q(R4out));
  register #(.NBits(8)) T1(.funsel(FunSel), .e(T1e), .i(i), .q(T1out));
  register #(.NBits(8)) T2(.funsel(FunSel), .e(T2e), .i(i), .q(T2out));
  register #(.NBits(8)) T3(.funsel(FunSel), .e(T3e), .i(i), .q(T3out));
  register #(.NBits(8)) T4(.funsel(FunSel), .e(T4e), .i(i), .q(T4out));



  always @(*) begin
    {R1e, R2e, R3e, R4e} = RSel;
    {T1e, T2e, T3e, T4e} = TSel;
    
    case (O1Sel)
      3'b000:  O1out = T1out;
      3'b001:  O1out = T2out;
      3'b010:  O1out = T3out;
      3'b011:  O1out = T4out;
      3'b100:  O1out = R1out;
      3'b101:  O1out = R2out;
      3'b110:  O1out = R3out;
      3'b111:  O1out = R4out;
    endcase
    case (O2Sel)
      3'b000:  O2out = T1out;
      3'b001:  O2out = T2out;
      3'b010:  O2out = T3out;
      3'b011:  O2out = T4out;
      3'b100:  O2out = R1out;
      3'b101:  O2out = R2out;
      3'b110:  O2out = R3out;
      3'b111:  O2out = R4out;
    endcase

    end
endmodule
