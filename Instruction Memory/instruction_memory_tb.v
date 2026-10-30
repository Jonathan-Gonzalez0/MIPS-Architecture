
`timescale 1ns/1ps

module instruction_memory_tb;

    reg [8:0] A;
    wire [31:0] I;

    // Instruction Memory connecciones
    InstructionMemory memory (
        .A(A),
        .I(I)
    );

    initial begin

        // Cargar instrucciones a memoria
        $readmemb(
            "test_instructions_memory.txt",
            memory.Mem, 0, 99
        );

        // Leer instrucciones
        A = 0;
        #2;
        $display("A=%0d I=%h", A, I);

        A = 4;
        #2;
        $display("A=%0d I=%h", A, I);

        A = 8;
        #2;
        $display("A=%0d I=%h", A, I);

        A = 12;
        #2;
        $display("A=%0d I=%h", A, I);

        $finish;

    end

endmodule
