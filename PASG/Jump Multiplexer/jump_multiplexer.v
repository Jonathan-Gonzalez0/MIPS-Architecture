module jump_multiplexer (
  input wire S,
  input wire[31:0] A1,
  input wire[31:0] A0,
  output reg[31:0] O 
);
  always@(*) begin
    if(S)
      O = A1;
    else
      O = A0;
  end
endmodule