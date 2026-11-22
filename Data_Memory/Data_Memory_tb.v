`timescale 1ns/1ps

module Data_Memory_tb;
  reg[31:0] DI;
  reg[31:0] A;
  reg RW;
  reg E;
  reg[1:0] size;
  reg SE;
  
  wire[31:0] DO;

  DataMemory dut(
    .DI(DI),
    .A(A),
    .RW(RW),
    .E(E),
    .size(size),
    .SE(SE),

    .DO(DO)
  );

  initial begin
    $readmemb(
      "Validation_Code.txt",
      dut.Mem, 0, 79
    );

    DI = 32'd3;
    A = 32'd4;
    E = 1'b1;
    size = 2'b00;
    RW = 1'b0;
    SE = 1'b1;

    //$monitor("DO = %b", DO);

    #2
    size = 2'b01;
    
    #2
    size = 2'b10;

    #2
    size = 2'b11;
    RW = 1'b1;
    E = 1'b0;

    #1
    $display("Mem[A] = %b", {dut.Mem[A],dut.Mem[A+1], dut.Mem[A+2], dut.Mem[A+3]});

  end


endmodule