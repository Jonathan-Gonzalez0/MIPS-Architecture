module soh (
  input wire [31:0] RB,
  input wire [15:0] I,
  input wire [1:0] OS2,
  output reg [31:0] OB
  );

  always @(*) begin
    case(OS2)
      2'b00: OB = RB;
      2'b01: OB = {{16{I[15]}}, I};
      2'b10: OB = {I, 16'b0};
      default OB = 32'b0;
    endcase
  end

endmodule