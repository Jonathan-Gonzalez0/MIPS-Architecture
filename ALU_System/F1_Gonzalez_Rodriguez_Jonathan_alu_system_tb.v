module alu_system_tb;

  reg [31:0] RA;
  reg [4:0] SA;
  reg OS1;
  reg [31:0] RB;
  reg [15:0] I;
  reg [1:0] OS2;
  reg [3:0] OP;

  wire LE;
  wire EQ;
  wire GT;
  wire [31:0] Out;

  alu_system dut(
    .RA(RA),
    .SA(SA),
    .OS1(OS1),
    .RB(RB),
    .I(I),
    .OS2(OS2),
    .OP(OP),
    .LE(LE),
    .EQ(EQ),
    .GT(GT),
    .Out(Out)
  );

  initial begin
    $monitor("OP = %b, Out = %b, LE = %b, EQ = %b, GT = %b", OP, Out, LE, EQ, GT);

    RA = 32'b10011100000000000000000000100010;
    RB = 32'b01110000000000000000000000000011;
    SA = 5'b00101;
    I = 16'b1111111111011000;
    OS1 = 1'b0;
    OS2 = 2'b00;
    OP = 4'b0000;
    #2;

    //Test 1 Addition
    if(Out == 32'b00001100000000000000000000100101)begin
      $display("Test 1: Pass");
    end
    else begin
      $display("Test1: Fail");
      end
    

    //Test 2 Substraction
    $display("");
    OP = 4'b0001;
    #2;
    if(Out == 32'b00101100000000000000000000011111)begin
      $display("Test 2: Pass");
    end
    else begin
      $display("Test 2s: Fail");
      end


    //Test 3 AND
    $display("");
    OP = 4'b0010;
    #2;
    if(Out == 32'b00010000000000000000000000000010)begin
      $display("Test 3: Pass");
    end
    else begin
      $display("Test 3: Fail");
    end


    //Test 4 OR
    $display("");
    OP = 4'b0011;
    #2;
    if(Out == 32'b11111100000000000000000000100011)begin
      $display("Test 4: Pass");
    end
    else begin
      $display("Test 4: Fail");
    end


    //Test 5 XOR
    $display("");
    OP = 4'b0100;
    #2;
    if(Out == 32'b11101100000000000000000000100001)begin
      $display("Test 5: Pass");
    end
    else begin
      $display("Test 5: Fail");
    end

    //Test 6 NOT OR
    $display("");
    OP = 4'b0101;
    #2;
    if(Out == 32'b00000011111111111111111111011100)begin
      $display("Test 6: Pass");
    end
    else begin
      $display("Test 6: Fail");
    end

    //Test 7 SLT
    $display("");
    OP = 4'b0110;
    #2;
    if(Out == 32'b1)begin
      $display("Test 7: Pass");
    end
    else begin
      $display("Test 7: Fail");
    end

    //Test 8 Output A
    $display("");
    OP = 4'b0111;
    #2;
    if(Out == RA)begin
      $display("Test 8: Pass");
    end
    else begin
      $display("Test 8: Fail");
    end

    //Test 9 Output B
    $display("");
    OP = 4'b1000;
    #2;
    if(Out == RB)begin
      $display("Test 9: Pass");
    end
    else begin
      $display("Test 9: Fail");
    end

    //Test 10 SLL
    $display("");
    OP = 4'b1001;
    #2;
    if(Out == 32'b11000000000000000000000000001100)begin
      $display("Test 10: Pass");
    end
    else begin
      $display("Test 10: Fail");
    end

    //Test 11 SRL
    $display("");
    OP = 4'b1010;
    #2;
    if(Out == 32'b00011100000000000000000000000000)begin
      $display("Test 11: Pass");
    end
    else begin
      $display("Test 11: Fail");
    end

    //Test 12 SRA
    $display("");
    OP = 4'b1011;
    #2;
    if(Out == 32'b00011100000000000000000000000000)begin
      $display("Test 12: Pass");
    end
    else begin
      $display("Test 12: Fail");
    end

    //Test 13 
    $display("");
    OP = 4'b1100;
    #2;
    if(Out == 32'b0)begin
      $display("Test 13: Pass");
    end
    else begin
      $display("Test 13: Fail");
    end

    //Test 14 
    $display("");
    OP = 4'b1101;
    #2;
    if(Out == 32'b0)begin
      $display("Test 14: Pass");
    end
    else begin
      $display("Test 14: Fail");
    end

    //Test 15 
    $display("");
    OP = 4'b1110;
    #2;
    if(Out == 32'b0)begin
      $display("Test 15: Pass");
    end
    else begin
      $display("Test 15: Fail");
    end

    //Test 16 
    $display("");
    OP = 4'b1111;
    #2;
    if(Out == 32'b0)begin
      $display("Test 16: Pass");
    end
    else begin
      $display("Test 16: Fail");
    end

    //Test 17  SLL
    $display("");
    OS1 = 1'b1;
    OS2 = 2'b01;
    OP = 4'b1001;
    #2;
    if(Out == 32'b11111111111111111111101100000000)begin
      $display("Test 17: Pass");
    end
    else begin
      $display("Test 17: Fail");
    end

    //Test 18  SRL
    $display("");
    OS1 = 1'b1;
    OS2 = 2'b01;
    OP = 4'b1010;
    #2;
    if(Out == 32'b00000111111111111111111111111110)begin
      $display("Test 18: Pass");
    end
    else begin
      $display("Test 18: Fail");
    end

    //Test 19  SRA
    $display("");
    OS1 = 1'b1;
    OS2 = 2'b01;
    OP = 4'b1011;
    #2;
    if(Out == 32'b11111111111111111111111111111110)begin
      $display("Test 19: Pass");
    end
    else begin
      $display("Test 19: Fail");
    end

    //Test 20  Addition
    $display("");
    OS1 = 1'b1;
    OS2 = 2'b10;
    OP = 4'b0000;
    #2;
    if(Out == 32'b11111111110110000000000000000101)begin
      $display("Test 20: Pass");
    end
    else begin
      $display("Test 20: Fail");
    end

  end

  



endmodule