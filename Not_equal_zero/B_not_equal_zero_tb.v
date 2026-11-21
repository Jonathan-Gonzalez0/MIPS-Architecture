module B_not_equal_zero_tb;

    reg[31:0] OB;

    wire NZ;

    B_not_equal_zero dut(
        .OB(OB),
        .NZ(NZ)
    );

    initial begin
        OB = 32'd0;
        $monitor("OB = %0d, NZ = %b", OB, NZ);

        #2
        OB = 32'd5;
    end

endmodule