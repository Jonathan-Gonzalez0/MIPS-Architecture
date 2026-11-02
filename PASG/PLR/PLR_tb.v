`timescale 1ns/1ps
module PLR_tb;
  reg Rst;
  reg Clr;
  reg[31:0] D0;
  reg[31:0] D1;
  reg Clk;
  reg LE;
  wire[31:0] Q0;
  wire[31:0] Q1;

  PLR dut(
    .Rst (Rst),
    .Clr (Clr),
    .D0 (D0),
    .D1 (D1),
    .Clk (Clk),
    .LE (LE),
    .Q0 (Q0),
    .Q1 (Q1)
  );

  initial begin
    fork
      Rst = 1'b0;
      Clr = 1'b0;
      D0 = 32'd0;
      D1 = 32'd0;
      Clk = 1'b0;
      LE = 1'b0;
      $monitor("Q0 = %0d, Q1 = %0d", Q0, Q1);

      #2 Clk = 1'b1;

      #4 Clk = 1'b0;
      #4 Rst = 1'b1;

      #6 Clk = 1'b1;

      #8 Clk = 1'b0;
      #8 Rst = 1'b0;
      #8 Clr = 1'b1;

      #10 Clk = 1'b1;

      #12 Clk = 1'b0;
      #12 Rst = 1'b1;
      #12 Clr = 1'b1;

      #14 Clk = 1'b1;

      #16 Clk = 1'b0;
      #16 Rst = 1'b0;
      #16 Clr = 1'b0;
      #16 D0 = 32'd3;

      #18 Clk = 1'b1;

      #20 Clk = 1'b0;
      #20 Rst = 1'b1;
      #20 Clr = 1'b0;
      #20 D0 = 32'd3;

      #22 Clk = 1'b1;

      #24 Clk = 1'b0;
      #24 Rst = 1'b1;
      #24 Clr = 1'b0;
      #24 D0 = 32'd3;

      #26 Clk = 1'b1;

      #28 Clk = 1'b0;
      #28 Rst = 1'b0;
      #28 Clr = 1'b1;
      #28 D0 = 32'd3;

      #30 Clk = 1'b1;

      #32 Clk = 1'b0;
      #32 Rst = 1'b1;
      #32 Clr = 1'b1;
      #32 D0 = 32'd3;

      #34 Clk = 1'b1;

      #36 Clk = 1'b0;
      #36 Rst = 1'b0;
      #36 Clr = 1'b0;
      #36 D0 = 32'd3;
      #36 D1 = 32'd4;

      #38 Clk = 1'b1;

      #40 Clk = 1'b0;
      #40 Rst = 1'b0;
      #40 Clr = 1'b0;
      #40 D0 = 32'd3;
      #40 D1 = 32'd4;
      #40 LE = 1'b1;

      #42 Clk = 1'b1;

      #44 Clk = 1'b0;
      #44 Rst = 1'b1;
      #44 Clr = 1'b0;
      #44 D0 = 32'd3;
      #44 D1 = 32'd4;
      #44 LE = 1'b1;

      #46 Clk = 1'b1;

      #48 Clk = 1'b0;
      #48 Rst = 1'b0;
      #48 Clr = 1'b1;
      #48 D0 = 32'd3;
      #48 D1 = 32'd4;
      #48 LE = 1'b1;

      #50 Clk = 1'b1;
  join
  end
endmodule