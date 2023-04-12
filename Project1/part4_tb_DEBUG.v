module Project1Test_debug();
    //Input Registers of ALUSystem
    reg[2:0] RF_O1Sel; 
    reg[2:0] RF_O2Sel; 
    reg[1:0] RF_FunSel;
    reg[3:0] RF_RSel;
    reg[3:0] RF_TSel;
    reg[3:0] ALU_FunSel;
    reg[1:0] ARF_OutASel; 
    reg[1:0] ARF_OutBSel; 
    reg[1:0] ARF_FunSel;
    reg[3:0] ARF_RSel;
    reg      IR_LH;
    reg      IR_Enable;
    reg[1:0]      IR_Funsel;
    reg      Mem_WR;
    reg      Mem_CS;
    reg[1:0] MuxASel;
    reg[1:0] MuxBSel;
    reg MuxCSel;
    reg      Clock;
    
    //output
    wire[7:0] out;
    //provisional outputs for debugging
    ///*
    wire[7:0] p_RF_O1;
    wire[7:0] p_RF_O2;
    wire[7:0] p_ALU_Out;
    wire[3:0] p_ALU_ZCNO;
    wire[7:0] p_ARF_OutA;
    wire[7:0] p_MEM_Address;
    wire[7:0] p_MEM_Out;
    wire[15:0] p_IR_Out;
    wire[7:0] p_MUXA_Out;
    wire[7:0] p_MUXB_Out;
    wire[7:0] p_MUXC_Out;
    //*/
    
    //Test Bench Connection of ALU System
    ALU_System _ALUSystem(
    .RF_OutASel(RF_O1Sel), 
    .RF_OutBSel(RF_O2Sel), 
    .RF_FunSel(RF_FunSel),
    .RF_RSel(RF_RSel),
    .RF_TSel(RF_TSel),
    .ALU_FunSel(ALU_FunSel),
    .ARF_OutASel(ARF_OutASel), 
    .ARF_OutBSel(ARF_OutBSel), 
    .ARF_FunSel(ARF_FunSel),
    .ARF_RSel(ARF_RSel),
    .IR_LH(IR_LH),
    .IR_Enable(IR_Enable),
    .IR_Funsel(IR_Funsel),
    .Mem_WR(Mem_WR),
    .Mem_CS(Mem_CS),
    .MuxASel(MuxASel),
    .MuxBSel(MuxBSel),
    .MuxCSel(MuxCSel),
    .Clock(Clock)
    
     //output
    ,.out(out)
    //provisional outputs
    ///*
    ,.p_RF_O1(p_RF_O1)
    ,.p_RF_O2(p_RF_O2)
    ,.p_ALU_Out(p_ALU_Out)
    ,.p_ALU_ZCNO(p_ALU_ZCNO)
    ,.p_ARF_OutA(p_ARF_OutA)
    ,.p_MEM_Address(p_MEM_Address)
    ,.p_MEM_Out(p_MEM_Out)
    ,.p_IR_Out(p_IR_Out)
    ,.p_MUXA_Out(p_MUXA_Out)
    ,.p_MUXB_Out(p_MUXB_Out)
    ,.p_MUXC_Out(p_MUXC_Out)
    
    
    //*/
    );
    
    //Test Vector Variables
    reg [41:0] VectorNum, Errors, TotalLine; 
    reg [41:0] TestVectors[3:0];
    reg Reset, Operation;
    initial begin
        Reset = 0;
    end
    //Clock Signal Generation
    always 
    begin
        Clock = 1; #15; Clock = 0; #15; // 10ns period
    end
    
    //Read Test Bench Values
    initial begin
        $readmemb("TestBench.mem", TestVectors); // Read vectors
        VectorNum = 0; Errors = 0; TotalLine=0; Reset=0;// Initialize
    end
    
    // Apply test vectors on rising edge of clock
    always @(posedge Clock)
    begin
        #1; 
        {Operation, RF_O1Sel, RF_O2Sel, RF_FunSel, 
        RF_RSel, RF_TSel, ALU_FunSel, ARF_OutASel, ARF_OutBSel, 
        ARF_FunSel, ARF_RSel, IR_LH, IR_Enable, IR_Funsel, 
        Mem_WR, Mem_CS, MuxASel, MuxBSel, MuxCSel} = TestVectors[VectorNum];
    end
    
    // Check results on falling edge of clk
    always @(negedge Clock)
        if (~Reset) // skip during reset
        begin
            $display("");
            $display("Input Values:");
            $display("Operation: %d", Operation);
            $display("Register File: O1Sel: %d, O2Sel: %d, FunSel: %d, RSel: %d, TSel: %d", RF_O1Sel, RF_O2Sel, RF_FunSel, RF_RSel, RF_TSel);            
            $display("ALU FunSel: %d", ALU_FunSel);
            $display("Addres Register File: OutASel: %d, OutBSel: %d, FunSel: %d, Regsel: %d", ARF_OutASel, ARF_OutBSel, ARF_FunSel, ARF_RSel);            
            $display("Instruction Register: LH: %d, Enable: %d, FunSel: %d", IR_LH, IR_Enable, IR_Funsel);            
            $display("Memory: WR: %d, CS: %d", Mem_WR, Mem_CS);
            $display("MuxASel: %d, MuxBSel: %d, MuxCSel: %d", MuxASel, MuxBSel, MuxCSel);
            
            $display("");
            $display("Output Values:");
            $display("Register File: AOut: %d, BOut: %d", _ALUSystem.RF_O1, _ALUSystem.RF_O2);            
            $display("ALUOut: %d, ALUOutFlag: %d, ALUOutFlags: Z:%d, C:%d, N:%d, O:%d,", _ALUSystem.OutALU, _ALUSystem.ALU_ZCNO, _ALUSystem.ALU_ZCNO[3],_ALUSystem.ALU_ZCNO[2],_ALUSystem.ALU_ZCNO[1],_ALUSystem.ALU_ZCNO[0]);
            $display("Address Register File: AOut: %d, BOut (Address): %d", _ALUSystem.ARF_OutA, _ALUSystem.MEM_address);            
            $display("Memory Out: %d", _ALUSystem.MEM_out);            
            $display("Instruction Register: IROut: %d", _ALUSystem.IR_out);            
            $display("MuxAOut: %d, MuxBOut: %d, MuxCOut: %d", _ALUSystem.MUXA_out, _ALUSystem.MUXB_out, _ALUSystem.MUXC_out);
            
            // increment array index and read next testvector
            VectorNum = VectorNum + 1;
            if (TestVectors[VectorNum] === 42'bx)
            begin
                $display("%d tests completed.",
                VectorNum);
                $finish; // End simulation
            end
        end
endmodule