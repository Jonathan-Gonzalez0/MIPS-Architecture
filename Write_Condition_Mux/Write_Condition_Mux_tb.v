module Write_Condition_Mux_tb;

  reg one;
  reg not_zero;
  reg zero;
  reg BranchTaken;
  reg[1:0] S;

  wire Out;

  Write_Condition_Mux dut(
    .one(one),
    .not_zero(not_zero),
    .zero(zero),
    .BranchTaken(BranchTaken),
    .S(S),

    .Out(Out)
  );

  initial begin
    one = 1'b1;
    not_zero = 1'b1;
    zero = 1'b0;
    BranchTaken = 1'b1;
    S = 2'b00;

    $monitor("S = %b, Out = %b",S,  Out);
    
    #2
    S = 2'b01;

    #2
    S = 2'b10;

    #2 
    S = 2'b11;


  end


endmodule