`timescale 1ns / 1ps

module Project2Test();
    reg Clock, Reset;
    initial begin 
        Reset = 1;
        #15;
        Reset = 0;
    end
    always begin
        Clock = 1; #5; Clock = 0; #5; // 10ns period
    end
    CPUSystem _CPUSystem( 
            .Clock(Clock), .Reset(Reset)
        );
endmodule
