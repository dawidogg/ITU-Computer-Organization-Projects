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


