module register #(
parameter NBits = 16
) (
  input               clk,
  input[1:0]          funsel, 
  input               e, 
  input[NBits-1: 0]   i,
  output[NBits-1: 0]  q
);

reg[NBits-1:0] data;
assign q = data;

initial data = {NBits{1'b0}};

always @(posedge clk) begin
  if (e)
    case (funsel)
      2'b00: data = {NBits{1'b0}};  // Clear
      2'b01: data = i;              // Load
      2'b10: data = data - 1'b1;    // Decrement
      2'b11: data = data + 1'b1;    // Increment
    endcase
end 
endmodule

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
    output[3:0] ALU_ZCNO,
    input dump
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
    .clock(Clock),
    .dump(dump)
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

module Memory(
    input wire[7:0] address,
    input wire[7:0] data,
    input wire wr, //Read = 0, Write = 1
    input wire cs, //Chip is enable when cs = 0
    input wire clock,
    output reg[7:0] o, // Output
    input dump
);
    //Declaration o�f the RAM Area
    reg[7:0] RAM_DATA[0:255];
    reg[7:0] i;
    //Read Ram data from the file
    initial $readmemh("RAM.mem", RAM_DATA);
    //Read the selected data from RAM
    always @(*) begin
        $writememh("RAM_OUT.mem",RAM_DATA);
        o = ~wr && ~cs ? RAM_DATA[address] : 8'hZ;
    end
    
    //Write the data to RAM
    always @(posedge clock) begin
        if (wr && ~cs) begin
            RAM_DATA[address] <= data; 
        end
    end

    always @(posedge dump) begin
      for (i = 8'h0; i < 8'hff; i = i + 1) begin
        if (i % 16 == 0) $display("// Address: 0x%x", i);
        $display("%x", RAM_DATA[i]);
        // #1;
      end
      $finish;
    end
endmodule

module decoder_4_16(
  input [3:0] in,
  output [15:0] out
);
  assign out = {
    (in[3] & in[2] & in[1] & in[0]), 
    (in[3] & in[2] & in[1] & ~in[0]), 
    (in[3] & in[2] & ~in[1] & in[0]), 
    (in[3] & in[2] & ~in[1] & ~in[0]), 
    (in[3] & ~in[2] & in[1] & in[0]), 
    (in[3] & ~in[2] & in[1] & ~in[0]), 
    (in[3] & ~in[2] & ~in[1] & in[0]), 
    (in[3] & ~in[2] & ~in[1] & ~in[0]), 
    (~in[3] & in[2] & in[1] & in[0]), 
    (~in[3] & in[2] & in[1] & ~in[0]), 
    (~in[3] & in[2] & ~in[1] & in[0]), 
    (~in[3] & in[2] & ~in[1] & ~in[0]), 
    (~in[3] & ~in[2] & in[1] & in[0]), 
    (~in[3] & ~in[2] & in[1] & ~in[0]), 
    (~in[3] & ~in[2] & ~in[1] & in[0]), 
    (~in[3] & ~in[2] & ~in[1] & ~in[0])
  };
endmodule

