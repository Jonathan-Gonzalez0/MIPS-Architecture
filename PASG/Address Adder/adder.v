module address_adder(
  input wire [31:0] nPC,
  output reg [31:0] R
);

  always@(*) begin
    R = nPC + 32'd4;
  end
endmodule