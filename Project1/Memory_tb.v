module Memory_tb;
    reg[7:0]  address;
    reg[7:0]  data;
    reg       wr; //Read = 0, Write = 1
    reg       cs; //Chip is enable when cs = 0
    reg       clock;
    wire[7:0] o; // Output

    Memory uut(
        address,
        data,
        wr,
        cs,
        clock,
        o
    );

    always begin
        clock = 0;
        #5;
        clock = 1;
        #5;
        address++;
        $display("%x", o);
        if (address == 255)
            $finish;
    end

    initial begin
        wr = 0;
        clock = 0;
        cs = 0;
        address = 8'b0;
    end
endmodule