module CPUSystem(input Clock, input Reset);
  reg[1:0] MuxASel;
  reg[1:0] MuxBSel;
  reg      MuxCSel;
  // register file
  reg[2:0] RF_OutASel; //o1sel
  reg[2:0] RF_OutBSel; //o2sel
  reg[1:0] RF_FunSel;
  reg[3:0] RF_TSel;
  reg[3:0] RF_RSel;
  //ALU
  reg[3:0] ALU_FunSel;
  //address register file
  reg[1:0] ARF_OutASel;
  reg[1:0] ARF_OutBSel;
  reg[1:0] ARF_FunSel;
  reg[3:0] ARF_RSel;
  // instruction register (IR)
  reg[1:0] IR_Funsel;
  reg      IR_Enable;
  reg      IR_LH;
  //MEM
  reg      Mem_WR;
  reg      Mem_CS;
  reg dump;
  wire[3:0] ALU_ZCNO;
  
  ALU_System alu_sys(
    MuxASel,
    MuxBSel,
    MuxCSel,
    RF_OutASel,
    RF_OutBSel,
    RF_FunSel,
    RF_TSel,
    RF_RSel,
    ALU_FunSel,
    ARF_OutASel,
    ARF_OutBSel,
    ARF_FunSel,
    ARF_RSel,
    IR_Funsel,
    IR_Enable,
    IR_LH,
    Mem_WR,
    Mem_CS,
    Clock,
    ALU_ZCNO,
    dump
  );

  reg[1:0] s_counter_funsel;
  register #(.NBits(3)) s_counter (
    .clk(Clock), 
    .funsel(s_counter_funsel),
    .e(1'b1)
  );

  // Time
  wire[15:0] T;
  decoder_4_16 time_decoder({1'b0, s_counter.q}, T);

  // Opcode
  wire[15:0] K;
  decoder_4_16 opcode_decoder(alu_sys.IR_out[15:12], K);

  wire[15:0] d_dstreg;
  decoder_4_16 dstreg_decoder(alu_sys.IR_out[11:8], d_dstreg);
  wire[15:0] d_sreg1;
  decoder_4_16 sreg1_decoder(alu_sys.IR_out[7:4], d_sreg1);
  wire[15:0] d_sreg2;
  decoder_4_16 sreg2_decoder(alu_sys.IR_out[3:0], d_sreg2);
  wire[3:0] d_rsel;
  wire[11:0] d_rsel_void;
  decoder_4_16 rsel_decoder({2'b00, alu_sys.IR_out[9:8]}, {d_rsel_void, d_rsel});

  // addressing mode bit
  wire I;
  assign I = alu_sys.IR_out[10];

  initial begin
    $dumpvars;
    dump = 0;
    s_counter_funsel = 2'b11;
  end
  always @(*) begin
    if (Reset) begin
      s_counter_funsel = 2'b00;
      ARF_FunSel = 2'b00;
      ARF_RSel = 4'b0011;
    end
    if (!Reset) begin
    // Fetch cycle (T0, T1, T2)

    if (T[0]) begin
      // IR(0-7) <-
      IR_Enable = 1;
      IR_Funsel = 2'b01;
      IR_LH = 0;
      // <- M[PC]
      Mem_WR = 0;
      Mem_CS = 0;
      ARF_OutBSel = 2'b11;
      // Increment PC_past and PC
      ARF_FunSel = 2'b11;
      ARF_RSel = 4'b0011;

      s_counter_funsel = 2'b11;
      RF_RSel = 4'b0000;
    end

    if (T[1]) begin
      // IR(8-15) <-
      IR_Enable = 1;
      IR_Funsel = 2'b01;
      IR_LH = 1;
      // <- M[PC]
      Mem_WR = 0;
      Mem_CS = 0;
      ARF_OutBSel = 2'b11;    
      // Increment PC_past and PC
      ARF_FunSel = 2'b11;
      ARF_RSel = 4'b0011;

      s_counter_funsel = 2'b11;
      RF_RSel = 4'b0000;
    end

    if (T[2]) begin
      Mem_WR = 0; // disable memory
      s_counter_funsel = 2'b11;
      RF_RSel = 4'b0000;
      IR_Enable = 0;
      ARF_RSel = 4'b0000;
      if (alu_sys.IR_out == 16'hffff) begin
        dump = 1;
      end
    end

    // AND
    if (T[3] && K[0]) begin
      MuxASel = 2'b00; // Select ALU
      MuxBSel = 2'b00; // Select ALU

      // DSTREG <-

      // If R1, R2, R3 or R4
      if (d_dstreg[0] || d_dstreg[1] || d_dstreg[2] || d_dstreg[3]) begin
        RF_FunSel = 2'b01;
        RF_RSel = {d_dstreg[0], d_dstreg[1], d_dstreg[2], d_dstreg[3]};
      end
      
      // If SP, AR, PC, PC
      if (d_dstreg[4] || d_dstreg[5] || d_dstreg[6] || d_dstreg[7]) begin
        ARF_FunSel = 2'b01;
        ARF_RSel = {d_dstreg[5], d_dstreg[4], d_dstreg[6], d_dstreg[7]};
      end

      // <- SREG1 and SREG2

      // Both SREGs cannot be from ARF
      if (d_sreg1[4]) ARF_OutASel = 2'b01; // SP
      if (d_sreg1[5]) ARF_OutASel = 2'b00; // AR
      if (d_sreg1[6]) ARF_OutASel = 2'b11; // PC
      if (d_sreg1[7]) ARF_OutASel = 2'b11; // PC

      if (d_sreg2[4]) ARF_OutASel = 2'b01; // SP
      if (d_sreg2[5]) ARF_OutASel = 2'b00; // AR
      if (d_sreg2[6]) ARF_OutASel = 2'b11; // PC
      if (d_sreg2[7]) ARF_OutASel = 2'b11; // PC
      
      if ((d_sreg1[4] || d_sreg1[5] || d_sreg1[6] || d_sreg1[7]) || 
         (d_sreg2[4] || d_sreg2[5] || d_sreg2[6] || d_sreg2[7])) begin
        MuxCSel = 1'b1; // Select ARF_OutA
        // One of SREGs from RF
        if (d_sreg1[0]) RF_OutBSel = 3'b100;
        if (d_sreg1[1]) RF_OutBSel = 3'b101;
        if (d_sreg1[2]) RF_OutBSel = 3'b110;
        if (d_sreg1[3]) RF_OutBSel = 3'b111;

        if (d_sreg2[0]) RF_OutBSel = 3'b100;
        if (d_sreg2[1]) RF_OutBSel = 3'b101;
        if (d_sreg2[2]) RF_OutBSel = 3'b110;
        if (d_sreg2[3]) RF_OutBSel = 3'b111;
      end else begin
        MuxCSel = 1'b0; // Select RF_OutA
        // Both SREGs from RF
        if (d_sreg1[0]) RF_OutASel = 3'b100;
        if (d_sreg1[1]) RF_OutASel = 3'b101;
        if (d_sreg1[2]) RF_OutASel = 3'b110;
        if (d_sreg1[3]) RF_OutASel = 3'b111;

        if (d_sreg2[0]) RF_OutBSel = 3'b100;
        if (d_sreg2[1]) RF_OutBSel = 3'b101;
        if (d_sreg2[2]) RF_OutBSel = 3'b110;
        if (d_sreg2[3]) RF_OutBSel = 3'b111;
      end

      ALU_FunSel = 4'b0111; // AND
      Mem_CS = 1; // disable memory
      s_counter_funsel = 2'b00; // reset counter
      IR_Enable = 0;
    end  
    
    // OR
    if (T[3] && K[1]) begin
      MuxASel = 2'b00; // Select ALU
      MuxBSel = 2'b00; // Select ALU

      // DSTREG <-

      // If R1, R2, R3 or R4
      if (d_dstreg[0] || d_dstreg[1] || d_dstreg[2] || d_dstreg[3]) begin
        RF_FunSel = 2'b01;
        RF_RSel = {d_dstreg[0], d_dstreg[1], d_dstreg[2], d_dstreg[3]};
      end
      
      // If SP, AR, PC, PC
      if (d_dstreg[4] || d_dstreg[5] || d_dstreg[6] || d_dstreg[7]) begin
        ARF_FunSel = 2'b01;
        ARF_RSel = {d_dstreg[5], d_dstreg[4], d_dstreg[6], d_dstreg[7]};
      end

      // <- SREG1 or SREG2

      // Both SREGs cannot be from ARF
      if (d_sreg1[4]) ARF_OutASel = 2'b01; // SP
      if (d_sreg1[5]) ARF_OutASel = 2'b00; // AR
      if (d_sreg1[6]) ARF_OutASel = 2'b11; // PC
      if (d_sreg1[7]) ARF_OutASel = 2'b11; // PC

      if (d_sreg2[4]) ARF_OutASel = 2'b01; // SP
      if (d_sreg2[5]) ARF_OutASel = 2'b00; // AR
      if (d_sreg2[6]) ARF_OutASel = 2'b11; // PC
      if (d_sreg2[7]) ARF_OutASel = 2'b11; // PC
      
      if ((d_sreg1[4] || d_sreg1[5] || d_sreg1[6] || d_sreg1[7]) || 
         (d_sreg2[4] || d_sreg2[5] || d_sreg2[6] || d_sreg2[7])) begin
        MuxCSel = 1'b1; // Select ARF_OutA
        // One of SREGs from RF
        if (d_sreg1[0]) RF_OutBSel = 3'b100;
        if (d_sreg1[1]) RF_OutBSel = 3'b101;
        if (d_sreg1[2]) RF_OutBSel = 3'b110;
        if (d_sreg1[3]) RF_OutBSel = 3'b111;

        if (d_sreg2[0]) RF_OutBSel = 3'b100;
        if (d_sreg2[1]) RF_OutBSel = 3'b101;
        if (d_sreg2[2]) RF_OutBSel = 3'b110;
        if (d_sreg2[3]) RF_OutBSel = 3'b111;
      end else begin
        MuxCSel = 1'b0; // Select RF_OutA
        // Both SREGs from RF
        if (d_sreg1[0]) RF_OutASel = 3'b100;
        if (d_sreg1[1]) RF_OutASel = 3'b101;
        if (d_sreg1[2]) RF_OutASel = 3'b110;
        if (d_sreg1[3]) RF_OutASel = 3'b111;

        if (d_sreg2[0]) RF_OutBSel = 3'b100;
        if (d_sreg2[1]) RF_OutBSel = 3'b101;
        if (d_sreg2[2]) RF_OutBSel = 3'b110;
        if (d_sreg2[3]) RF_OutBSel = 3'b111;
      end

      ALU_FunSel = 4'b1000; // OR
      Mem_CS = 1; // disable memory
      s_counter_funsel = 2'b00; // reset counter
      IR_Enable = 0;
    end  

    // NOT
    if (T[3] && K[2]) begin
      MuxASel = 2'b00; // Select ALU
      MuxBSel = 2'b00; // Select ALU
      MuxCSel = 1'b1; // Select ARF_OutA

      // DSTREG <-

      // If R1, R2, R3 or R4
      if (d_dstreg[0] || d_dstreg[1] || d_dstreg[2] || d_dstreg[3]) begin
        RF_FunSel = 2'b01;
        RF_RSel = {d_dstreg[0], d_dstreg[1], d_dstreg[2], d_dstreg[3]};
      end
      
      // If SP, AR, PC, PC
      if (d_dstreg[4] || d_dstreg[5] || d_dstreg[6] || d_dstreg[7]) begin
        ARF_FunSel = 2'b01;
        ARF_RSel = {d_dstreg[5], d_dstreg[4], d_dstreg[6], d_dstreg[7]};
      end

      // <- not SREG1

      // If R1, R2, R3 or R4
      if (d_sreg1[0] || d_sreg1[1] || d_sreg1[2] || d_sreg1[3])
        ALU_FunSel = 4'b0011; // NOT B
      if (d_sreg1[0]) RF_OutBSel = 3'b100;
      if (d_sreg1[1]) RF_OutBSel = 3'b101;
      if (d_sreg1[2]) RF_OutBSel = 3'b110;
      if (d_sreg1[3]) RF_OutBSel = 3'b111;
      
      // If SP, AR, PC, PC
      if (d_sreg1[4] || d_sreg1[5] || d_sreg1[6] || d_sreg1[7]) 
        ALU_FunSel = 4'b0010; // NOT A
      if (d_sreg1[4]) ARF_OutASel = 2'b01; // SP
      if (d_sreg1[5]) ARF_OutASel = 2'b00; // AR
      if (d_sreg1[6]) ARF_OutASel = 2'b11; // PC
      if (d_sreg1[7]) ARF_OutASel = 2'b11; // PC

      Mem_CS = 1; // disable memory
      s_counter_funsel = 2'b00; // reset counter
      IR_Enable = 0;
    end  

    // ADD
    if (T[3] && K[3]) begin
      MuxASel = 2'b00; // Select ALU
      MuxBSel = 2'b00; // Select ALU

      // DSTREG <-

      // If R1, R2, R3 or R4
      if (d_dstreg[0] || d_dstreg[1] || d_dstreg[2] || d_dstreg[3]) begin
        RF_FunSel = 2'b01;
        RF_RSel = {d_dstreg[0], d_dstreg[1], d_dstreg[2], d_dstreg[3]};
      end
      
      // If SP, AR, PC, PC
      if (d_dstreg[4] || d_dstreg[5] || d_dstreg[6] || d_dstreg[7]) begin
        ARF_FunSel = 2'b01;
        ARF_RSel = {d_dstreg[5], d_dstreg[4], d_dstreg[6], d_dstreg[7]};
      end

      // <- SREG1 + SREG2

      // Both SREGs cannot be from ARF
      if (d_sreg1[4]) ARF_OutASel = 2'b01; // SP
      if (d_sreg1[5]) ARF_OutASel = 2'b00; // AR
      if (d_sreg1[6]) ARF_OutASel = 2'b11; // PC
      if (d_sreg1[7]) ARF_OutASel = 2'b11; // PC

      if (d_sreg2[4]) ARF_OutASel = 2'b01; // SP
      if (d_sreg2[5]) ARF_OutASel = 2'b00; // AR
      if (d_sreg2[6]) ARF_OutASel = 2'b11; // PC
      if (d_sreg2[7]) ARF_OutASel = 2'b11; // PC
      
      if ((d_sreg1[4] || d_sreg1[5] || d_sreg1[6] || d_sreg1[7]) || 
         (d_sreg2[4] || d_sreg2[5] || d_sreg2[6] || d_sreg2[7])) begin
        MuxCSel = 1'b1; // Select ARF_OutA
        // One of SREGs from RF
        if (d_sreg1[0]) RF_OutBSel = 3'b100;
        if (d_sreg1[1]) RF_OutBSel = 3'b101;
        if (d_sreg1[2]) RF_OutBSel = 3'b110;
        if (d_sreg1[3]) RF_OutBSel = 3'b111;

        if (d_sreg2[0]) RF_OutBSel = 3'b100;
        if (d_sreg2[1]) RF_OutBSel = 3'b101;
        if (d_sreg2[2]) RF_OutBSel = 3'b110;
        if (d_sreg2[3]) RF_OutBSel = 3'b111;
      end else begin
        MuxCSel = 1'b0; // Select RF_OutA
        // Both SREGs from RF
        if (d_sreg1[0]) RF_OutASel = 3'b100;
        if (d_sreg1[1]) RF_OutASel = 3'b101;
        if (d_sreg1[2]) RF_OutASel = 3'b110;
        if (d_sreg1[3]) RF_OutASel = 3'b111;

        if (d_sreg2[0]) RF_OutBSel = 3'b100;
        if (d_sreg2[1]) RF_OutBSel = 3'b101;
        if (d_sreg2[2]) RF_OutBSel = 3'b110;
        if (d_sreg2[3]) RF_OutBSel = 3'b111;
      end

      ALU_FunSel = 4'b0100; // ADD
      Mem_CS = 1; // disable memory
      s_counter_funsel = 2'b00; // reset counter
      IR_Enable = 0;
    end  

    // SUB
    if (T[3] && K[4]) begin
      MuxASel = 2'b00; // Select ALU
      MuxBSel = 2'b00; // Select ALU

      // DSTREG <-

      // If R1, R2, R3 or R4
      if (d_dstreg[0] || d_dstreg[1] || d_dstreg[2] || d_dstreg[3]) begin
        RF_FunSel = 2'b01;
        RF_RSel = {d_dstreg[0], d_dstreg[1], d_dstreg[2], d_dstreg[3]};
      end
      
      // If SP, AR, PC, PC
      if (d_dstreg[4] || d_dstreg[5] || d_dstreg[6] || d_dstreg[7]) begin
        ARF_FunSel = 2'b01;
        ARF_RSel = {d_dstreg[5], d_dstreg[4], d_dstreg[6], d_dstreg[7]};
      end

      // <- SREG1 - SREG2

      // Both SREGs cannot be from ARF
      if (d_sreg1[4]) ARF_OutASel = 2'b01; // SP
      if (d_sreg1[5]) ARF_OutASel = 2'b00; // AR
      if (d_sreg1[6]) ARF_OutASel = 2'b11; // PC
      if (d_sreg1[7]) ARF_OutASel = 2'b11; // PC

      if (d_sreg2[4]) ARF_OutASel = 2'b01; // SP
      if (d_sreg2[5]) ARF_OutASel = 2'b00; // AR
      if (d_sreg2[6]) ARF_OutASel = 2'b11; // PC
      if (d_sreg2[7]) ARF_OutASel = 2'b11; // PC
      
      if ((d_sreg1[4] || d_sreg1[5] || d_sreg1[6] || d_sreg1[7]) || 
         (d_sreg2[4] || d_sreg2[5] || d_sreg2[6] || d_sreg2[7])) begin
        MuxCSel = 1'b1; // Select ARF_OutA
        // One of SREGs from RF
        if (d_sreg1[0]) RF_OutBSel = 3'b100;
        if (d_sreg1[1]) RF_OutBSel = 3'b101;
        if (d_sreg1[2]) RF_OutBSel = 3'b110;
        if (d_sreg1[3]) RF_OutBSel = 3'b111;

        if (d_sreg2[0]) RF_OutBSel = 3'b100;
        if (d_sreg2[1]) RF_OutBSel = 3'b101;
        if (d_sreg2[2]) RF_OutBSel = 3'b110;
        if (d_sreg2[3]) RF_OutBSel = 3'b111;
      end else begin
        MuxCSel = 1'b0; // Select RF_OutA
        // Both SREGs from RF
        if (d_sreg1[0]) RF_OutASel = 3'b100;
        if (d_sreg1[1]) RF_OutASel = 3'b101;
        if (d_sreg1[2]) RF_OutASel = 3'b110;
        if (d_sreg1[3]) RF_OutASel = 3'b111;

        if (d_sreg2[0]) RF_OutBSel = 3'b100;
        if (d_sreg2[1]) RF_OutBSel = 3'b101;
        if (d_sreg2[2]) RF_OutBSel = 3'b110;
        if (d_sreg2[3]) RF_OutBSel = 3'b111;
      end

      ALU_FunSel = 4'b0101; // SUB
      Mem_CS = 1; // disable memory
      s_counter_funsel = 2'b00; // reset counter
      IR_Enable = 0;
    end  

    // LSR
    if (T[3] && K[5]) begin
      MuxASel = 2'b00; // Select ALU
      MuxBSel = 2'b00; // Select ALU

      // DSTREG <-

      // If R1, R2, R3 or R4
      if (d_dstreg[0] || d_dstreg[1] || d_dstreg[2] || d_dstreg[3]) begin
        RF_FunSel = 2'b01;
        RF_RSel = {d_dstreg[0], d_dstreg[1], d_dstreg[2], d_dstreg[3]};
      end
      
      // If SP, AR, PC, PC
      if (d_dstreg[4] || d_dstreg[5] || d_dstreg[6] || d_dstreg[7]) begin
        ARF_FunSel = 2'b01;
        ARF_RSel = {d_dstreg[5], d_dstreg[4], d_dstreg[6], d_dstreg[7]};
      end

      // <- LSR SREG1

      // If R1, R2, R3 or R4
      if (d_sreg1[0] || d_sreg1[1] || d_sreg1[2] || d_sreg1[3])
        MuxCSel = 1'b0;
      if (d_sreg1[0]) RF_OutASel = 3'b100;
      if (d_sreg1[1]) RF_OutASel = 3'b101;
      if (d_sreg1[2]) RF_OutASel = 3'b110;
      if (d_sreg1[3]) RF_OutASel = 3'b111;
      
      // If SP, AR, PC, PC
      if (d_sreg1[4] || d_sreg1[5] || d_sreg1[6] || d_sreg1[7]) 
        MuxCSel = 1'b1;
      if (d_sreg1[4]) ARF_OutASel = 2'b01; // SP
      if (d_sreg1[5]) ARF_OutASel = 2'b00; // AR
      if (d_sreg1[6]) ARF_OutASel = 2'b11; // PC
      if (d_sreg1[7]) ARF_OutASel = 2'b11; // PC

      ALU_FunSel = 4'b1100; // LSR
      Mem_CS = 1; // disable memory
      s_counter_funsel = 2'b00; // reset counter
      IR_Enable = 0;
    end  

    // LSL
    if (T[3] && K[6]) begin
      MuxASel = 2'b00; // Select ALU
      MuxBSel = 2'b00; // Select ALU

      // DSTREG <-

      // If R1, R2, R3 or R4
      if (d_dstreg[0] || d_dstreg[1] || d_dstreg[2] || d_dstreg[3]) begin
        RF_FunSel = 2'b01;
        RF_RSel = {d_dstreg[0], d_dstreg[1], d_dstreg[2], d_dstreg[3]};
      end
      
      // If SP, AR, PC, PC
      if (d_dstreg[4] || d_dstreg[5] || d_dstreg[6] || d_dstreg[7]) begin
        ARF_FunSel = 2'b01;
        ARF_RSel = {d_dstreg[5], d_dstreg[4], d_dstreg[6], d_dstreg[7]};
      end

      // <- LSL SREG1

      // If R1, R2, R3 or R4
      if (d_sreg1[0] || d_sreg1[1] || d_sreg1[2] || d_sreg1[3])
        MuxCSel = 1'b0;
      if (d_sreg1[0]) RF_OutASel = 3'b100;
      if (d_sreg1[1]) RF_OutASel = 3'b101;
      if (d_sreg1[2]) RF_OutASel = 3'b110;
      if (d_sreg1[3]) RF_OutASel = 3'b111;
      
      // If SP, AR, PC, PC
      if (d_sreg1[4] || d_sreg1[5] || d_sreg1[6] || d_sreg1[7]) 
        MuxCSel = 1'b1;
      if (d_sreg1[4]) ARF_OutASel = 2'b01; // SP
      if (d_sreg1[5]) ARF_OutASel = 2'b00; // AR
      if (d_sreg1[6]) ARF_OutASel = 2'b11; // PC
      if (d_sreg1[7]) ARF_OutASel = 2'b11; // PC

      ALU_FunSel = 4'b1011; // LSL
      Mem_CS = 1; // disable memory
      s_counter_funsel = 2'b00; // reset counter
      IR_Enable = 0;
    end 

    // INC
    if (T[3] && K[7]) begin

        MuxASel = 2'b00; // Select ALU
        MuxBSel = 2'b00; // Select ALU
        ALU_FunSel = 4'b0000;
        
        // DSTREG <-
    
        // If R1, R2, R3 or R4
        if (d_dstreg[0] || d_dstreg[1] || d_dstreg[2] || d_dstreg[3]) begin
          MuxCSel = 1'b0;
          RF_FunSel = 2'b01;
          RF_RSel = {d_dstreg[0], d_dstreg[1], d_dstreg[2], d_dstreg[3]};
          ARF_RSel = 4'b0;
        end
        
        if (d_sreg1[0]) RF_OutASel = 3'b100;
        if (d_sreg1[1]) RF_OutASel = 3'b101;
        if (d_sreg1[2]) RF_OutASel = 3'b110;
        if (d_sreg1[3]) RF_OutASel = 3'b111;
        
        // If SP, AR, PC, PC
        if (d_dstreg[4] || d_dstreg[5] || d_dstreg[6] || d_dstreg[7]) begin
          MuxCSel = 1'b1;
          ARF_FunSel = 2'b01;
          ARF_RSel = {d_dstreg[5], d_dstreg[4], d_dstreg[6], d_dstreg[7]};
          RF_RSel = 4'b0;
        end
        
        if (d_sreg1[4]) ARF_OutASel = 2'b01; // SP
        if (d_sreg1[5]) ARF_OutASel = 2'b00; // AR
        if (d_sreg1[6]) ARF_OutASel = 2'b11; // PC
        if (d_sreg1[7]) ARF_OutASel = 2'b11; // PC
       
        Mem_CS = 1; // disable memory
        IR_Enable = 0;
    end  

    if (T[4] && K[7]) begin
        // <-  DSTREG + 1

        // If R1, R2, R3 or R4
        if (d_dstreg[0] || d_dstreg[1] || d_dstreg[2] || d_dstreg[3]) begin
          RF_FunSel = 2'b11;
          RF_RSel = {d_dstreg[0], d_dstreg[1], d_dstreg[2], d_dstreg[3]};
          ARF_RSel = 4'b0;
        end

        // If SP, AR, PC, PC
        if (d_dstreg[4] || d_dstreg[5] || d_dstreg[6] || d_dstreg[7]) begin
          ARF_FunSel = 2'b11;
          ARF_RSel = {d_dstreg[5], d_dstreg[4], d_dstreg[6], d_dstreg[7]};
          RF_RSel = 4'b0;
        end
        
        Mem_CS = 1; // disable memory
        s_counter_funsel = 2'b00; // reset counter
        IR_Enable = 0;
        
    end
    
    // DEC
    if (T[3] && K[8]) begin

            MuxASel = 2'b00; // Select ALU
            MuxBSel = 2'b00; // Select ALU
            ALU_FunSel = 4'b0000;
            
            // DSTREG <-
        
            // If R1, R2, R3 or R4
            if (d_dstreg[0] || d_dstreg[1] || d_dstreg[2] || d_dstreg[3]) begin
              MuxCSel = 1'b0;
              RF_FunSel = 2'b01;
              RF_RSel = {d_dstreg[0], d_dstreg[1], d_dstreg[2], d_dstreg[3]};
              ARF_RSel = 4'b0;
            end
            
            if (d_sreg1[0]) RF_OutASel = 3'b100;
            if (d_sreg1[1]) RF_OutASel = 3'b101;
            if (d_sreg1[2]) RF_OutASel = 3'b110;
            if (d_sreg1[3]) RF_OutASel = 3'b111;
            
            // If SP, AR, PC, PC
            if (d_dstreg[4] || d_dstreg[5] || d_dstreg[6] || d_dstreg[7]) begin
              MuxCSel = 1'b1;
              ARF_FunSel = 2'b01;
              ARF_RSel = {d_dstreg[5], d_dstreg[4], d_dstreg[6], d_dstreg[7]};
              RF_RSel = 4'b0;
            end
            
            if (d_sreg1[4]) ARF_OutASel = 2'b01; // SP
            if (d_sreg1[5]) ARF_OutASel = 2'b00; // AR
            if (d_sreg1[6]) ARF_OutASel = 2'b11; // PC
            if (d_sreg1[7]) ARF_OutASel = 2'b11; // PC
           
            Mem_CS = 1; // disable memory
            IR_Enable = 0;
        
    end  
    
    if(T[4] && K[8]) begin
        // <-  DSTREG - 1

        // If R1, R2, R3 or R4
        if (d_dstreg[0] || d_dstreg[1] || d_dstreg[2] || d_dstreg[3]) begin
          RF_FunSel = 2'b10;
          RF_RSel = {d_dstreg[0], d_dstreg[1], d_dstreg[2], d_dstreg[3]};
          ARF_RSel = 4'b0;
        end
    
        // If SP, AR, PC, PC
        if (d_dstreg[4] || d_dstreg[5] || d_dstreg[6] || d_dstreg[7]) begin
          ARF_FunSel = 2'b10;
          ARF_RSel = {d_dstreg[5], d_dstreg[4], d_dstreg[6], d_dstreg[7]};
          RF_RSel = 4'b0;
        end
        
        Mem_CS = 1; // disable memory
        s_counter_funsel = 2'b00; // reset counter
        IR_Enable = 0;
    end
//?

    // BRA
    if (T[3] && K[9]) begin
        RF_RSel = 4'b0000;
        
        MuxBSel = 2'b10;
        ARF_RSel = 4'b0001; // PC
        ARF_FunSel = 2'b01; //Load
    
        
        Mem_CS = 1; // disable memory
        s_counter_funsel = 2'b00; // reset counter
        IR_Enable = 0;
    end

    // BNE
    if (T[3] && K[10]) begin
     
        if(!ALU_ZCNO[3]) begin //if Z == 0
            RF_RSel = 4'b0000;
            
            MuxBSel = 2'b10;
            ARF_RSel = 4'b0001; // PC
            ARF_FunSel = 2'b01; //Load
        
            
            Mem_CS = 1; // disable memory
            s_counter_funsel = 2'b00; // reset counter
            IR_Enable = 0;
        end
        
        if(ALU_ZCNO[3]) begin // if condition is not 0, finish instruction
            Mem_CS = 1; // disable memory
            s_counter_funsel = 2'b00; // reset counter
            IR_Enable = 0;
        end
    end

    // MOV
    if (T[3] && K[11]) begin
      MuxASel = 2'b00; // Select ALU
      MuxBSel = 2'b00; // Select ALU
      MuxCSel = 1'b1;

      // DSTREG <-

      // If R1, R2, R3 or R4
      if (d_dstreg[0] || d_dstreg[1] || d_dstreg[2] || d_dstreg[3]) begin
        RF_FunSel = 2'b01;
        RF_RSel = {d_dstreg[0], d_dstreg[1], d_dstreg[2], d_dstreg[3]};
      end
      
      // If SP, AR, PC, PC
      if (d_dstreg[4] || d_dstreg[5] || d_dstreg[6] || d_dstreg[7]) begin
        ARF_FunSel = 2'b01;
        ARF_RSel = {d_dstreg[5], d_dstreg[4], d_dstreg[6], d_dstreg[7]};
      end

      // <- SREG1

      // If R1, R2, R3 or R4
      if (d_sreg1[0] || d_sreg1[1] || d_sreg1[2] || d_sreg1[3])
        ALU_FunSel = 4'b0001;
      if (d_sreg1[0]) RF_OutBSel = 3'b100;
      if (d_sreg1[1]) RF_OutBSel = 3'b101;
      if (d_sreg1[2]) RF_OutBSel = 3'b110;
      if (d_sreg1[3]) RF_OutBSel = 3'b111;
      
      // If SP, AR, PC, PC
      if (d_sreg1[4] || d_sreg1[5] || d_sreg1[6] || d_sreg1[7]) 
        ALU_FunSel = 4'b0000;
      if (d_sreg1[4]) ARF_OutASel = 2'b01; // SP
      if (d_sreg1[5]) ARF_OutASel = 2'b00; // AR
      if (d_sreg1[6]) ARF_OutASel = 2'b11; // PC
      if (d_sreg1[7]) ARF_OutASel = 2'b11; // PC

      Mem_WR = 0; // disable memory
      s_counter_funsel = 2'b00; // reset counter
      IR_Enable = 0;
    end  

    // LD
    if (T[3] && K[12]) begin
      // Rx <-
      RF_RSel = {d_rsel[0], d_rsel[1], d_rsel[2], d_rsel[3]};
      RF_FunSel = 2'b01;
      
      if (I == 0) begin
        // Immediate address
        // <- IR(0-7)
        MuxASel = 2'b10;
      end

      if (I == 1) begin
        // Direct address
        // <- M[AR]
        MuxASel = 2'b01;
        ARF_OutBSel = 2'b00;
        Mem_CS = 0; // enable memory
        Mem_WR = 0; // read
      end

      s_counter_funsel = 2'b00; // reset counter
      ARF_RSel = 4'b0000;
      IR_Enable = 0;
    end  

    // ST
    if (T[3] && K[13]) begin
      // M[AR] <-
      Mem_CS = 0; // enable memory
      Mem_WR = 1; // write
      ARF_OutBSel = 2'b00;

      // <- Rx 
      ALU_FunSel = 4'b0001;
      if (d_rsel[0]) RF_OutBSel = 3'b100;
      if (d_rsel[1]) RF_OutBSel = 3'b101;
      if (d_rsel[2]) RF_OutBSel = 3'b110;
      if (d_rsel[3]) RF_OutBSel = 3'b111;

      s_counter_funsel = 2'b00; // reset counter
      IR_Enable = 0;
      ARF_RSel = 4'b0000;
    end  

    // PUL
    if (T[3] && K[14]) begin
      MuxASel = 2'b01;
      // Rx <-
      RF_RSel = {d_rsel[0], d_rsel[1], d_rsel[2], d_rsel[3]};
      RF_FunSel = 2'b01;

      // <- M[SP]
      ARF_OutBSel = 2'b01;
      Mem_CS = 0; // enable memory
      Mem_WR = 0; // read

      // SP <- SP + 1
      ARF_RSel = 4'b0100;
      ARF_FunSel = 2'b11;

      IR_Enable = 0;
      s_counter_funsel = 2'b00; // reset counter
    end  

    // PSH
    if (T[3] && K[15]) begin
      Mem_WR = 0; // read
      // SP <- SP - 1
      ARF_RSel = 4'b0100;
      ARF_FunSel = 2'b10;     
      IR_Enable = 0;
    end  

    if (T[4] && K[15]) begin 
      // M[SP] <- 
      Mem_CS = 0; // enable memory
      Mem_WR = 1; // write
      ARF_OutBSel = 2'b01;
      ARF_RSel = 4'b0000;
      
      // <- Rx
      ALU_FunSel = 4'b0001;
      if (d_rsel[0]) RF_OutBSel = 3'b100;
      if (d_rsel[1]) RF_OutBSel = 3'b101;
      if (d_rsel[2]) RF_OutBSel = 3'b110;
      if (d_rsel[3]) RF_OutBSel = 3'b111;

      s_counter_funsel = 2'b00; // reset counter
      IR_Enable = 0;
    end
    
    end

  end
endmodule
