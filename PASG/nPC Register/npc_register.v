module npc_register(
  input wire Clk,
  input wire Reset,
  input wire LE,
  input wire [31:0] D,
  output reg [31:0] Q
);

  always @(posedge Clk) begin
    if(Reset)
      Q <= 32'd0;
    else if (LE)
      Q <= D;
  end

endmodule