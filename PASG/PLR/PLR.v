module PLR (
  input wire Rst,
  input wire Clr,
  input wire[31:0] D0,
  input wire[31:0] D1,
  input wire Clk,
  input wire LE,
  output reg[31:0] Q0,
  output reg[31:0] Q1
);

  always @(posedge Clk) begin
    if(Rst || Clr) begin
      Q0 <= 32'd0;
      Q1 <= 32'd0;
    end
    else if (LE)begin
      Q0 <= D0;
      Q1 <= D1;
    end
  end

endmodule