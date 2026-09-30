module alu_tb;
  reg [31:0] A;
  reg [31:0] B;
  reg [3:0] OP;

  wire LE;
  wire EQ;
  wire GT;
  wire [31:0] Out;

  alu dut(
    .A (A),
    .B (B),
    .OP (OP),
    .LE (LE),
    .EQ (EQ),
    .GT (GT),
    .Out (Out)
  );

  initial begin
    
    //---Addition---
    $display("%s Addition %s", {32{"-"}}, {32{"-"}});
    A = 32'd10;
    B = 32'd5;
    OP = 4'b0000;
    #1;
    $display("OP = %b  | A = %0d   | B = %0d    | Out = %0d   | LE = %b  | EQ = %b  | GT = %b", OP, A, B, Out, LE, EQ, GT);

    A = 32'd10;
    B = -32'd5;
    OP = 4'b0000;
    #1;
    $display("OP = %b  | A = %0d   | B = %0d   | Out = %0d    | LE = %b  | EQ = %b  | GT = %b", OP, A, $signed(B), Out, LE, EQ, GT);

    A = -32'd10;
    B = 32'd5;
    OP = 4'b0000;
    #1;
    $display("OP = %b  | A = %0d  | B = %0d    | Out = %0d   | LE = %b  | EQ = %b  | GT = %b", OP, $signed(A), B, $signed(Out), LE, EQ, GT);
    
    A = -32'd10;
    B = -32'd5;
    OP = 4'b0000;
    #1;

    $display("OP = %b  | A = %0d  | B = %0d   | Out = %0d  | LE = %b  | EQ = %b  | GT = %b", OP, $signed(A), $signed(B), $signed(Out), LE, EQ, GT);

    //---Substraction---
    $display("");
    $display("%s Substraction %s", {30{"-"}}, {30{"-"}});
    A = 32'd10;
    B = 32'd5;
    OP = 4'b0001;
    #1;

    $display("OP = %b  | A = %0d   | B = %0d    | Out = %0d    | LE = %b  | EQ = %b  | GT = %b", OP, $signed(A), B, $signed(Out), LE, EQ, GT);

    A = 32'd10;
    B = -32'd5;
    OP = 4'b0001;
    #1;

    $display("OP = %b  | A = %0d   | B = %0d   | Out = %0d   | LE = %b  | EQ = %b  | GT = %b", OP, $signed(A), $signed(B), $signed(Out), LE, EQ, GT);

    A = -32'd10;
    B = 32'd5;
    OP = 4'b0001;
    #1;

    $display("OP = %b  | A = %0d  | B = %0d    | Out = %0d  | LE = %b  | EQ = %b  | GT = %b", OP, $signed(A), $signed(B), $signed(Out), LE, EQ, GT);

    A = -32'd10;
    B = -32'd5;
    OP = 4'b0001;
    #1;
    $display("OP = %b  | A = %0d  | B = %0d   | Out = %0d   | LE = %b  | EQ = %b  | GT = %b", OP, $signed(A), $signed(B), $signed(Out), LE, EQ, GT);

    //---AND---
    $display("");
    $display("%s AND %s", {35{"-"}}, {35{"-"}});
    A = 32'd10;
    B = 32'd5;
    OP = 4'b0010;
    #1;

    $display("OP = %b  | A = %b | B = %b | Out = %b | LE = %b  | EQ = %b  | GT = %b", OP, A[3:0], B[3:0], Out[3:0], LE, EQ, GT);

    //---OR---
    $display("");
    $display("%s OR %s", {35{"-"}}, {35{"-"}});

    A = 32'd10;
    B = 32'd5;
    OP = 4'b0011;
    #1
  
    $display("OP = %b  | A = %b | B = %b | Out = %b | LE = %b  | EQ = %b  | GT = %b", OP, A[3:0], B[3:0], Out[3:0], LE, EQ, GT);

    //---XOR---
    $display("");
    $display("%s XOR %s", {35{"-"}}, {35{"-"}});
    A = 32'd10;
    B = 32'd5;
    OP = 4'b0100;
    #1;
    $display("OP = %b  | A = %b | B = %b | Out = %b | LE = %b  | EQ = %b  | GT = %b", OP, A[3:0], B[3:0], Out[3:0], LE, EQ, GT);

    //---NOR---
    $display("");
    $display("%s NOR %s", {35{"-"}}, {35{"-"}});
    A = 32'd10;
    B = 32'd5;
    OP = 4'b0101;
    #1;
    $display("OP = %b  | A = %b | B = %b | Out = %b | LE = %b  | EQ = %b  | GT = %b", OP, A[3:0], B[3:0], Out[3:0], LE, EQ, GT);

    //---SLT Test---
    $display("");
    $display("%s SLT %s", {35{"-"}}, {35{"-"}});

    A = 32'd10;
    B = 32'd5;
    OP = 4'b0110;
    #1;
    $display("OP = %b  | A = %0d   | B = %0d    | Out = %0d    | LE = %b  | EQ = %b  | GT = %b", OP, A, B, Out, LE, EQ, GT);

    A = 32'd4;
    B = 32'd5;
    OP = 4'b0110;
    #1;
    $display("OP = %b  | A = %0d    | B = %0d     | Out = %0d    | LE = %b  | EQ = %b  | GT = %b", OP, A, B, Out, LE, EQ, GT);

    //---Output A Test---
    $display("");
    $display("%s Output A %s", {32{"-"}}, {32{"-"}});
    A = 32'd4;
    B = 32'd5;
    OP = 4'b0111;
    #1;
    $display("OP = %b  | A = %0d   | B = %0d     | Out = %0d    | LE = %b  | EQ = %b  | GT = %b", OP, A, B, Out, LE, EQ, GT);

    //---Output B Test---
    $display("");
    $display("%s Output B %s", {32{"-"}}, {32{"-"}});
    A = 32'd4;
    B = 32'd5;
    OP = 4'b1000;
    #1;
    $display("OP = %b  | A = %0d   | B = %0d     | Out = %0d    | LE = %b  | EQ = %b  | GT = %b", OP, A, B, Out, LE, EQ, GT);

    //---SLL---
    $display("");
    $display("%s SLL %s", {66{"-"}}, {66{"-"}});
    A = 32'd2;
    B = 32'd3;
    OP = 4'b1001;
    #1;
    $display("OP = %b  | A = %0d   | B = %b     | Out = %b    | LE = %b  | EQ = %b  | GT = %b", OP, A[4:0], B, Out, LE, EQ, GT);

    //---SRL---
    $display("");
    $display("%s SRL %s", {66{"-"}}, {66{"-"}});
    A = 32'd2;
    B = 32'd12;
    OP = 4'b1010;
    #1;
    $display("OP = %b  | A = %0d   | B = %b     | Out = %b    | LE = %b  | EQ = %b  | GT = %b", OP, A[4:0], B, Out, LE, EQ, GT);

    A = 32'd3;
    B = -32'd5;
    OP = 4'b1010;
    #1;
    $display("OP = %b  | A = %0d   | B = %0b     | Out = %b    | LE = %b  | EQ = %b  | GT = %b", OP, A[4:0], B, Out, LE, EQ, GT);

    //---SRA---
    $display("");
    $display("%s SRA %s", {66{"-"}}, {66{"-"}});
    A = 32'd2;
    B = -32'd5;
    OP = 4'b1011;
    #1;
    $display("OP = %b  | A = %0d   | B = %b     | Out = %b    | LE = %b  | EQ = %b  | GT = %b", OP, A[4:0], B, Out, LE, EQ, GT);

    A = 32'd2;
    B = 32'd4;
    OP = 4'b1011;
    #1;
    $display("OP = %b  | A = %0d   | B = %b     | Out = %b    | LE = %b  | EQ = %b  | GT = %b", OP, A[4:0], B, Out, LE, EQ, GT);

    $finish;
  end 

endmodule