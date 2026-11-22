module Writeback_Data(
    input wire[31:0] DO,
    input wire[31:0] ALU,
    input wire S,

    output reg[31:0] Out
  );

  always @(*) begin
    if(S)
      Out = ALU;
    else
      Out = DO;
  end
endmodule