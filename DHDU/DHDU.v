module DHDU(
  input wire[4:0] ID_RA,
  input wire[4:0] ID_RB,
  input wire SRA,
  input wire SRB,
  input wire[4:0] EX_RD,
  input wire[4:0] MEM_RD,
  input wire[4:0] WB_RD,
  input wire EX_RF_LE,
  input wire MEM_RF_LE,
  input wire WB_RF_LE,
  input wire EX_L,

  output reg[1:0] A,
  output reg[1:0] B,
  output reg LE,
  output reg NOP
);

always@(*) begin
    A   = 2'b00;
    B   = 2'b00;
    LE  = 1'b1;
    NOP = 1'b0;

  if(SRA && EX_RF_LE && (EX_RD != 5'd0) && ID_RA == EX_RD)begin
    if(EX_L) begin
      LE = 1'b0;
      NOP = 1'b1;
    end
    else
      A = 2'b01;
  end 
  else if(SRA && MEM_RF_LE && (MEM_RD != 5'd0) && ID_RA == MEM_RD)begin
    A = 2'b10;
  end
  else if(SRA && WB_RF_LE && (WB_RD != 5'd0) && ID_RA == WB_RD)
    A = 2'b11;


  if(SRB && EX_RF_LE && (EX_RD != 5'd0) && ID_RB == EX_RD)begin
    if(EX_L) begin
      LE = 1'b0;
      NOP = 1'b1;
    end
    else
      B = 2'b01;
  end 
  else if(SRB && MEM_RF_LE && (MEM_RD != 5'd0) && ID_RB == MEM_RD)begin
    B = 2'b10;
  end
  else if(SRB && WB_RF_LE && (WB_RD != 5'd0) && ID_RB == WB_RD)
    B = 2'b11;
end
endmodule