module soh_tb;

  reg [31:0] RB;
  reg [15:0] I;
  reg [1:0] OS2;
  wire [31:0] OB;

  soh dut(
    .RB (RB),
    .I (I),
    .OS2 (OS2),
    .OB (OB)
  );

  initial begin
    $monitor("time = %0t OS2 = %b RB = %0d I = %0d OB = %0d", $time, OS2, RB, I, OB);

    RB = 32'd10;
    I = 16'd5;

    OS2 = 2'b00;
    #1;

    OS2 = 2'b01;
    #1;

    OS2 = 2'b10;
    #1;

    OS2 = 2'b11;
    #1;

    I = -16'd5;
    OS2 = 2'b01;
    #1;

    $display("OB signed = %0d", $signed(OB));
    #1;

  end

endmodule