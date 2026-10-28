module adder_tb;
  reg[31:0] nPC;
  wire[31:0] R;
  
  address_adder dut(
    .nPC (nPC),
    .R (R)
  );

  initial begin
    $monitor("R = %0d", R);
    
    nPC = 32'd0;

    #1
    nPC = 32'd15;

    #1
    nPC = 32'd33;
    
  end
endmodule