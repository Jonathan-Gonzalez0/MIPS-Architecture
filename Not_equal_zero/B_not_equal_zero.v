module B_not_equal_zero(
    input wire[31:0] OB,

    output reg NZ
    );

    always@(*) begin
        if(OB != 0)
            NZ  = 1'b1;
        else
            NZ = 1'b0;
    end
endmodule