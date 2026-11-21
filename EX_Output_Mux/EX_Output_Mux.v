module EX_Output_Mux(
  input wire[31:0] PC,
  input wire[31:0] ALU,
  input wire S,

  output reg[31:0] O
);

always @(*) begin
  if(S)
    O = PC;
  else
    O = ALU;
end

endmodule