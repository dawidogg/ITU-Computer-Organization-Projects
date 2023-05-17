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
  output[7:0]     O1,
  output[7:0]     O2
);
  wire R1e, R2e, R3e, R4e;
  wire T1e, T2e, T3e, T4e;

  assign {R1e, R2e, R3e, R4e} = RSel;
  assign {T1e, T2e, T3e, T4e} = TSel;

  register #(.NBits(8)) R1(.funsel(FunSel), .e(R1e), .i(i), .clk(clk));
  register #(.NBits(8)) R2(.funsel(FunSel), .e(R2e), .i(i), .clk(clk));
  register #(.NBits(8)) R3(.funsel(FunSel), .e(R3e), .i(i), .clk(clk));
  register #(.NBits(8)) R4(.funsel(FunSel), .e(R4e), .i(i), .clk(clk));
  register #(.NBits(8)) T1(.funsel(FunSel), .e(T1e), .i(i), .clk(clk));
  register #(.NBits(8)) T2(.funsel(FunSel), .e(T2e), .i(i), .clk(clk));
  register #(.NBits(8)) T3(.funsel(FunSel), .e(T3e), .i(i), .clk(clk));
  register #(.NBits(8)) T4(.funsel(FunSel), .e(T4e), .i(i), .clk(clk));

  assign O1 = (O1Sel == 3'b000)? T1.q : 8'bz;
  assign O1 = (O1Sel == 3'b001)? T2.q : 8'bz;
  assign O1 = (O1Sel == 3'b010)? T3.q : 8'bz;
  assign O1 = (O1Sel == 3'b011)? T4.q : 8'bz;
  assign O1 = (O1Sel == 3'b100)? R1.q : 8'bz;
  assign O1 = (O1Sel == 3'b101)? R2.q : 8'bz;
  assign O1 = (O1Sel == 3'b110)? R3.q : 8'bz;
  assign O1 = (O1Sel == 3'b111)? R4.q : 8'bz;

  assign O2 = (O2Sel == 3'b000)? T1.q : 8'bz;
  assign O2 = (O2Sel == 3'b001)? T2.q : 8'bz;
  assign O2 = (O2Sel == 3'b010)? T3.q : 8'bz;
  assign O2 = (O2Sel == 3'b011)? T4.q : 8'bz;
  assign O2 = (O2Sel == 3'b100)? R1.q : 8'bz;
  assign O2 = (O2Sel == 3'b101)? R2.q : 8'bz;
  assign O2 = (O2Sel == 3'b110)? R3.q : 8'bz;
  assign O2 = (O2Sel == 3'b111)? R4.q : 8'bz;
endmodule