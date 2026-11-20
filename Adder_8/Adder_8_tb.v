module Adder_8_tb;

  reg[31:0] PC;

  wire[31:0] R;

  Adder_8 dut(
    .PC(PC),
    .R(R)
  );

  initial begin
    PC = 32'd8;

    $monitor("R = %0d", R);
  end

endmodule