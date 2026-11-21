module Branch_Control_Unit_tb;

  reg LE;
  reg EQ;
  reg GT;
  reg[2:0] BranchType;

  wire BranchTaken;

  Branch_Control_Unit dut(
    .LE(LE),
    .EQ(EQ),
    .GT(GT),
    .BranchType(BranchType),

    .BranchTaken(BranchTaken)
  );

  initial begin
    LE = 1'b1;
    EQ = 1'b0;
    GT = 1'b0;
    BranchType = 3'b000;
    $monitor("BranchType = %b, BranchTaken = %b", BranchType, BranchTaken);

    #2
    BranchType = 3'b001;

    #2
    BranchType = 3'b010;

    #2
    BranchType = 3'b011;

    #2
    BranchType = 3'b100;

    #2
    BranchType = 3'b101;

    #2
    BranchType = 3'b110;
    
  end

endmodule