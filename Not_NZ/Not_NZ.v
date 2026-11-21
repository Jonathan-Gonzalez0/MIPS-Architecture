module Not_NZ(
    input wire NZ,
    output reg not_NZ
    );

    always@(*)begin
    not_NZ = ~NZ;
    end

endmodule