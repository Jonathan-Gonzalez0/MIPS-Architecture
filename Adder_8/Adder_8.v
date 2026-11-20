module Adder_8(
  input wire[31:0] PC,

  output reg[31:0] R
);

always@(*)begin
  R = PC + 32'd8;
end

endmodule