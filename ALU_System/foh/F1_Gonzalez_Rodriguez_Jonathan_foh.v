module foh (
  input wire [31:0] RA,
  input wire [4:0] SA,
  input wire OS1,
  output wire [31:0] OA
);

  assign OA = OS1 ? {27'b000000000000000000000000000, SA} : RA;
  
endmodule