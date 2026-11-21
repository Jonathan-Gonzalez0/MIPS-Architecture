module Branch_Control_Unit(
  input wire LE,
  input wire EQ,
  input wire GT,
  input wire[2:0] BranchType,

  output reg BranchTaken
  );

  always@(*)begin
    case(BranchType)
      3'b000: BranchTaken = 1'b0;
      3'b001: BranchTaken = EQ;
      3'b010: BranchTaken = ~LE;
      3'b011: BranchTaken = GT;
      3'b100: begin
        if(LE || EQ)
          BranchTaken = 1'b1;
        else
          BranchTaken = 1'b0;
      end
      3'b101: BranchTaken = LE;
      3'b110: BranchTaken = ~EQ;
      default: BranchTaken = 1'b0;
    endcase
  end

endmodule