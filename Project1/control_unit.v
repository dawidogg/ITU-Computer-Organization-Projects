// iverilog control_unit.v part4.v part3.v part2c.v part2b.v part2a.v part1.v Memory.v
`timescale 1ns / 1ps

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

module control_unit;
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

  reg clk;

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
    clk,
  );

  reg[1:0] s_counter_funsel;
  register #(.NBits(3)) s_counter (
    .clk(clk), 
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
    // Set sequence counter to increment 
    s_counter_funsel = 2'b11;
    // Disable memory
    Mem_CS = 1;

    clk = 0;
    repeat(50) #1 clk = ~clk; 

    $writememh("RAM_OUT.mem", alu_sys._MEMORY.RAM_DATA);
    $finish;
  end

  always @(*) begin
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
      // direct adressing
      // AR <- IR(8-15)
      MuxBSel = 2'b10;
      ARF_FunSel = 2'b01;
      ARF_RSel = 4'b1000;
      Mem_CS = 1; // disable memory
      s_counter_funsel = 2'b11;
      RF_RSel = 4'b0000;
      IR_Enable = 0;
    end

    // AND
    if (T[3] && K[0]) begin
    
    end  
    
    // OR
    if (T[3] && K[1]) begin
    
    end  

    // NOT
    if (T[3] && K[2]) begin
    
    end  

    // ADD
    if (T[3] && K[3]) begin
    
    end  

    // SUB
    if (T[3] && K[4]) begin
    
    end  

    // LSR
    if (T[3] && K[5]) begin
    
    end  

    // LSL
    if (T[3] && K[6]) begin
    
    end  

    // INC
    if (T[3] && K[7]) begin
    
    end  

    // DEC
    if (T[3] && K[8]) begin
    
    end  

    // BRA
    if (T[3] && K[9]) begin
    
    end  

    // BNE
    if (T[3] && K[10]) begin
    
    end  

    // MOV
    if (T[3] && K[11]) begin
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

      Mem_CS = 1; // disable memory
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
        // <- AR
        MuxASel = 2'b11;
        ARF_OutASel = 2'b00;
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

      s_counter_funsel = 2'b00; // reset counter
      IR_Enable = 0;
    end  

    // PSH
    if (T[3] && K[15]) begin
      // M[SP] <- 
      Mem_CS = 0; // enable memory
      Mem_WR = 1; // write
      ARF_OutBSel = 2'b01;

      // <- Rx
      ALU_FunSel = 4'b0001;
      if (d_rsel[0]) RF_OutBSel = 3'b100;
      if (d_rsel[1]) RF_OutBSel = 3'b101;
      if (d_rsel[2]) RF_OutBSel = 3'b110;
      if (d_rsel[3]) RF_OutBSel = 3'b111;

      // SP <- SP - 1
      ARF_RSel = 4'b0100;
      ARF_FunSel = 2'b10;

      s_counter_funsel = 2'b00; // reset counter
      IR_Enable = 0;
    end  
  
  end
endmodule