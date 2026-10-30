
module InstructionMemory (
    input wire [8:0] A,
    output wire [31:0] I
);

    // Memoria ROM de 512 bytes
    reg [7:0] Mem [0:511];

    // Lectura combinacional big-endian
    assign I = {Mem[A],
                Mem[A+1],
                Mem[A+2],
                Mem[A+3]};

endmodule
