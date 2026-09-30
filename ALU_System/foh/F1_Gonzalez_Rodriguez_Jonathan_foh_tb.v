module foh_tb;

  reg [31:0] RA;
  reg [4:0] SA;
  reg OS1;
  wire [31:0] OA;

  foh dut (
    .RA (RA),
    .SA (SA),
    .OS1 (OS1),
    .OA (OA)
  );

  initial begin
    $monitor("time= %0t OS1 = %b RA = %0d SA = %0d OA = %0d", $time, OS1, RA, SA, OA);

    RA = 32'd10;
    SA = 5'd5;

    OS1 = 1'b0;
    #1;

    OS1 = 1'b1;
    #1;

    $finish;
  end

endmodule