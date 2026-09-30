module alu_system(
  input wire [31:0] RA,
  input wire [4:0] SA,
  input wire OS1,
  input wire [31:0] RB,
  input wire [15:0] I,
  input wire [1:0] OS2,
  input wire [3:0] OP,

  output wire LE,
  output wire EQ,
  output wire GT,
  output wire [31:0] Out
);

  wire [31:0] A;
  wire [31:0] B;

  foh first_operand(
    .RA(RA),
    .SA(SA),
    .OS1(OS1),
    .OA(A)
  );

  soh second_operand(
    .RB(RB),
    .I(I),
    .OS2(OS2),
    .OB(B)
  );

  alu calculator(
    .A(A),
    .B(B),
    .OP(OP),
    .Out(Out),
    .LE(LE),
    .EQ(EQ),
    .GT(GT)
  );


endmodule