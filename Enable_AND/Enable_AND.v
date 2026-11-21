module Enable_AND(
  input wire A,
  input wire B,

  output reg Out
  );

  always @(*) begin
    Out = A & B;
  end

endmodule