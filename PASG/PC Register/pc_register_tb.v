module pc_register_tb;
  reg Clk;
  reg Reset;
  reg LE;
  reg[31:0] D;
  wire[31:0] Q;

  pc_register dut(
    .Clk (Clk),
    .Reset (Reset),
    .LE (LE),
    .D (D),
    .Q (Q)
  );

  initial begin
    Clk = 1'b0;
    Reset = 1'b0;
    LE = 1'b0;
    D = 32'b00000000000000000000000000000001;
    #1
    $display("Q = %b", Q);

    Clk = 1'b1;
    Reset = 1'b0;
    LE = 1'b0;
    D = 32'b00000000000000000000000000000001;
    #1
    $display("Q = %b", Q);

    Clk = 1'b0;
    Reset = 1'b0;
    LE = 1'b0;
    D = 32'b00000000000000000000000000000011;
    #1
    $display("Q = %b", Q);

    Clk = 1'b0;
    Reset = 1'b1;
    LE = 1'b0;
    D = 32'b00000000000000000000000000000011;
    #1
    $display("Q = %b", Q);

    Clk = 1'b1;
    Reset = 1'b1;
    LE = 1'b0;
    D = 32'b00000000000000000000000000000011;
    #1
    $display("Q = %b", Q);
    
    Clk = 1'b0;
    Reset = 1'b0;
    LE = 1'b1;
    D = 32'b00000000000000000000000000000011;
    #1
    $display("Q = %b", Q);

    Clk = 1'b1;
    Reset = 1'b0;
    LE = 1'b0;
    D = 32'b00000000000000000000000000000011;
    #1
    $display("Q = %b", Q);

    Clk = 1'b0;
    Reset = 1'b0;
    LE = 1'b1;
    D = 32'b00000000000000000000000000000011;
    #1
    $display("Q = %b", Q);

    Clk = 1'b1;
    Reset = 1'b0;
    LE = 1'b1;
    D = 32'b00000000000000000000000000000011;
    #1
    $display("Q = %b", Q);

    Clk = 1'b0;
    Reset = 1'b1;
    LE = 1'b1;
    D = 32'b00000000000000000000000000000011;
    #1
    $display("Q = %b", Q);

    Clk = 1'b1;
    Reset = 1'b1;
    LE = 1'b1;
    D = 32'b00000000000000000000000000000011;
    #1
    $display("Q = %b", Q);

    Clk = 1'b0;
    Reset = 1'b0;
    LE = 1'b1;
    D = 32'b00000000000000000000000000000011;
    #1
    $display("Q = %b", Q);

    Clk = 1'b1;
    Reset = 1'b0;
    LE = 1'b1;
    D = 32'b00000000000000000000000000000011;
    #1
    $display("Q = %b", Q);

    Clk = 1'b0;
    Reset = 1'b0;
    LE = 1'b1;
    D = 32'b00000000000000000000000000000011;
    #1
    $display("Q = %b", Q);

    Clk = 1'b1;
    Reset = 1'b0;
    LE = 1'b1;
    D = 32'b00000000000000000000000000000111;
    #1
    $display("Q = %b", Q);
    
  end

endmodule