module TAG(
  input wire[31:0] PC,
  input wire[31:0] I,
  input wire[31:0] RS,
  output reg[31:0] TAO 
);

  always @(*) begin
    TAO = 32'd0;
    case(I[31:26])
        6'b000100: TAO = PC + 4 + $signed(32'sd4 * $signed(I[15:0]));
        6'b000001: begin
          if(I[20:16] == 5'b10001 || I[20:16] == 5'b00001 || I[20:16] == 5'd0 || I[20:16] == 5'b10000)
              TAO = PC + 4 + $signed(32'sd4 * $signed(I[15:0]));
        end
        6'b000111:begin
          if(I[20:16] == 5'd0)
            TAO = PC + 4 + $signed(32'sd4 * $signed(I[15:0]));
        end
        6'b000110: begin
          if(I[20:16] == 32'd0)
            TAO = PC + 4 + $signed(32'sd4 * $signed(I[15:0]));
        end
        6'b000101: TAO = PC + 4 + $signed(32'sd4 * $signed(I[15:0]));
        6'b000010: TAO = ((PC + 32'd4) & 32'hF0000000) | {4'b0000, I[25:0], 2'b00};
        6'b000011: TAO = ((PC + 32'd4) & 32'hF0000000) | {4'b0000, I[25:0], 2'b00};
        6'b000000: if(I[5:0] == 6'b001001 || I[5:0] == 6'b001000) TAO = RS;
        default: TAO = 32'd0;
      endcase
  end

endmodule