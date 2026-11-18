module OR_Jump_Branch (
  input wire A,
  input wire B,

  output reg Out
);

  always@(*)begin
    Out = A || B;
  end

endmodule