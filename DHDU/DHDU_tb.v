module DHDU_tb;
  reg[4:0] ID_RA;
  reg[4:0] ID_RB;
  reg SRA;
  reg SRB;
  reg[4:0] EX_RD;
  reg [4:0] MEM_RD;
  reg[4:0] WB_RD;
  reg EX_RF_LE;
  reg MEM_RF_LE;
  reg WB_RF_LE;
  reg EX_L;

  wire[1:0] A;
  wire[1:0] B;
  wire LE;
  wire NOP;

  DHDU dut(
    .ID_RA(ID_RA),
    .ID_RB(ID_RB),
    .SRA(SRA),
    .SRB(SRB),
    .EX_RD(EX_RD),
    .MEM_RD(MEM_RD),
    .WB_RD(WB_RD),
    .EX_RF_LE(EX_RF_LE),
    .MEM_RF_LE(MEM_RF_LE),
    .WB_RF_LE(WB_RF_LE),
    .EX_L(EX_L),
    .A(A),
    .B(B),
    .LE(LE),
    .NOP(NOP)
  );

  initial  begin
    ID_RA = 5'd0;
    ID_RB = 5'd5;
    SRA = 1'b1;
    SRB = 1'b0;
    EX_RD = 5'd0;
    MEM_RD = 5'd0;
    WB_RD = 5'd0;
    EX_RF_LE = 1'b0;
    MEM_RF_LE = 1'b0;
    WB_RF_LE = 1'b0;
    EX_L = 1'b0;
    $monitor("ID_RA = %b, ID_RB = %b, SRA = %b, SRB = %b, EX_RD = %b, MEM_RD = %b, WB_RD = %b, EX_RF_LE = %b, MEM_RF_LE = %b, WB_RF_LE = %b, EX_L = %b, A = %b, B = %b, LE = %b, NOP = %b",
    ID_RA,ID_RB,SRA,SRB,EX_RD,MEM_RD,WB_RD,EX_RF_LE,MEM_RF_LE,WB_RF_LE,EX_L,A,B,LE,NOP);
    #2

    ID_RA = 5'd5;
    ID_RB = 5'd16;
    EX_RD = 5'd5;
    EX_RF_LE = 1'b1;
    
    #2
    ID_RB = 5'd17;
    EX_RD = 5'd16;
    MEM_RD = 5'd5;
    MEM_RF_LE = 1'b1;
    EX_L = 1'b1;

    #2
    ID_RA = 5'd5;
    ID_RB = 5'd18;
    EX_RD = 5'd17;
    MEM_RD = 5'd16;
    WB_RD = 5'd5;
    WB_RF_LE = 1'b1;

    #2 
    ID_RA = 5'd16;
    ID_RB = 5'd1;
    EX_RD = 5'd18;
    MEM_RD = 5'd17;
    WB_RD = 5'd16;

    #2
    ID_RA = 5'd0;
    ID_RB = 5'd0;
    SRA = 1'b0;
    EX_RD = 5'd31;
    MEM_RD = 5'd18;
    WB_RD = 5'd17;
    EX_L = 1'b0;

    #2
    EX_RD = 5'd0;
    MEM_RD = 5'd31;
    WB_RD = 5'd18;
    EX_RF_LE = 1'b0;

    #2
    MEM_RD = 5'd0;
    WB_RD = 5'd31;
    MEM_RF_LE = 1'b0;

    #2
    WB_RD = 5'd0;
    WB_RF_LE = 1'b0;

    #2
    ID_RA = 5'd18;
    ID_RB = 5'd17;
    SRA = 1'b1;
    SRB = 1'b1;

    #2
    ID_RA = 5'd0;
    ID_RB =5'd0;
    SRA = 1'b0;
    SRB = 1'b0;
    EX_RD = 5'd6;
    EX_RF_LE = 1'b1;

    #2
    EX_RD = 5'd0;
    EX_RF_LE = 1'b0;
    MEM_RD = 5'd6;
    MEM_RF_LE = 1'b1;

    #2
    ID_RA = 5'd5;
    SRA = 1'b1;
    ID_RB = 5'd6;
    SRB = 1'b1;
    MEM_RD = 5'd0;
    MEM_RF_LE = 1'b0;
    WB_RD = 5'd6;
    WB_RF_LE = 1'b1;

    #2
    ID_RA = 5'd0;
    SRA = 1'b0;
    ID_RB = 5'd0;
    SRB = 1'b0;
    EX_RD = 5'd6;
    WB_RD = 5'd0;
    WB_RF_LE = 1'b0;

    #2
    EX_RD = 5'd0;
    MEM_RD = 5'd6;
    WB_RD = 5'd0;

    #2
    WB_RD = 5'd0;


  end
endmodule