module Not_NZ_tb;
    reg NZ;

    wire not_NZ;

    Not_NZ dut(
        .NZ(NZ),
        .not_NZ(not_NZ)
    );

    initial begin
        NZ = 1'b1;
        $monitor("NZ = %b, not_NZ = %b", NZ, not_NZ);

        #2
        NZ = 1'b0;
    end
endmodule