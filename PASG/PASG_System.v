module PASG_System(
  input wire Reset,
  input wire LE,
  input wire Clk,
  input wire J,
  input wire Clr, 
  input wire[31:0] TAI,
  input wire[31:0] RS,
  input wire[31:0] Ins,

  output wire[31:0] PC,
  output wire[31:0] I,
  output wire[31:0] TAO
);
  wire[31:0] R;
  wire[31:0] A0;
  wire[31:0] nPC;
  wire[31:0] Q0;

  npc_register nPCR(
    .Clk(Clk),
    .Reset(Reset),
    .LE(LE),
    .D(R),
    .Q(A0)
  );

  jump_multiplexer Jump(
    .S(J),
    .A1(TAO),
    .A0(A0),
    .O(nPC)
  );

  address_adder Adder(
    .nPC(nPC),
    .R(R)
  );

  pc_register PCR(
    .Clk(Clk),
    .Reset(Reset),
    .LE(LE),
    .D(nPC),
    .Q(PC)
  );

  PLR PLRegister(
    .Rst(Reset),
    .Clr(Clr),
    .D0(PC),
    .D1(Ins),
    .Clk(Clk),
    .LE(LE),
    .Q0(Q0),
    .Q1(I)
  );

  TAG TAGModule(
    .PC(Q0),
    .I(I),
    .RS(RS),
    .TAO(TAO)
  );


endmodule