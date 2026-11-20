module FWD_A_tb;
  reg[31:0] RF;
  reg[31:0] R_EX;
  reg[31:0] R_MEM;
  reg[31:0] R_WB;
  reg[1:0] S;

  wire[31:0] Out;

  FWD_A dut(
    .RF(RF),
    .R_EX(R_EX),
    .R_MEM(R_MEM),
    .R_WB(R_WB),
    .S(S),
    .Out(Out)
  );

  initial begin
    RF = 32'd1;
    R_EX = 32'd2;
    R_MEM = 32'd3;
    R_WB = 32'd4;
    S = 2'b00;

    $monitor("RF = %0d, R_EX = %0d, R_MEM = %0d, R_WB = %0d, S = %b, Out = %0d",RF, R_EX, R_MEM, R_WB, S, Out);
    
    #2
    S = 2'b01;

    #2
    S = 2'b10;

    #2
    S = 2'b11;
  end
endmodule