module DataMemory(
  input wire[31:0] DI,
  input wire[31:0] A,
  input wire RW,
  input wire E,
  input wire[1:0] size,
  input wire SE,

  output reg[31:0] DO
);

  reg[7:0] Mem [0:511];

  always @(*) begin
    if(RW && E) begin
        case(size)
          2'b00: Mem[A] = DI[7:0];
          2'b01: {Mem[A], Mem[A+1]} = DI[15:0]; 
          default: {Mem[A], Mem[A+1], Mem[A+2], Mem[A+3]} = DI[31:0];
        endcase
      end
    else begin
      case(size)
        2'b00: DO = {{24{SE & Mem[A][7]}}, Mem[A]};
        2'b01: DO = {{{16{SE & Mem[A][7]}}}, Mem[A], Mem[A+1]};
        default: DO = {Mem[A], Mem[A+1], Mem[A+2], Mem[A+3]};
      endcase
    end
  end

endmodule