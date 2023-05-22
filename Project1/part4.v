// iverilog part4.v part3.v part2c.v part2b.v part2a.v part1.v Memory.v

`timescale 1ns / 1ps

module mux1to2 (input       sel, 
                input [7:0] I0,
                input [7:0] I1,
                output reg[7:0] out);
                
    always @ (*) begin
        case (sel)
            1'b0: out <= I0;
            1'b1: out <= I1;
        endcase
    end
endmodule

module mux2to4 (input [1:0] sel, 
                input [7:0] I0,
                input [7:0] I1,
                input [7:0] I2,
                input [7:0] I3,
                output reg[7:0] out);
                
    always @ (*) begin
        case (sel)
            2'b00: out <= I0; 
            2'b01: out <= I1; 
            2'b10: out <= I2; 
            2'b11: out <= I3; 
        endcase 
    end
endmodule

module ALU_System(
    //multiplexers
    input[1:0] MuxASel,
    input[1:0] MuxBSel,
    input      MuxCSel,
    // register file
    input[2:0] RF_OutASel, //o1sel
    input[2:0] RF_OutBSel, //o2sel
    input[1:0] RF_FunSel,
    input[3:0] RF_TSel,
    input[3:0] RF_RSel,
    //ALU
    input[3:0] ALU_FunSel,
    //address register file
    input[1:0] ARF_OutASel,
    input[1:0] ARF_OutBSel,
    input[1:0] ARF_FunSel,
    input[3:0] ARF_RSel,
    // instruction register (IR)
    input[1:0] IR_Funsel,
    input      IR_Enable,
    input      IR_LH,
    //MEM
    input      Mem_WR, //Read = 0, Write = 1
    input      Mem_CS, //Chip is enable when cs = 0
    //clock
    input      Clock,
    //output 
    output[3:0] ALU_ZCNO
);

// i think its better to use assign and use original names for every part
//MUXA
wire[7:0] A_I0;
wire[7:0] A_I1;
wire[7:0] A_I2;
wire[7:0] A_I3;
wire[7:0] MUXA_out;
//RF
wire[7:0] RF_i;
wire[7:0] RF_O1;
wire[7:0] RF_O2;
//MUXC
wire[7:0] C_I0;
wire[7:0] C_I1;
wire[7:0] MUXC_out;
//ALU
wire[7:0] ALU_A;
wire[7:0] ALU_B;
wire[7:0] OutALU;
//wire[3:0] ALU_ZCNO;
//MUXB
wire[7:0] B_I0;
wire[7:0] B_I1;
wire[7:0] B_I2;
wire[7:0] B_I3; 
wire[7:0] MUXB_out;
//ARF
wire[7:0] ARF_i;
wire[7:0] ARF_OutA;
wire[7:0] ARF_OutB;
//Memory
wire[7:0] MEM_address;
wire[7:0] MEM_data;
wire[7:0] MEM_out;
//IR
wire[7:0] IR_i;
wire[7:0] IR_out_low;
wire[7:0] IR_out_high; // this may not be used.
wire[15:0] IR_out;
//out
//just a placeholder
//wire[7:0] out;

//assignments between outputs and inputs
// categorization is for inputs

//RF
assign RF_i = MUXA_out;
//ALU
assign ALU_A = MUXC_out;
assign ALU_B = RF_O2;
//MEMORY
assign MEM_data = OutALU;
assign MEM_address = ARF_OutB;
//ARF
assign ARF_i = MUXB_out;
//IR
assign IR_i = MEM_out;
assign IR_out_low = IR_out[7:0]; //maybe IR_out[0:7]
assign IR_out_high = IR_out[15:8]; // maybe IR_out[8:15]
//System
assign out = IR_out_high; //probably not needed
//MUXA
assign A_I0 = OutALU;
assign A_I1 = MEM_out;
assign A_I2 = IR_out_low;
assign A_I3 = ARF_OutA;
//MUXB
assign B_I0 = OutALU;
assign B_I1 = MEM_out;
assign B_I2 = IR_out_low;
assign B_I3 = ARF_OutA;
//MUXC
assign C_I0 = RF_O1;
assign C_I1 = ARF_OutA;

//modules
mux2to4 MUXA(
    .sel(MuxASel),
    .I0(A_I0),
    .I1(A_I1),
    .I2(A_I2),
    .I3(A_I3),
    .out(MUXA_out)
);

RF _RF(
    .O1Sel(RF_OutASel),
    .O2Sel(RF_OutBSel),
    .FunSel(RF_FunSel),
    .RSel(RF_RSel),
    .TSel(RF_TSel),
    .i(RF_i),
    .O1(RF_O1),
    .O2(RF_O2),
    .clk(Clock)
);

mux1to2 MUXC(
    .sel(MuxCSel),
    .I0(C_I0),
    .I1(C_I1),
    .out(MUXC_out)
);

mux2to4 MUXB(
    .sel(MuxBSel),
    .I0(B_I0),
    .I1(B_I1),
    .I2(B_I2),
    .I3(B_I3),
    .out(MUXB_out)
);

alu _ALU(
    .A(ALU_A),
    .B(ALU_B),
    .FunSel(ALU_FunSel),
    .CLK(Clock),
    .OutALU(OutALU),
    .ZCNO(ALU_ZCNO)
);

ARF _ARF(
    .i(ARF_i),
    .out_a_sel(ARF_OutASel),
    .out_b_sel(ARF_OutBSel),
    .funsel(ARF_FunSel),
    .r_sel(ARF_RSel),
    .out_a(ARF_OutA),
    .out_b(ARF_OutB),
    .clk(Clock)
);

Memory _MEMORY(
    .address(MEM_address),
    .data(MEM_data),
    .wr(Mem_WR),
    .cs(Mem_CS),
    .o(MEM_out),
    .clock(Clock)
);

IR_16_bit _IR(
    .i_half (IR_i),
    .funsel (IR_Funsel),
    .e      (IR_Enable),
    .l_h    (IR_LH),
    .ir_out (IR_out),
    .clk(Clock)
);

endmodule
