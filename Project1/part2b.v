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



module part2b(
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
  wire[7:0] R1in = i, R2in = i, R3in = i, R4in = i;
  wire[7:0] T1in = i, T2in = i, T3in = i, T4in = i;
  reg[0:0] R1e, R2e, R3e, R4e;
  reg[0:0] T1e, T2e, T3e, T4e;
  reg[7:0] O1out, O2out;
  assign O1 = O1out; assign O2 = O2out;

  register #(.NBits(8)) R1(.funsel(FunSel), .e(R1e), .i(R1in), .q(R1out));
  register #(.NBits(8)) R2(.funsel(FunSel), .e(R2e), .i(R2in), .q(R2out));
  register #(.NBits(8)) R3(.funsel(FunSel), .e(R3e), .i(R3in), .q(R3out));
  register #(.NBits(8)) R4(.funsel(FunSel), .e(R4e), .i(R4in), .q(R4out));
  register #(.NBits(8)) T1(.funsel(FunSel), .e(T1e), .i(T1in), .q(T1out));
  register #(.NBits(8)) T2(.funsel(FunSel), .e(T2e), .i(T2in), .q(T2out));
  register #(.NBits(8)) T3(.funsel(FunSel), .e(T3e), .i(T3in), .q(T3out));
  register #(.NBits(8)) T4(.funsel(FunSel), .e(T4e), .i(T4in), .q(T4out));



  always @(O1Sel or O2Sel or FunSel or RSel or TSel) begin
    case (O1Sel)
      3'b000:  O1out <= T1out;
      3'b001:  O1out <= T2out;
      3'b010:  O1out <= T3out;
      3'b011:  O1out <= T4out;
      3'b100:  O1out <= R1out;
      3'b101:  O1out <= R2out;
      3'b110:  O1out <= R3out;
      3'b111:  O1out <= R4out;
    endcase
    case (O2Sel)
      3'b000:  O2out <= T1out;
      3'b001:  O2out <= T2out;
      3'b010:  O2out <= T3out;
      3'b011:  O2out <= T4out;
      3'b100:  O2out <= R1out;
      3'b101:  O2out <= R2out;
      3'b110:  O2out <= R3out;
      3'b111:  O2out <= R4out;
    endcase
    
    case (RSel)
      4'b0000:begin
                R1e = 1'b0;   R2e = 1'b0;  R3e = 1'b0;  R4e = 1'b0;  
              end
      4'b0001:begin
                R1e = 1'b0;   R2e = 1'b0;  R3e = 1'b0;  R4e = 1'b1; 
              end
      4'b0010:begin
                R1e = 1'b0;   R2e = 1'b0;  R3e = 1'b1;  R4e = 1'b0; 
              end
      4'b0011:begin
                R1e = 1'b0;   R2e = 1'b0;  R3e = 1'b1;  R4e = 1'b1; 
              end
      4'b0100:begin
                R1e = 1'b0;   R2e = 1'b1;  R3e = 1'b0;  R4e = 1'b0;
              end
      4'b0101:begin
                R1e = 1'b0;   R2e = 1'b1;  R3e = 1'b0;  R4e = 1'b1;  
              end
      4'b0110:begin
                R1e = 1'b0;   R2e = 1'b1;  R3e = 1'b1;  R4e = 1'b0; 
              end
      4'b0111:begin
                R1e = 1'b0;   R2e = 1'b1;  R3e = 1'b1;  R4e = 1'b1;  
              end
      4'b1000:begin
                R1e = 1'b1;   R2e = 1'b0;  R3e = 1'b0;  R4e = 1'b0;  
              end
      4'b1001:begin
                R1e = 1'b1;   R2e = 1'b0;  R3e = 1'b0;  R4e = 1'b1;
              end
      4'b1010:begin
                R1e = 1'b1;   R2e = 1'b0;  R3e = 1'b1;  R4e = 1'b0; 
              end
      4'b1011:begin
                R1e = 1'b1;   R2e = 1'b0;  R3e = 1'b1;  R4e = 1'b1; 
              end
      4'b1100:begin
                R1e = 1'b1;   R2e = 1'b1;  R3e = 1'b0;  R4e = 1'b0; 
              end
      4'b1101:begin
                R1e = 1'b1;   R2e = 1'b1;  R3e = 1'b0;  R4e = 1'b1; 
              end
      4'b1110:begin
                R1e = 1'b1;   R2e = 1'b1;  R3e = 1'b1;  R4e = 1'b0; 
              end
      4'b1111:begin
                R1e = 1'b1;   R2e = 1'b1;  R3e = 1'b1;  R4e = 1'b1;
              end
     
    endcase
    
    case (TSel)
          4'b0000:begin
                    T1e = 1'b0;  T2e = 1'b0; T3e = 1'b0;  T4e = 1'b0;
                  end
          4'b0001:begin
                    T1e = 1'b0;  T2e = 1'b0; T3e = 1'b0;  T4e = 1'b1;
                  end
          4'b0010:begin
                    T1e = 1'b0;  T2e = 1'b0; T3e = 1'b1;  T4e = 1'b0;
                  end
          4'b0011:begin
                    T1e = 1'b0;  T2e = 1'b0; T3e = 1'b1;  T4e = 1'b1;
                  end
          4'b0100:begin
                    T1e = 1'b0;  T2e = 1'b1; T3e = 1'b0;  T4e = 1'b0;
                  end
          4'b0101:begin
                    T1e = 1'b0;  T2e = 1'b1; T3e = 1'b0;  T4e = 1'b1;
                  end
          4'b0110:begin
                    T1e = 1'b0;  T2e = 1'b1; T3e = 1'b1;  T4e = 1'b0;
                  end
          4'b0111:begin
                    T1e = 1'b0;  T2e = 1'b1; T3e = 1'b1;  T4e = 1'b1;
                  end
          4'b1000:begin
                    T1e = 1'b1;  T2e = 1'b0; T3e = 1'b0;  T4e = 1'b0;
                  end
          4'b1001:begin
                    T1e = 1'b1;  T2e = 1'b0; T3e = 1'b0;  T4e = 1'b1;
                  end
          4'b1010:begin
                    T1e = 1'b1;  T2e = 1'b0; T3e = 1'b1;  T4e = 1'b0;
                  end
          4'b1011:begin
                    T1e = 1'b1;  T2e = 1'b0; T3e = 1'b1;  T4e = 1'b1;
                  end
          4'b1100:begin
                    T1e = 1'b1;  T2e = 1'b1; T3e = 1'b0;  T4e = 1'b0;
                  end
          4'b1101:begin
                    T1e = 1'b1;  T2e = 1'b1; T3e = 1'b0;  T4e = 1'b1; 
                  end
          4'b1110:begin
                    T1e = 1'b1;  T2e = 1'b1; T3e = 1'b1;  T4e = 1'b0;
                  end
          4'b1111:begin
                    T1e = 1'b1;  T2e = 1'b1; T3e = 1'b1;  T4e = 1'b1;
                  end
        endcase
    end
endmodule
